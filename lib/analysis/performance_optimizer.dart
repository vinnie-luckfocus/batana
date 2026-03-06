import 'dart:async';
import 'dart:isolate';
import 'pose_detector.dart';

/// 帧采样器配置
class FrameSamplerConfig {
  const FrameSamplerConfig({
    /// 采样间隔 (每 N 帧处理一次)
    this.sampleInterval = 2,

    /// 是否启用智能采样
    this.enableSmartSampling = true,

    /// 运动检测阈值
    this.motionThreshold = 0.01,
  });

  /// 采样间隔
  final int sampleInterval;

  /// 是否启用智能采样
  final bool enableSmartSampling;

  /// 运动检测阈值
  final double motionThreshold;
}

/// 帧采样器
///
/// 用于减少 MediaPipe 处理负载
/// - 固定间隔采样: 每 N 帧处理一次
/// - 智能采样: 只在检测到明显运动时处理
class FrameSampler {
  FrameSampler({FrameSamplerConfig? config})
      : _config = config ?? const FrameSamplerConfig();

  final FrameSamplerConfig _config;

  int _frameCount = 0;
  PoseData? _lastProcessedFrame;
  double _lastMotionMagnitude = 0.0;

  /// 是否应该处理当前帧
  bool shouldProcessFrame(PoseData? currentFrame) {
    _frameCount++;

    // 固定间隔采样
    if (!_config.enableSmartSampling) {
      return _frameCount % _config.sampleInterval == 0;
    }

    // 智能采样
    if (currentFrame == null) return false;

    // 计算运动幅度
    final motionMagnitude = _calculateMotionMagnitude(currentFrame);

    // 如果运动幅度明显变化，处理当前帧
    final motionDelta = (motionMagnitude - _lastMotionMagnitude).abs();
    if (motionDelta > _config.motionThreshold) {
      _lastMotionMagnitude = motionMagnitude;
      _lastProcessedFrame = currentFrame;
      return true;
    }

    // 定期处理（避免完全跳过）
    return _frameCount % _config.sampleInterval == 0;
  }

  /// 计算运动幅度
  double _calculateMotionMagnitude(PoseData currentFrame) {
    if (_lastProcessedFrame == null) return 0.0;

    double totalMovement = 0.0;
    int count = 0;

    final currentLandmarks = currentFrame.landmarks;
    final lastLandmarks = _lastProcessedFrame!.landmarks;

    // 简单的关键点距离计算
    for (int i = 0; i < currentLandmarks.length && i < lastLandmarks.length; i++) {
      final current = currentLandmarks[i];
      final last = lastLandmarks[i];

      if (current.isValid && last.isValid) {
        final dx = current.x - last.x;
        final dy = current.y - last.y;
        totalMovement += (dx * dx + dy * dy);
        count++;
      }
    }

    return count > 0 ? (totalMovement / count) : 0.0;
  }

  /// 重置采样器状态
  void reset() {
    _frameCount = 0;
    _lastProcessedFrame = null;
    _lastMotionMagnitude = 0.0;
  }

  /// 获取当前帧计数
  int get frameCount => _frameCount;
}

/// 关键点缓存
///
/// 避免重复计算关键点派生数据
class LandmarkCache {
  final Map<String, dynamic> _cache = {};

  /// 缓存过期时间 (毫秒)
  final int cacheExpiryMs;

  /// 最后更新时间
  int _lastUpdateTime = 0;

  LandmarkCache({this.cacheExpiryMs = 100});

  /// 获取缓存值
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    final cacheEntry = entry as _CacheEntry<T>;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 检查是否过期
    if (now - cacheEntry.timestamp > cacheExpiryMs) {
      _cache.remove(key);
      return null;
    }

    return cacheEntry.value;
  }

  /// 设置缓存值
  void set<T>(String key, T value) {
    _cache[key] = _CacheEntry(
      value: value,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 清除所有缓存
  void clear() {
    _cache.clear();
    _lastUpdateTime = 0;
  }

  /// 清除过期缓存
  void evictExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      final cacheEntry = entry.value as _CacheEntry;
      if (now - cacheEntry.timestamp > cacheExpiryMs) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }
}

class _CacheEntry<T> {
  _CacheEntry({required this.value, required this.timestamp});

  final T value;
  final int timestamp;
}

/// 异步处理结果
class AsyncResult<T> {
  const AsyncResult({
    required this.data,
    required this.durationMs,
    this.error,
  });

  /// 数据 (可能为空)
  final T? data;

  /// 处理时长 (毫秒)
  final int durationMs;

  /// 错误信息
  final String? error;

  /// 是否成功
  bool get isSuccess => error == null;

  /// 是否失败
  bool get isFailure => !isSuccess;
}

/// 异步任务包装器
///
/// 用于在后台线程执行耗时操作
class AsyncProcessor {
  AsyncProcessor();

  /// 在隔离区执行任务
  Future<AsyncResult<T>> process<T>(
    T Function() task, {
    String? taskName,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 使用 Isolate.run 在隔离区执行 (支持闭包)
      final result = await Isolate.run(() => task());

      stopwatch.stop();

      return AsyncResult(
        data: result,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();

      return AsyncResult(
        data: null,
        durationMs: stopwatch.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }

  /// 带超时的异步处理
  Future<AsyncResult<T>> processWithTimeout<T>(
    T Function() task, {
    Duration timeout = const Duration(seconds: 10),
    String? taskName,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 使用 Isolate.run 在隔离区执行 (支持闭包)
      final result = await Isolate.run(() => task())
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('Task timeout: $taskName');
      });

      stopwatch.stop();

      return AsyncResult(
        data: result,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();

      return AsyncResult(
        data: null,
        durationMs: stopwatch.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }
}

/// 性能监控器
class PerformanceMonitor {
  PerformanceMonitor();

  final List<int> _durations = [];
  static const int maxSamples = 100;

  /// 记录执行时长
  void recordDuration(int durationMs) {
    _durations.add(durationMs);
    if (_durations.length > maxSamples) {
      _durations.removeAt(0);
    }
  }

  /// 获取 P50
  int get p50 {
    if (_durations.isEmpty) return 0;
    final sorted = List<int>.from(_durations)..sort();
    final index = ((sorted.length - 1) * 0.5).round();
    return sorted[index];
  }

  /// 获取 P95
  int get p95 {
    if (_durations.isEmpty) return 0;
    final sorted = List<int>.from(_durations)..sort();
    final index = ((sorted.length - 1) * 0.95).round();
    return sorted[index];
  }

  /// 获取 P99
  int get p99 {
    if (_durations.isEmpty) return 0;
    final sorted = List<int>.from(_durations)..sort();
    final index = ((sorted.length - 1) * 0.99).round();
    return sorted[index];
  }

  /// 获取平均时长
  int get average {
    if (_durations.isEmpty) return 0;
    return _durations.reduce((a, b) => a + b) ~/ _durations.length;
  }

  /// 获取样本数
  int get sampleCount => _durations.length;

  /// 重置监控器
  void reset() {
    _durations.clear();
  }

  /// 性能报告
  String get report {
    if (_durations.isEmpty) {
      return 'No performance data collected';
    }

    return 'Performance (n=$sampleCount): '
        'avg=${average}ms, '
        'P50=${p50}ms, '
        'P95=${p95}ms, '
        'P99=${p99}ms';
  }
}
