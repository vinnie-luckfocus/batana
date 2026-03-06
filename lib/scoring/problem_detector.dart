import '../analysis/metrics_calculator.dart';

/// 问题类型枚举
///
/// 定义了棒球挥棒动作中常见的问题类型
enum ProblemType {
  /// 过早开肩 - 肩部先于髋部转动
  earlyShoulder,

  /// 重心后移不足 - 击球时重心偏前
  insufficientWeightShift,

  /// 挥棒速度不足
  insufficientSpeed,

  /// 挥棒角度过小
  angleTooSmall,

  /// 挥棒角度过大
  angleTooLarge,

  /// 协调性不足
  poorCoordination,
}

/// 扩展 ProblemType 的辅助方法
extension ProblemTypeExtension on ProblemType {
  /// 获取问题类型的中文描述
  String get description {
    switch (this) {
      case ProblemType.earlyShoulder:
        return '过早开肩';
      case ProblemType.insufficientWeightShift:
        return '重心后移不足';
      case ProblemType.insufficientSpeed:
        return '挥棒速度不足';
      case ProblemType.angleTooSmall:
        return '挥棒角度过小';
      case ProblemType.angleTooLarge:
        return '挥棒角度过大';
      case ProblemType.poorCoordination:
        return '协调性不足';
    }
  }

  /// 获取问题类型的严重程度
  /// 数值越大越严重
  int get severity {
    switch (this) {
      case ProblemType.earlyShoulder:
        return 3;
      case ProblemType.insufficientWeightShift:
        return 2;
      case ProblemType.insufficientSpeed:
        return 3;
      case ProblemType.angleTooSmall:
        return 2;
      case ProblemType.angleTooLarge:
        return 2;
      case ProblemType.poorCoordination:
        return 2;
    }
  }
}

/// 评分结果数据结构
///
/// 包含挥棒动作的完整评分信息
class ScoringResult {
  const ScoringResult({
    required this.totalScore,
    required this.velocityScore,
    required this.angleScore,
    required this.coordinationScore,
    required this.problems,
    required this.suggestions,
  });

  /// 综合评分 (0-100)
  final int totalScore;

  /// 速度评分 (0-100)
  final double velocityScore;

  /// 角度评分 (0-100)
  final double angleScore;

  /// 协调性评分 (0-100)
  final double coordinationScore;

  /// 检测到的问题列表
  final List<ProblemType> problems;

  /// 改进建议列表
  final List<String> suggestions;

  /// 综合评分等级
  String get grade {
    if (totalScore >= 90) return '优秀';
    if (totalScore >= 75) return '良好';
    if (totalScore >= 60) return '及格';
    return '需改进';
  }

  /// 是否有问题
  bool get hasProblems => problems.isNotEmpty;

  /// 打印评分结果
  @override
  String toString() {
    return 'ScoringResult(总分: $totalScore, 速度: $velocityScore, 角度: $angleScore, 协调性: $coordinationScore, 问题: ${problems.length}, 建议: ${suggestions.length})';
  }
}

/// 问题检测器配置
class ProblemDetectorConfig {
  const ProblemDetectorConfig({
    /// 最小挥棒速度 (m/s)
    this.minVelocity = 10.0,

    /// 理想挥棒角度最小值 (度)
    this.minAngle = 30.0,

    /// 理想挥棒角度最大值 (度)
    this.maxAngle = 60.0,

    /// 协调性最低阈值
    this.minCoordination = 0.5,

    /// 髋肩时序差阈值 (毫秒)
    this.hipShoulderDelayThreshold = 0.0,
  });

  /// 最小挥棒速度 (m/s)
  final double minVelocity;

  /// 理想挥棒角度最小值 (度)
  final double minAngle;

  /// 理想挥棒角度最大值 (度)
  final double maxAngle;

  /// 协调性最低阈值
  final double minCoordination;

  /// 髋肩时序差阈值 (毫秒)
  /// 小于等于此值认为是过早开肩
  final double hipShoulderDelayThreshold;
}

/// 问题检测器
///
/// 基于挥棒指标检测常见问题模式
class ProblemDetector {
  ProblemDetector({ProblemDetectorConfig? config})
      : _config = config ?? const ProblemDetectorConfig();

  final ProblemDetectorConfig _config;

  /// 检测问题
  ///
  /// 根据挥棒指标检测存在的问题
  List<ProblemType> detectProblems(SwingMetrics metrics) {
    final problems = <ProblemType>[];

    // 检测过早开肩
    if (metrics.hipShoulderDelay < _config.hipShoulderDelayThreshold) {
      problems.add(ProblemType.earlyShoulder);
    }

    // 检测速度不足
    if (metrics.velocity < _config.minVelocity) {
      problems.add(ProblemType.insufficientSpeed);
    }

    // 检测角度过小
    if (metrics.maxAngle < _config.minAngle) {
      problems.add(ProblemType.angleTooSmall);
    }

    // 检测角度过大
    if (metrics.maxAngle > _config.maxAngle) {
      problems.add(ProblemType.angleTooLarge);
    }

    // 检测协调性不足
    final coordinationScore = _calculateCoordinationScore(metrics);
    if (coordinationScore < _config.minCoordination) {
      problems.add(ProblemType.poorCoordination);
    }

    return problems;
  }

  /// 计算协调性分数
  double _calculateCoordinationScore(SwingMetrics metrics) {
    // 综合髋肩时序和重心转移流畅度
    final hipScore = metrics.hipShoulderDelay > 0 ? 1.0 : 0.5;
    final transferScore = metrics.transferSmoothness;
    return (hipScore + transferScore) / 2;
  }
}
