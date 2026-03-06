import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../scoring/problem_detector.dart';

/// 结果页面 - 显示分析结果
class ResultPage extends StatelessWidget {
  final int score;
  final double velocity;
  final double angle;
  final double coordination;
  final List<String> suggestions;

  const ResultPage({
    super.key,
    required this.score,
    required this.velocity,
    required this.angle,
    required this.coordination,
    required this.suggestions,
  });

  /// 从 ScoringResult 构造
  factory ResultPage.fromScoringResult(ScoringResult result) {
    return ResultPage(
      score: result.totalScore,
      velocity: 0, // 需要从 SwingMetrics 获取
      angle: 0, // 需要从 SwingMetrics 获取
      coordination: result.coordinationScore,
      suggestions: result.suggestions,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 根据分数获取评级
    final rating = _getRating(score);
    final ratingColor = _getRatingColor(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分析结果'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 分数卡片
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 进度环显示分数
                        _buildScoreRing(score, ratingColor),
                        const SizedBox(height: 16),
                        // 评级文字
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ratingColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rating,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ratingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 三个核心指标卡片
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '核心指标',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 速度指标
                        _buildMetricRow(
                          context,
                          '速度',
                          '${velocity.toStringAsFixed(1)} m/s',
                          '参考值: 10-30 m/s',
                          _getVelocityColor(velocity),
                        ),
                        const SizedBox(height: 12),
                        // 角度指标
                        _buildMetricRow(
                          context,
                          '角度',
                          '${angle.toStringAsFixed(0)}°',
                          '参考值: 30-60°',
                          _getAngleColor(angle),
                        ),
                        const SizedBox(height: 12),
                        // 协调性指标
                        _buildMetricRow(
                          context,
                          '协调性',
                          _getCoordinationText(coordination),
                          '参考值: 良好',
                          _getCoordinationColor(coordination),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 建议卡片
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '改进建议',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: suggestions.isEmpty
                              ? Center(
                                  child: Text(
                                    '动作表现优秀！继续保持。',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: suggestions.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.only(top: 8, right: 8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              suggestions[index],
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/history'),
                      icon: const Icon(Icons.history),
                      label: const Text('历史记录'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.replay),
                      label: const Text('再次录制'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建进度环分数显示
  Widget _buildScoreRing(int score, Color color) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade200),
            ),
          ),
          // 进度圆环
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: score / 100.0,
              strokeWidth: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // 分数文字
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '分',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建指标行
  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    String reference,
    Color color,
  ) {
    return Row(
      children: [
        // 标签
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ),
        // 值
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ),
        // 参考值
        Text(
          reference,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
        ),
      ],
    );
  }

  /// 获取评级文字
  String _getRating(int score) {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '中等';
    if (score >= 60) return '及格';
    return '需改进';
  }

  /// 获取评级颜色
  Color _getRatingColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFFC107);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  /// 获取速度颜色
  Color _getVelocityColor(double velocity) {
    if (velocity >= 20) return const Color(0xFF4CAF50);
    if (velocity >= 15) return const Color(0xFF8BC34A);
    if (velocity >= 10) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  /// 获取角度颜色
  Color _getAngleColor(double angle) {
    if (angle >= 30 && angle <= 60) return const Color(0xFF4CAF50);
    if (angle >= 20 || angle <= 70) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  /// 获取协调性文字
  String _getCoordinationText(double coordination) {
    if (coordination >= 80) return '优秀';
    if (coordination >= 60) return '良好';
    if (coordination >= 40) return '一般';
    return '需改进';
  }

  /// 获取协调性颜色
  Color _getCoordinationColor(double coordination) {
    if (coordination >= 80) return const Color(0xFF4CAF50);
    if (coordination >= 60) return const Color(0xFF8BC34A);
    if (coordination >= 40) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}
