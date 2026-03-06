import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../storage/storage.dart';

/// 历史记录页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseManager _dbManager = DatabaseManager();
  List<AnalysisRecord> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 确保数据库已初始化
      if (!_dbManager.isInitialized) {
        await _dbManager.initDatabase();
      }

      // 获取最近 10 条记录
      final records = await _dbManager.getRecentRecords(limit: 10);

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dbManager.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_records.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildHistoryList(context, _records);
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
  Widget _buildHistoryList(BuildContext context, List<AnalysisRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildHistoryCard(context, record);
      },
    );
  }

  /// 构建历史卡片
  Widget _buildHistoryCard(BuildContext context, AnalysisRecord record) {
    final scoreColor = _getScoreColor(record.score);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 跳转到结果页，传递完整数据
          context.push('/result', extra: {
            'score': record.score,
            'velocity': record.velocity,
            'angle': record.angle,
            'coordination': record.coordination,
            'suggestions': record.suggestions,
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
                    '${record.score}',
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
                      record.formattedDate,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    // 简要指标
                    Row(
                      children: [
                        _buildMiniMetric(
                          context,
                          '速度',
                          '${record.velocity.toStringAsFixed(1)} m/s',
                        ),
                        const SizedBox(width: 12),
                        _buildMiniMetric(
                          context,
                          '角度',
                          '${record.angle.toStringAsFixed(0)}°',
                        ),
                        const SizedBox(width: 12),
                        _buildMiniMetric(
                          context,
                          '协调性',
                          _getCoordinationText(record.coordination),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.briefFeedback,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 1,
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

  /// 构建小指标显示
  Widget _buildMiniMetric(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
        ),
        const SizedBox(width: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
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

  /// 获取协调性文字
  String _getCoordinationText(double coordination) {
    if (coordination >= 80) return '优秀';
    if (coordination >= 60) return '良好';
    if (coordination >= 40) return '一般';
    return '需改进';
  }
}
