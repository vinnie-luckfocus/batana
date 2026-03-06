import 'dart:math';
import '../analysis/metrics_calculator.dart';
import 'problem_detector.dart';

/// 评分引擎配置
class ScoringEngineConfig {
  const ScoringEngineConfig({
    /// 速度指标权重
    this.velocityWeight = 0.35,

    /// 角度指标权重
    this.angleWeight = 0.35,

    /// 协调性指标权重
    this.coordinationWeight = 0.30,

    /// 速度评分参考最小值 (m/s)
    this.velocityMin = 10.0,

    /// 速度评分参考最大值 (m/s)
    this.velocityMax = 30.0,

    /// 角度评分参考最小值 (度)
    this.angleMin = 20.0,

    /// 角度评分参考最大值 (度)
    this.angleMax = 70.0,

    /// 协调性评分参考最小值
    this.coordinationMin = 0.0,

    /// 协调性评分参考最大值
    this.coordinationMax = 1.0,
  });

  /// 速度指标权重 (默认 35%)
  final double velocityWeight;

  /// 角度指标权重 (默认 35%)
  final double angleWeight;

  /// 协调性指标权重 (默认 30%)
  final double coordinationWeight;

  /// 速度评分参考最小值 (m/s)
  final double velocityMin;

  /// 速度评分参考最大值 (m/s)
  final double velocityMax;

  /// 角度评分参考最小值 (度)
  final double angleMin;

  /// 角度评分参考最大值 (度)
  final double angleMax;

  /// 协调性评分参考最小值
  final double coordinationMin;

  /// 协调性评分参考最大值
  final double coordinationMax;

  /// 验证权重总和
  bool get isValid {
    final sum = velocityWeight + angleWeight + coordinationWeight;
    return (sum - 1.0).abs() < 0.01;
  }
}

/// 评分引擎
///
/// 根据挥棒指标计算综合评分
class ScoringEngine {
  ScoringEngine({ScoringEngineConfig? config})
      : _config = config ?? const ScoringEngineConfig();

  final ScoringEngineConfig _config;

  /// 计算综合评分
  ///
  /// 根据挥棒指标计算综合评分和各分项评分
  /// 返回 [ScoringResult] 包含所有评分信息
  ScoringResult calculate(SwingMetrics metrics) {
    // 计算各分项评分
    final velocityScore = _calculateVelocityScore(metrics.velocity);
    final angleScore = _calculateAngleScore(metrics.maxAngle);
    final coordinationScore = _calculateCoordinationScore(metrics);

    // 计算综合评分
    final totalScore = _calculateTotalScore(
      velocityScore,
      angleScore,
      coordinationScore,
    );

    // 检测问题
    final problemDetector = ProblemDetector();
    final problems = problemDetector.detectProblems(metrics);

    // 生成建议
    final suggestionGenerator = SuggestionGenerator();
    final suggestions = suggestionGenerator.generateSuggestions(
      metrics,
      problems,
    );

    return ScoringResult(
      totalScore: totalScore.round(),
      velocityScore: velocityScore,
      angleScore: angleScore,
      coordinationScore: coordinationScore,
      problems: problems,
      suggestions: suggestions,
    );
  }

  /// 计算速度评分
  ///
  /// 使用线性映射将速度转换为 0-100 的分数
  /// 速度越快分数越高
  double _calculateVelocityScore(double velocity) {
    return _mapToScore(
      velocity,
      _config.velocityMin,
      _config.velocityMax,
    );
  }

  /// 计算角度评分
  ///
  /// 使用目标范围映射: 角度在理想范围内得高分
  /// 偏离理想范围则扣分
  double _calculateAngleScore(double angle) {
    const idealMin = 30.0;
    const idealMax = 60.0;
    const idealMid = 45.0;

    // 如果在理想范围内
    if (angle >= idealMin && angle <= idealMax) {
      // 计算与理想中点的偏差
      final deviation = (angle - idealMid).abs();
      final maxDeviation = (idealMax - idealMin) / 2;
      // 偏差越小分数越高
      return 100 - (deviation / maxDeviation * 20);
    }

    // 如果在理想范围外
    if (angle < idealMin) {
      return _mapToScore(angle, _config.angleMin, idealMin);
    } else {
      return _mapToScore(angle, idealMax, _config.angleMax);
    }
  }

