import 'package:flutter/material.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/design_system/typography.dart';
import 'package:batana/storage/storage.dart';
import 'analysis_record_card.dart';

/// 最近分析列表区域组件
///
/// 显示最近3次分析记录，从 SQLite 数据库读取数据
/// 支持点击跳转到结果页
class RecentAnalysisSection extends StatefulWidget {
  /// 点击记录回调
  final Function(AnalysisRecord record)? onRecordTap;

  const RecentAnalysisSection({
    super.key,
    this.onRecordTap,
  });

  @override
  State<RecentAnalysisSection> createState() => _RecentAnalysisSectionState();
}

class _RecentAnalysisSectionState extends State<RecentAnalysisSection> {
  final DatabaseManager _databaseManager = DatabaseManager();
  List<AnalysisRecord> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentRecords();
  }

  /// 加载最近分析记录
  Future<void> _loadRecentRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 初始化数据库
      await _databaseManager.initDatabase();

      // 获取最近3条记录
      final records = await _databaseManager.getRecentRecords(limit: 3);

      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 处理记录点击
  void _onRecordTap(AnalysisRecord record) {
    if (widget.onRecordTap != null) {
      widget.onRecordTap!(record);
    } else {
      // 默认导航到结果页
      debugPrint('点击记录: ${record.id}');
      // TODO: 导航到结果页
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => AnalysisResultScreen(record: record),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有记录且不加载中，不显示此区域
    if (!_isLoading && _records.isEmpty && _error == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 区域标题
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近分析',
              style: AppTypography.h2.copyWith(fontSize: 18),
            ),
            if (!_isLoading && _records.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: 导航到历史记录页
                  debugPrint('查看全部历史记录');
                },
                child: Text(
                  '查看全部',
                  style: AppTypography.buttonSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.verticalSpaceM,
        // 内容区域
        _buildContent(),
      ],
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_records.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildRecordList();
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32,
          ),
          AppSpacing.verticalSpaceS,
          Text(
            _error!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceS,
          TextButton(
            onPressed: _loadRecentRecords,
            child: Text(
              '重试',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建记录列表
  Widget _buildRecordList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _records.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _records.length - 1 ? 12.0 : 0,
          ),
          child: AnalysisRecordCard(
            record: record,
            onTap: () => _onRecordTap(record),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _databaseManager.closeDatabase();
    super.dispose();
  }
}
