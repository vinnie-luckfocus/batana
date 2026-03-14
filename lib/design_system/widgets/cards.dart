import 'package:flutter/material.dart';
import '../colors.dart';
import '../radius.dart';
import '../spacing.dart';

/// 卡片内边距枚举
enum CardPadding {
  standard,
  relaxed,
}

/// Neumorphic 卡片组件
///
/// 支持可配置内边距、阴影深度、头部图片
/// 布局：标题 + 内容 + 操作区（垂直排列）
class NeumorphicCard extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 卡片标题（可选）
  final Widget? title;

  /// 头部图片（可选）
  final Widget? headerImage;

  /// 操作按钮列表（可选）
  final List<Widget>? actions;

  /// 内边距类型（默认 standard）
  final CardPadding padding;

  /// 自定义内边距（优先级高于 padding）
  final EdgeInsets? customPadding;

  /// 阴影深度（默认 2.0）
  final double depth;

  /// 圆角半径（默认 12pt）
  final double borderRadius;

  /// 背景色（可选）
  final Color? color;

  /// 自定义宽度（可选）
  final double? width;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.title,
    this.headerImage,
    this.actions,
    this.padding = CardPadding.standard,
    this.customPadding,
    this.depth = 2.0,
    this.borderRadius = 12.0,
    this.color,
    this.width,
  }) : super(key: key);

  /// 获取内边距值
  EdgeInsets get _padding {
    if (customPadding != null) {
      return customPadding!;
    }
    switch (padding) {
      case CardPadding.standard:
        return AppSpacing.allM; // 16pt
      case CardPadding.relaxed:
        return AppSpacing.allL; // 24pt
    }
  }

  /// 获取阴影列表（模拟 Neumorphic 效果）
  List<BoxShadow> get _shadows {
    final shadowOffset = depth * 2;
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        offset: Offset(shadowOffset, shadowOffset),
        blurRadius: shadowOffset * 2,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.7),
        offset: Offset(-shadowOffset, -shadowOffset),
        blurRadius: shadowOffset * 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 头部图片（如果有）
          if (headerImage != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9, // 16:9 比例
                child: headerImage!,
              ),
            ),

          // 内容区域
          Padding(
            padding: _padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题（如果有）
                if (title != null) ...[
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    child: title!,
                  ),
                  AppSpacing.verticalSpaceM,
                ],

                // 主要内容
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  child: child,
                ),

                // 操作区（如果有）
                if (actions != null && actions!.isNotEmpty) ...[
                  AppSpacing.verticalSpaceM,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
