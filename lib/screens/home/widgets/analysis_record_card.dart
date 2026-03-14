import 'package:flutter/material.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/design_system/typography.dart';
import 'package:batana/design_system/radius.dart';
import 'package:batana/storage/storage.dart';

/// 分析记录卡片组件
///
/// 显示单次分析记录的概要信息，包括日期、分数和挥棒速度
/// 使用 Neumorphic 风格阴影效果
class AnalysisRecordCard extends StatelessWidget {
  /// 分析记录数据
  final AnalysisRecord record;

  /// 点击回调
  final VoidCallback onTap;

  const AnalysisRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  /// 根据分数获取对应的颜色
  Color _getScoreColor(int score) {
    if (score >= 80) {
      return AppColors.success;
    } else if (score >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  /// 格式化日期显示
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(record.score);

    return Semantics(
      label: '分析记录: 分数${record.score}分, 挥棒速度${record.velocity.toStringAsFixed(1)}米/秒',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.allMedium,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // 分数圆形指示器
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.15),
                  borderRadius: AppRadius.allMedium,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${record.score}',
                        style: AppTypography.h2.copyWith(
                          color: scoreColor,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '分',
                        style: AppTypography.caption.copyWith(
                          color: scoreColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceM,
              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 日期
                    Text(
                      _formatDate(record.createdAt),
                      style: AppTypography.caption,
                    ),
                    AppSpacing.verticalSpaceXXS,
                    // 挥棒速度
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        AppSpacing.horizontalSpaceXXS,
                        Text(
                          '挥棒速度: ${record.velocity.toStringAsFixed(1)} m/s',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 箭头指示
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
