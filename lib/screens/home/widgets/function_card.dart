import 'package:flutter/material.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/design_system/typography.dart';
import 'package:batana/design_system/radius.dart';

/// 功能入口卡片组件
///
/// 用于主界面展示功能入口，包含图标、标题和描述
/// 使用 Neumorphic 风格阴影效果
class FunctionCard extends StatelessWidget {
  /// 卡片图标
  final IconData icon;

  /// 卡片标题
  final String title;

  /// 卡片描述
  final String description;

  /// 点击回调
  final VoidCallback onTap;

  const FunctionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title - $description',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: AppSpacing.allM,
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
              // 图标区域
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.allSmall,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalSpaceM,
              // 文字区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppTypography.h3),
                    AppSpacing.verticalSpaceXXS,
                    Text(description, style: AppTypography.caption),
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
