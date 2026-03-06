import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'pose_detector.dart';

/// 挥棒阶段枚举
///
/// 定义挥棒的四个阶段:
/// - prepare: 准备期 - 挥棒前静止
/// - accelerate: 加速期 - 腕部开始加速到最大速度
/// - strike: 击球期 - 最大速度点
/// - followThrough: 收尾期 - 击球后减速到静止
enum SwingPhase {
  /// 准备期: 挥棒前静止
  prepare,

  /// 加速期: 腕部开始加速到最大速度
  accelerate,

  /// 击球期: 最大速度点
  strike,

  /// 收尾期: 击球后减速到静止
  followThrough,
}

/// 挥棒阶段检测结果
class SwingPhaseResult {
  const SwingPhaseResult({
    required this.phases,
    required this.phaseBoundaries,
    required this.isFullPhase,
    this.errorMessage,
    this.peakVelocity,
    this.phaseVelocities,
  });

  /// 检测到的阶段列表
  final List<SwingPhase> phases;

  /// 阶段边界帧索引 [准备期结束, 加速期结束, 击球期结束]
  final List<int> phaseBoundaries;

  /// 是否完整四阶段
  final bool isFullPhase;

  /// 错误信息 (如果有)
  final String? errorMessage;

  /// 峰值速度
  final double? peakVelocity;

  /// 各阶段平均速度
  final List<double>? phaseVelocities;

  /// 是否成功
  bool get isSuccess => errorMessage == null && phases.isNotEmpty;

  /// 是否失败
  bool get isFailure => !isSuccess;

  @override
  String toString() {
    if (isFailure) {
      return 'SwingPhaseResult(error: $errorMessage)';
    }
    return 'SwingPhaseResult(phases: $phases, boundaries: $phaseBoundaries, isFullPhase: $isFullPhase)';
  }
}

/// 帧数据
class FrameData {
  const FrameData({
    required this.frameIndex,
    required this.timestamp,
    required this.wristPosition,
    this.wristVelocity = 0.0,
  });

  /// 帧索引
  final int frameIndex;

  /// 时间戳 (毫秒)
  final int timestamp;

  /// 腕部位置 (x, y, z)
  final Offset wristPosition;

  /// 腕部速度
  final double wristVelocity;
}

/// 挥棒阶段检测器配置
class SwingPhaseDetectorConfig {
  const SwingPhaseDetectorConfig({
    /// 速度阈值: 低于此值认为静止 (归一化坐标/秒)
    this.velocityThreshold = 0.05,

    /// 最小速度变化率 (用于检测加速/减速)
    this.accelerationThreshold = 0.01,

    /// 峰值检测的最小帧数间隔
    this.peakMinFrames = 5,

    /// 速度平滑窗口大小
    this.smoothingWindowSize = 3,

    /// 最小有效帧数
    this.minValidFrames = 30,

    /// 最小峰值速度
    this.minPeakVelocity = 0.1,
  });

  /// 速度阈值: 低于此值认为静止
  final double velocityThreshold;

  /// 最小速度变化率
  final double accelerationThreshold;

  /// 峰值检测的最小帧数间隔
  final int peakMinFrames;

  /// 速度平滑窗口大小
  final int smoothingWindowSize;

  /// 最小有效帧数
  final int minValidFrames;

  /// 最小峰值速度
  final double minPeakVelocity;
}

/// 挥棒阶段检测器
///
/// 基于腕部速度曲线识别挥棒的四阶段
class SwingPhaseDetector {
  SwingPhaseDetector({SwingPhaseDetectorConfig? config})
      : _config = config ?? const SwingPhaseDetectorConfig();

  final SwingPhaseDetectorConfig _config;

  /// 检测挥棒阶段
  ///
  /// [frames] 按时间顺序排列的帧数据列表
  /// [useDominantHand] 是否使用惯用手 (true=右手, false=左手)
  SwingPhaseResult detect(List<FrameData> frames, {bool useDominantHand = true}) {
    // 验证输入
    if (frames.isEmpty) {
      return const SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: '无帧数据',
      );
    }

