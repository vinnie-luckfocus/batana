import '../analysis/metrics_calculator.dart';
import 'problem_detector.dart';

/// 建议模板库
///
/// 包含针对不同问题的建议模板
/// 格式: "通俗解释 + 可执行动作"
class SuggestionTemplate {
  const SuggestionTemplate({
    required this.problem,
    required this.title,
    required this.description,
    required this.action,
  });

  /// 对应的问题类型
  final ProblemType problem;

  /// 建议标题
  final String title;

  /// 通俗解释
  final String description;

  /// 可执行动作
  final String action;

  /// 完整的建议文本
  String get fullSuggestion => '$description $action';
}

/// 建议模板库
class SuggestionTemplateLibrary {
  SuggestionTemplateLibrary();

  /// 获取所有模板
  List<SuggestionTemplate> get templates => _templates;

  /// 根据问题类型获取对应模板
  SuggestionTemplate? getTemplate(ProblemType problem) {
    try {
      return _templates.firstWhere((t) => t.problem == problem);
    } catch (_) {
      return null;
    }
  }

  /// 获取所有模板
  static const List<SuggestionTemplate> _templates = [
    // 过早开肩相关建议
    SuggestionTemplate(
      problem: ProblemType.earlyShoulder,
      title: '先转髋后转肩',
      description: '挥棒时肩部转动过早，会导致力量损失。',
      action: '练习击球时，注意先转髋再转肩，可以在击球时喊"转髋"来提醒自己。',
    ),
    SuggestionTemplate(
      problem: ProblemType.earlyShoulder,
      title: '髋部领先启动',
      description: '髋部应该先于肩部开始转动，这是挥棒力量的主要来源。',
      action: '在挥棒准备动作中感受髋部的转动，从髋部开始带动整个身体。',
    ),

    // 重心后移不足相关建议
    SuggestionTemplate(
      problem: ProblemType.insufficientWeightShift,
      title: '重心转移训练',
      description: '击球时重心应该从后脚平稳转移到前脚。',
      action: '练习击球准备姿势时，将重心放在后脚，启动挥棒时先从前脚开始转移重心。',
    ),
    SuggestionTemplate(
      problem: ProblemType.insufficientWeightShift,
      title: '保持身体平衡',
      description: '身体平衡是稳定挥棒的基础。',
      action: '保持身体平衡，不要前倾或后仰，双脚与肩同宽稳定站位。',
    ),

    // 挥棒速度不足相关建议
    SuggestionTemplate(
      problem: ProblemType.insufficientSpeed,
      title: '提升挥棒速度',
      description: '挥棒速度是击球距离的关键因素。',
      action: '多进行挥棒速度训练，可以使用加重球拍来增强力量和速度。',
    ),
    SuggestionTemplate(
      problem: ProblemType.insufficientSpeed,
      title: '加快挥棒节奏',
      description: '快速的挥棒能产生更大的击球力量。',
      action: '在保证动作正确的前提下，逐步加快挥棒节奏和速度。',
    ),
    SuggestionTemplate(
      problem: ProblemType.insufficientSpeed,
      title: '力量训练',
      description: '核心力量和手臂力量对挥棒速度很重要。',
      action: '进行针对性的力量训练，包括核心力量、手臂力量和旋转力量的训练。',
    ),

    // 挥棒角度过小相关建议
    SuggestionTemplate(
      problem: ProblemType.angleTooSmall,
      title: '加大挥棒幅度',
      description: '挥棒角度过小会减少击球的有效面积。',
      action: '尝试增加挥棒轨迹的角度，可以加大从上往下挥动的幅度。',
    ),
    SuggestionTemplate(
      problem: ProblemType.angleTooSmall,
      title: '寻找理想击球点',
      description: '合适的挥棒角度能更好地击中球。',
      action: '调整击球点位置，在身体前方找到最佳的击球点。',
    ),

    // 挥棒角度过大相关建议
    SuggestionTemplate(
      problem: ProblemType.angleTooLarge,
      title: '控制挥棒轨迹',
      description: '过大的挥棒角度会导致击球不稳。',
      action: '控制挥棒轨迹，保持更平面的挥棒角度，避免过大或过小的角度。',
    ),
    SuggestionTemplate(
      problem: ProblemType.angleTooLarge,
      title: '平面挥棒练习',
      description: '使用平面挥棒路径可以提高击球稳定性。',
      action: '进行平面挥棒练习，想象用球棒水平画出一个平面。',
    ),

    // 协调性不足相关建议
    SuggestionTemplate(
      problem: ProblemType.poorCoordination,
      title: '整体动作协调',
      description: '身体的协调转动能产生更大的击球力量。',
      action: '放慢挥棒节奏，仔细感受身体的协调转动，注意重心平稳转移。',
    ),
    SuggestionTemplate(
      problem: ProblemType.poorCoordination,
      title: '节奏训练',
      description: '稳定的节奏有助于身体各部位的协调配合。',
      action: '练习击球时保持稳定节奏，注意髋部和肩部的配合时机。',
    ),
    SuggestionTemplate(
      problem: ProblemType.poorCoordination,
      title: '分解动作练习',
      description: '分步练习可以帮助建立正确的动作模式。',
      action: '先练习分解动作：准备姿势→转髋→转肩→击球，逐步连贯起来。',
    ),
  ];
}

