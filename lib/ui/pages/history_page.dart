import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 历史记录页面
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟历史数据
    final historyList = _generateMockHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: historyList.isEmpty
          ? _buildEmptyState(context)
          : _buildHistoryList(context, historyList),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无历史记录',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始录制您的第一次挥棒分析',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.videocam),
            label: const Text('开始录制'),
          ),
        ],
      ),
    );
  }

  /// 构建历史列表
  Widget _buildHistoryList(BuildContext context, List<HistoryItem> historyList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final item = historyList[index];
        return _buildHistoryCard(context, item);
      },
    );
  }

  /// 构建历史卡片
  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    final scoreColor = _getScoreColor(item.score);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 跳转到结果页
          context.push('/result', extra: {
            'score': item.score,
            'feedback': item.feedback,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 分数圆圈
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scoreColor.withOpacity(0.1),
                  border: Border.all(
                    color: scoreColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${item.score}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.date,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.feedback,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 箭头
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取分数颜色
  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFFC107);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  /// 生成模拟历史数据
  List<HistoryItem> _generateMockHistory() {
    return [
      HistoryItem(
        id: '1',
        date: '2024-01-15 14:30',
        score: 85,
        feedback: '挥棒动作流畅，击球力度适中。建议保持挥杆速度一致性。',
      ),
      HistoryItem(
        id: '2',
        date: '2024-01-14 10:20',
        score: 78,
        feedback: '整体表现良好，但挥棒角度略有偏差。注意保持身体平衡。',
      ),
      HistoryItem(
        id: '3',
        date: '2024-01-13 16:45',
        score: 92,
        feedback: '出色的挥棒动作！力量和控制力都达到了较高水平。',
      ),
    ];
  }
}

/// 历史记录数据模型
class HistoryItem {
  final String id;
  final String date;
  final int score;
  final String feedback;

  HistoryItem({
    required this.id,
    required this.date,
    required this.score,
    required this.feedback,
  });
}
