import 'package:flutter/material.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/design_system/typography.dart';

/// 自定义底部导航栏
///
/// Neumorphic 风格，包含 3 个导航项：主页、历史、设置
class CustomBottomNavBar extends StatelessWidget {
  /// 当前选中的索引
  final int currentIndex;

  /// 点击回调
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.verticalXS,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: '主页',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: '历史',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: '设置',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建导航项
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppSpacing.allXS,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            AppSpacing.verticalSpaceXXS,
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
