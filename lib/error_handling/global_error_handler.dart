import 'package:flutter/foundation.dart';
import '../analysis/pose_detector.dart';
import '../analysis/swing_phase_detector.dart';
import '../analysis/metrics_calculator.dart';
import '../scoring/scoring_engine.dart';
import '../scoring/problem_detector.dart';

/// 全局错误类型枚举
enum ErrorType {
  /// 摄像头错误
  camera,

  /// 姿态识别错误
  poseDetection,

  /// 阶段检测错误
  phaseDetection,

  /// 指标计算错误
  metricsCalculation,

  /// 评分错误
  scoring,

  /// 存储错误
  storage,

  /// 未知错误
  unknown,
}

/// 应用错误
class AppError {
  const AppError({
    required this.type,
    required this.message,
    this.stackTrace,
    this.context,
    this.recoverable = true,
  });

  /// 错误类型
  final ErrorType type;

  /// 错误信息
  final String message;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  /// 错误上下文
  final Map<String, dynamic>? context;

  /// 是否可恢复
  final bool recoverable;

  /// 获取错误类型的中文描述
  String get typeDescription {
    switch (type) {
      case ErrorType.camera:
        return '摄像头错误';
      case ErrorType.poseDetection:
        return '姿态识别错误';
      case ErrorType.phaseDetection:
        return '阶段检测错误';
      case ErrorType.metricsCalculation:
        return '指标计算错误';
      case ErrorType.scoring:
        return '评分错误';
      case ErrorType.storage:
        return '存储错误';
      case ErrorType.unknown:
        return '未知错误';
    }
  }

  @override
  String toString() => '[${typeDescription}] $message';
}

/// 错误日志记录器
class ErrorLogger {
  ErrorLogger._();

  static final ErrorLogger instance = ErrorLogger._();

  final List<AppError> _errors = [];
  static const int maxLogSize = 100;

  /// 记录错误
  void log(AppError error) {
    _errors.add(error);

    // 限制日志大小
    if (_errors.length > maxLogSize) {
      _errors.removeAt(0);
    }

    // 输出到调试控制台
    debugPrint('ERROR: ${error.typeDescription} - ${error.message}');
    if (error.stackTrace != null) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
  }

  /// 记录摄像头错误
  void logCameraError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.camera,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 记录姿态识别错误
  void logPoseError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.poseDetection,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 记录阶段检测错误
  void logPhaseError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.phaseDetection,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 记录指标计算错误
  void logMetricsError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.metricsCalculation,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 记录评分错误
  void logScoringError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.scoring,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 记录存储错误
  void logStorageError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.storage,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 记录未知错误
  void logUnknownError(String message, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    log(AppError(
      type: ErrorType.unknown,
      message: message,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  /// 获取所有错误
  List<AppError> get errors => List.unmodifiable(_errors);

  /// 获取特定类型的错误
  List<AppError> getErrorsByType(ErrorType type) {
    return _errors.where((e) => e.type == type).toList();
  }

  /// 清除所有错误
  void clear() {
    _errors.clear();
  }
}

/// 全局错误捕获回调类型
typedef ErrorCallback = void Function(AppError error);

/// 全局错误处理器
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static final GlobalErrorHandler instance = GlobalErrorHandler._();

  final List<ErrorCallback> _callbacks = [];

  /// Flutter 错误回调
  void Function()? flutterErrorCallback;

  /// 注册错误回调
  void registerCallback(ErrorCallback callback) {
    _callbacks.add(callback);
  }

  /// 移除错误回调
  void unregisterCallback(ErrorCallback callback) {
    _callbacks.remove(callback);
  }

  /// 处理错误
  void handleError(AppError error) {
    // 记录到日志
    ErrorLogger.instance.log(error);

    // 通知所有回调
    for (final callback in _callbacks) {
      try {
        callback(error);
      } catch (e) {
        debugPrint('Error in error callback: $e');
      }
    }
  }

  /// 处理捕获到的异常
  void handleException(Object exception, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    final error = AppError(
      type: _getErrorType(exception),
      message: exception.toString(),
      stackTrace: stackTrace,
      context: context,
      recoverable: _isRecoverable(exception),
    );

    handleError(error);
  }

  /// 根据异常类型确定错误类型
  ErrorType _getErrorType(Object exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('camera')) {
      return ErrorType.camera;
    } else if (message.contains('pose') || message.contains('mediapipe')) {
      return ErrorType.poseDetection;
    } else if (message.contains('phase')) {
      return ErrorType.phaseDetection;
    } else if (message.contains('metrics') || message.contains('calculation')) {
      return ErrorType.metricsCalculation;
    } else if (message.contains('score') || message.contains('scoring')) {
      return ErrorType.scoring;
    } else if (message.contains('database') || message.contains('storage') || message.contains('sqflite')) {
      return ErrorType.storage;
    }

    return ErrorType.unknown;
  }

  /// 判断异常是否可恢复
  bool _isRecoverable(Object exception) {
    // 网络错误、临时性错误通常可恢复
    final message = exception.toString().toLowerCase();

    // 不可恢复的错误
    if (message.contains('fatal') ||
        message.contains('crash') ||
        message.contains('permission denied')) {
      return false;
    }

    return true;
  }
}

/// 优雅降级策略
class GracefulDegradation {
  GracefulDegradation._();

  /// 默认降级动作
  static T? fallback<T>({
    required String operation,
    required T defaultValue,
    String? errorMessage,
  }) {
    ErrorLogger.instance.logUnknownError(
      errorMessage ?? '$operation 失败，使用默认值',
    );
    return defaultValue;
  }

  /// 姿态识别降级
  static PoseDetectionResult poseDetectionFallback({String? errorMessage}) {
    ErrorLogger.instance.logPoseError(
      errorMessage ?? '姿态识别失败，返回空结果',
    );
    return const PoseDetectionResult();
  }

  /// 阶段检测降级
  static SwingPhaseResult phaseDetectionFallback({String? errorMessage}) {
    ErrorLogger.instance.logPhaseError(
      errorMessage ?? '阶段检测失败，返回默认结果',
    );
    return const SwingPhaseResult(
      phases: [],
      phaseBoundaries: [],
      isFullPhase: false,
      errorMessage: '阶段检测降级处理',
    );
  }

  /// 指标计算降级
  static SwingMetrics metricsCalculationFallback({String? errorMessage}) {
    ErrorLogger.instance.logMetricsError(
      errorMessage ?? '指标计算失败，返回默认值',
    );
    return const SwingMetrics(
      velocity: 0.0,
      velocityLevel: '未知',
      maxAngle: 0.0,
      hipShoulderDelay: 0.0,
      transferSmoothness: 0.0,
    );
  }

  /// 评分降级
  static ScoringResult scoringFallback({String? errorMessage}) {
    ErrorLogger.instance.logScoringError(
      errorMessage ?? '评分失败，返回默认结果',
    );
    return const ScoringResult(
      totalScore: 0,
      velocityScore: 0.0,
      angleScore: 0.0,
      coordinationScore: 0.0,
      problems: [],
      suggestions: ['分析过程中出现错误，请重新录制'],
    );
  }
}