    if (frames.length < _config.minValidFrames) {
      return SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: '帧数不足: ${frames.length} < ${_config.minValidFrames}',
      );
    }

    // 尝试四阶段分割
    final fourPhaseResult = _detectFourPhase(frames);
    if (fourPhaseResult.isSuccess) {
      return fourPhaseResult;
    }

    // 降级到三阶段
    final threePhaseResult = _detectThreePhase(frames);
    if (threePhaseResult.isSuccess) {
      return threePhaseResult;
    }

    // 返回失败原因
    return SwingPhaseResult(
      phases: [],
      phaseBoundaries: [],
      isFullPhase: false,
      errorMessage: fourPhaseResult.errorMessage ?? '未检测到完整挥棒动作',
    );
  }

  /// 检测四阶段
  SwingPhaseResult _detectFourPhase(List<FrameData> frames) {
    // 1. 计算平滑后的速度曲线
    final smoothedVelocities = _smoothVelocities(frames);

    // 2. 找到速度峰值
    final peakIndex = _findPeakVelocityIndex(smoothedVelocities);
    if (peakIndex == -1) {
      return const SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: '未检测到速度峰值',
      );
    }

    // 3. 找到各阶段边界
    final boundaries = _findFourPhaseBoundaries(frames, smoothedVelocities, peakIndex);

    // 4. 验证阶段分割
    if (!_validateFourPhase(boundaries, frames.length)) {
      return const SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: '阶段分割验证失败',
      );
    }

    // 5. 构建结果
    final phases = [
      SwingPhase.prepare,
      SwingPhase.accelerate,
      SwingPhase.strike,
      SwingPhase.followThrough,
    ];

    // 计算各阶段平均速度
    final phaseVelocities = _calculatePhaseVelocities(frames, boundaries);

    // 找到峰值速度
    final peakVelocity = smoothedVelocities[peakIndex];

    return SwingPhaseResult(
      phases: phases,
      phaseBoundaries: boundaries,
      isFullPhase: true,
      peakVelocity: peakVelocity,
      phaseVelocities: phaseVelocities,
    );
  }

  /// 检测三阶段 (降级策略)
  SwingPhaseResult _detectThreePhase(List<FrameData> frames) {
    // 1. 计算平滑后的速度曲线
    final smoothedVelocities = _smoothVelocities(frames);

    // 2. 找到速度峰值
    final peakIndex = _findPeakVelocityIndex(smoothedVelocities);
    if (peakIndex == -1) {
      return const SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: '三阶段: 未检测到速度峰值',
      );
    }

    // 3. 找到三阶段边界
    final boundaries = _findThreePhaseBoundaries(frames, smoothedVelocities, peakIndex);

    // 4. 验证阶段分割
    if (!_validateThreePhase(boundaries, frames.length)) {
      return const SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: '三阶段分割验证失败',
      );
    }

    // 5. 构建结果 - 三阶段: 启动-击球-收尾
    final phases = [
      SwingPhase.prepare, // 启动期 (合并准备+加速)
      SwingPhase.strike,
      SwingPhase.followThrough,
    ];

    // 计算各阶段平均速度
    final phaseVelocities = _calculatePhaseVelocities(frames, boundaries);
    final peakVelocity = smoothedVelocities[peakIndex];

    return SwingPhaseResult(
      phases: phases,
      phaseBoundaries: boundaries,
      isFullPhase: false,
      peakVelocity: peakVelocity,
      phaseVelocities: phaseVelocities,
    );
  }

  /// 平滑速度曲线 (移动平均)
  List<double> _smoothVelocities(List<FrameData> frames) {
    if (frames.length <= _config.smoothingWindowSize) {
      return frames.map((f) => f.wristVelocity).toList();
    }

    final velocities = frames.map((f) => f.wristVelocity).toList();
    final smoothed = <double>[];

    for (int i = 0; i < velocities.length; i++) {
      final windowStart = max(0, i - _config.smoothingWindowSize ~/ 2);
      final windowEnd = min(velocities.length, i + _config.smoothingWindowSize ~/ 2 + 1);

      double sum = 0;
      for (int j = windowStart; j < windowEnd; j++) {
        sum += velocities[j];
      }
      smoothed.add(sum / (windowEnd - windowStart));
    }

    return smoothed;
  }

  /// 找到速度峰值索引
  int _findPeakVelocityIndex(List<double> velocities) {
    if (velocities.isEmpty) return -1;

    // 检查是否有多个峰值 (多次挥棒)
    final peaks = _findAllPeaks(velocities);
    if (peaks.length > 1) {
      debugPrint('检测到多次挥棒: ${peaks.length}个峰值');
      // 返回最大峰值
    }

    if (peaks.isEmpty) return -1;

    // 返回最大速度的峰值
    int maxPeakIndex = peaks[0];
    double maxVelocity = velocities[maxPeakIndex];

    for (int i = 1; i < peaks.length; i++) {
      if (velocities[peaks[i]] > maxVelocity) {
        maxVelocity = velocities[peaks[i]];
        maxPeakIndex = peaks[i];
      }
    }

    // 检查峰值是否足够大
    if (maxVelocity < _config.minPeakVelocity) {
      return -1;
    }

    return maxPeakIndex;
  }

  /// 找到所有局部峰值
  List<int> _findAllPeaks(List<double> velocities) {
    if (velocities.length < _config.peakMinFrames * 2) {
      return [];
    }

    final peaks = <int>[];

    for (int i = _config.peakMinFrames;
        i < velocities.length - _config.peakMinFrames;
        i++) {
      bool isPeak = true;

      // 检查前后窗口内的点
      for (int j = 1; j <= _config.peakMinFrames; j++) {
        if (velocities[i] <= velocities[i - j] ||
            velocities[i] <= velocities[i + j]) {
          isPeak = false;
          break;
        }
      }

      if (isPeak) {
        peaks.add(i);
      }
    }

    return peaks;
  }

  /// 找到四阶段边界
  List<int> _findFourPhaseBoundaries(
    List<FrameData> frames,
    List<double> velocities,
    int peakIndex,
  ) {
    final boundaries = <int>[];

    // 边界1: 准备期结束 (速度开始上升的点)
    final prepareEnd = _findPrepareEnd(velocities, peakIndex);
    boundaries.add(prepareEnd);

    // 边界2: 加速期结束 (速度峰值点)
    boundaries.add(peakIndex);

    // 边界3: 击球期结束 (速度开始快速下降的点)
    final strikeEnd = _findStrikeEnd(velocities, peakIndex);
    boundaries.add(strikeEnd);

    return boundaries;
  }

  /// 找到准备期结束点
  int _findPrepareEnd(List<double> velocities, int peakIndex) {
    // 从峰值向前找,找到速度开始持续上升的点
    final threshold = _config.velocityThreshold;

    // 首先找到第一个超过阈值的点
    for (int i = peakIndex - 1; i >= 0; i--) {
      if (velocities[i] > threshold) {
        // 从这个点继续向前,找到速度变化的拐点
        for (int j = i - 1; j >= 0; j--) {
          if (velocities[j] < threshold * 1.5) {
            return j;
          }
        }
        return max(0, i - 10);
      }
    }

    // 如果没找到,返回峰值前1/4处
    return max(0, peakIndex ~/ 4);
  }

  /// 找到击球期结束点
  int _findStrikeEnd(List<double> velocities, int peakIndex) {
    // 从峰值向后找,找到速度开始快速下降的点
    for (int i = peakIndex + 1; i < velocities.length - 1; i++) {
      final currentVel = velocities[i];
      final nextVel = velocities[i + 1];

      // 如果速度开始持续下降
      if (currentVel > nextVel * 1.2) {
        // 找到速度降到峰值一半以下的点
        final halfPeak = velocities[peakIndex] / 2;
        for (int j = i; j < velocities.length; j++) {
          if (velocities[j] < halfPeak) {
            return j;
          }
        }
        return velocities.length - 1;
      }
    }

    // 如果没找到,返回峰值后3/4处
    return min(velocities.length - 1, peakIndex + (velocities.length - peakIndex) * 3 ~/ 4);
  }

  /// 找到三阶段边界
  List<int> _findThreePhaseBoundaries(
    List<FrameData> frames,
    List<double> velocities,
    int peakIndex,
  ) {
    final boundaries = <int>[];

    // 边界1: 启动期结束 (速度开始快速上升)
    final startupEnd = _findStartupEnd(velocities, peakIndex);
    boundaries.add(startupEnd);

    // 边界2: 击球期结束 (速度峰值点)
    boundaries.add(peakIndex);

    return boundaries;
  }

  /// 找到启动期结束点
  int _findStartupEnd(List<double> velocities, int peakIndex) {
    final threshold = _config.velocityThreshold;

    // 找到速度超过阈值的点作为启动期结束
    for (int i = 0; i < peakIndex; i++) {
      if (velocities[i] > threshold) {
        return i;
      }
    }

    // 如果没找到,返回峰值前1/3处
    return peakIndex ~/ 3;
  }

  /// 验证四阶段分割
  bool _validateFourPhase(List<int> boundaries, int totalFrames) {
    if (boundaries.length != 3) return false;

    // 检查边界顺序
    if (boundaries[0] >= boundaries[1] ||
        boundaries[1] >= boundaries[2] ||
        boundaries[2] >= totalFrames - 1) {
      return false;
    }

    // 检查每个阶段是否有足够帧数
    final minPhaseFrames = totalFrames ~/ 10;
    if (boundaries[0] < minPhaseFrames ||
        boundaries[1] - boundaries[0] < minPhaseFrames ||
        boundaries[2] - boundaries[1] < minPhaseFrames ||
        totalFrames - boundaries[2] < minPhaseFrames) {
      return false;
    }

    return true;
  }

  /// 验证三阶段分割
  bool _validateThreePhase(List<int> boundaries, int totalFrames) {
    if (boundaries.length != 2) return false;

    // 检查边界顺序
    if (boundaries[0] >= boundaries[1] || boundaries[1] >= totalFrames - 1) {
      return false;
    }

    // 检查每个阶段是否有足够帧数
    final minPhaseFrames = totalFrames ~/ 8;
    if (boundaries[0] < minPhaseFrames ||
        boundaries[1] - boundaries[0] < minPhaseFrames ||
        totalFrames - boundaries[1] < minPhaseFrames) {
      return false;
    }

    return true;
  }

  /// 计算各阶段平均速度
  List<double> _calculatePhaseVelocities(List<FrameData> frames, List<int> boundaries) {
    if (boundaries.isEmpty) return [];

    final velocities = frames.map((f) => f.wristVelocity).toList();
    final phaseVelocities = <double>[];

    int start = 0;
    for (int i = 0; i < boundaries.length; i++) {
      final end = boundaries[i];
      if (end > start) {
        double sum = 0;
        for (int j = start; j < end; j++) {
          sum += velocities[j];
        }
        phaseVelocities.add(sum / (end - start));
      } else {
        phaseVelocities.add(0);
      }
      start = end;
    }

    // 最后一个阶段
    if (start < velocities.length) {
      double sum = 0;
      for (int j = start; j < velocities.length; j++) {
        sum += velocities[j];
      }
      phaseVelocities.add(sum / (velocities.length - start));
    }

    return phaseVelocities;
  }
}