/// 建议生成器
///
/// 使用模板库生成改进建议
class SuggestionGenerator {
  SuggestionGenerator({SuggestionTemplateLibrary? library})
      : _library = library ?? SuggestionTemplateLibrary();

  final SuggestionTemplateLibrary _library;

  /// 生成建议
  ///
  /// 根据挥棒指标和检测到的问题生成改进建议
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
      final suggestion = _generateForProblem(problem, metrics);
      if (suggestion != null && !suggestions.contains(suggestion)) {
        suggestions.add(suggestion);
      }
    }

    // 如果没有问题，添加积极反馈
    if (suggestions.isEmpty) {
      suggestions.addAll(_getPositiveFeedback(metrics));
    }

    return suggestions;
  }

  /// 为特定问题生成建议
  String? _generateForProblem(ProblemType problem, SwingMetrics metrics) {
    // 从模板库获取模板
    final template = _library.getTemplate(problem);
    if (template != null) {
      return template.fullSuggestion;
    }

    // 如果没有找到模板，使用内置逻辑
    return _fallbackSuggestion(problem, metrics);
  }

  /// 回退建议生成逻辑
  String? _fallbackSuggestion(ProblemType problem, SwingMetrics metrics) {
    switch (problem) {
      case ProblemType.earlyShoulder:
        return '保持髋部领先肩部的动作节奏，练习击球时注意力放在髋部转动上。';
      case ProblemType.insufficientWeightShift:
        return '练习击球准备姿势时，将重心放在后脚，启动挥棒时先从前脚开始转移重心。';
      case ProblemType.insufficientSpeed:
        return '加强挥棒速度训练，可以尝试挥重棒练习来增强力量。';
      case ProblemType.angleTooSmall:
        return '尝试增加挥棒轨迹的角度，可以加大从上往下挥动的幅度。';
      case ProblemType.angleTooLarge:
        return '控制挥棒轨迹，保持更平面的挥棒角度，避免过大或过小的角度。';
      case ProblemType.poorCoordination:
        return '放慢挥棒节奏，仔细感受身体的协调转动，注意重心平稳转移。';
    }
  }

  /// 获取积极反馈
  List<String> _getPositiveFeedback(SwingMetrics metrics) {
    final feedbacks = <String>[];

    // 根据各指标给出针对性的表扬
    if (metrics.velocity >= 20) {
      feedbacks.add('挥棒速度非常优秀！继续保持。');
    }

    if (metrics.maxAngle >= 30 && metrics.maxAngle <= 60) {
      feedbacks.add('挥棒角度控制得很好！');
    }

    if (metrics.hipShoulderDelay > 0) {
      feedbacks.add('髋肩时序配合优秀，力量传递很顺畅。');
    }

    if (metrics.transferSmoothness >= 0.8) {
      feedbacks.add('重心转移非常平稳流畅！');
    }

    // 如果没有特别的亮点，给出综合表扬
    if (feedbacks.isEmpty) {
      feedbacks.add('动作表现良好！继续保持当前的挥棒节奏和姿势。');
    }

    return feedbacks;
  }
}