  /// 计算协调性评分
  ///
  /// 综合髋肩时序和重心转移流畅度
  double _calculateCoordinationScore(SwingMetrics metrics) {
    // 髋肩时序评分: 正值得满分，负值扣分
    final hipScore = metrics.hipShoulderDelay > 0 ? 100.0 : 50.0;

    // 重心转移流畅度直接映射到 0-100
    final transferScore = metrics.transferSmoothness * 100;

    // 综合评分
    return (hipScore * 0.4 + transferScore * 0.6);
  }

  /// 计算综合评分
  ///
  /// 综合速度、角度、协调性三个维度的评分
  double _calculateTotalScore(
    double velocityScore,
    double angleScore,
    double coordinationScore,
  ) {
    return velocityScore * _config.velocityWeight +
        angleScore * _config.angleWeight +
        coordinationScore * _config.coordinationWeight;
  }

  /// 将值映射到 0-100 分数
  ///
  /// 使用线性映射，当值小于最小值时返回 0，
  /// 当值大于最大值时返回 100
  double _mapToScore(double value, double min, double max) {
    if (value <= min) return 0.0;
    if (value >= max) return 100.0;
    return ((value - min) / (max - min)) * 100;
  }
}

/// 建议生成器
///
/// 根据问题和指标生成改进建议
class SuggestionGenerator {
  SuggestionGenerator();

  /// 生成建议
  ///
  /// [metrics] 挥棒指标
  /// [problems] 检测到的问题列表
  List<String> generateSuggestions(
    SwingMetrics metrics,
    List<ProblemType> problems,
  ) {
    final suggestions = <String>[];

    // 按严重程度排序问题
    final sortedProblems = List<ProblemType>.from(problems)
      ..sort((a, b) => b.severity.compareTo(a.severity));

    // 为每个问题生成建议
    for (final problem in sortedProblems) {
      final suggestion = _getSuggestionForProblem(problem, metrics);
      if (suggestion != null && !suggestions.contains(suggestion)) {
        suggestions.add(suggestion);
      }
    }

    // 如果没有问题，添加积极反馈
    if (suggestions.isEmpty) {
      suggestions.add('动作表现优秀！继续保持当前的挥棒节奏和姿势。');
    }

    return suggestions;
  }

  /// 根据问题类型获取对应建议
  String? _getSuggestionForProblem(
    ProblemType problem,
    SwingMetrics metrics,
  ) {
    switch (problem) {
      case ProblemType.earlyShoulder:
        return _getEarlyShoulderSuggestion(metrics);
      case ProblemType.insufficientWeightShift:
        return '练习击球准备姿势时，将重心放在后脚，启动挥棒时先从前脚开始转移重心。';
      case ProblemType.insufficientSpeed:
        return _getSpeedSuggestion(metrics);
      case ProblemType.angleTooSmall:
        return '尝试增加挥棒轨迹的角度，可以加大从上往下挥动的幅度。';
      case ProblemType.angleTooLarge:
        return '控制挥棒轨迹，保持更平面的挥棒角度，避免过大或过小的角度。';
      case ProblemType.poorCoordination:
        return _getCoordinationSuggestion(metrics);
    }
  }

  /// 过早开肩的建议
  String _getEarlyShoulderSuggestion(SwingMetrics metrics) {
    if (metrics.hipShoulderDelay < -100) {
      return '注意髋部转动要明显先于肩部，练习"先转髋再转肩"的动作顺序。';
    }
    return '保持髋部领先肩部的动作节奏，练习击球时注意力放在髋部转动上。';
  }

  /// 速度不足的建议
  String _getSpeedSuggestion(SwingMetrics metrics) {
    if (metrics.velocity < 5) {
      return '先从慢速挥棒开始练习动作完整性，然后逐步提升速度。';
    }
    return '加强挥棒速度训练，可以尝试挥重棒练习来增强力量。';
  }

  /// 协调性不足的建议
  String _getCoordinationSuggestion(SwingMetrics metrics) {
    if (metrics.transferSmoothness < 0.3) {
      return '放慢挥棒节奏，仔细感受身体的协调转动，注意重心平稳转移。';
    }
    return '继续练习整体动作的协调性，注意髋部和肩部的配合时机。';
  }
}