/// 挥棒阶段分析器
///
/// 用于分析连续帧序列中的挥棒动作
class SwingPhaseAnalyzer {
  SwingPhaseAnalyzer({SwingPhaseDetectorConfig? config})
      : _detector = SwingPhaseDetector(config: config);

  final SwingPhaseDetector _detector;

  /// 帧数据列表
  final List<FrameData> _frames = [];

  /// 是否使用惯用手 (true=右手, false=左手)
  bool _useDominantHand = true;

  /// 是否使用惯用手
  bool get useDominantHand => _useDominantHand;

  /// 设置是否使用惯用手
  void setUseDominantHand(bool useDominantHand) {
    _useDominantHand = useDominantHand;
  }

  /// 添加帧数据
  void addFrame(int frameIndex, int timestamp, PoseData poseData) {
    // 获取腕部位置
    final wrist = _getWristPosition(poseData);
    if (wrist == null) return;

    // 计算速度
    double velocity = 0.0;
    if (_frames.isNotEmpty) {
      final prevFrame = _frames.last;
      final timeDelta = (timestamp - prevFrame.timestamp) / 1000.0; // 转换为秒

      if (timeDelta > 0) {
        // 计算位移
        final dx = wrist.dx - prevFrame.wristPosition.dx;
        final dy = wrist.dy - prevFrame.wristPosition.dy;
        final distance = sqrt(dx * dx + dy * dy);

        // 计算速度 (归一化坐标/秒)
        velocity = distance / timeDelta;
      }
    }

    _frames.add(FrameData(
      frameIndex: frameIndex,
      timestamp: timestamp,
      wristPosition: wrist,
      wristVelocity: velocity,
    ));
  }

  /// 获取腕部位置
  Offset? _getWristPosition(PoseData poseData) {
    final wrist = _useDominantHand
        ? poseData.getLandmark(PoseLandmark.rightWrist)
        : poseData.getLandmark(PoseLandmark.leftWrist);

    if (wrist != null && wrist.isValid) {
      return Offset(wrist.x, wrist.y);
    }

    // 如果首选手腕不可用,尝试另一只
    final altWrist = _useDominantHand
        ? poseData.getLandmark(PoseLandmark.leftWrist)
        : poseData.getLandmark(PoseLandmark.rightWrist);

    if (altWrist != null && altWrist.isValid) {
      return Offset(altWrist.x, altWrist.y);
    }

    return null;
  }

  /// 分析挥棒阶段
  SwingPhaseResult analyze() {
    return _detector.detect(_frames, useDominantHand: _useDominantHand);
  }

  /// 重置分析器
  void reset() {
    _frames.clear();
  }

  /// 获取当前帧数
  int get frameCount => _frames.length;
}
