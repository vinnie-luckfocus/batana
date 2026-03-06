import 'package:flutter/material.dart';
import 'colors.dart';

/// 设计系统字体定义
///
/// 定义 9 个层级的文字样式，确保清晰的视觉层次：
/// - Display/H1/H2/H3: 标题层级
/// - Body Large/Body/Body Small: 正文层级
/// - Caption/Overline: 辅助层级
class AppTypography {
  AppTypography._();

  // ============================================================================
  // 标题层级 - 用于页面标题和重要信息
  // ============================================================================

  /// Display - 超大标题，用于启动页、空状态等
  /// 32pt / Bold / 1.2 行高
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// H1 - 一级标题，用于页面主标题
  /// 24pt / Bold / 1.3 行高
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// H2 - 二级标题，用于区块标题
  /// 20pt / SemiBold / 1.4 行高
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// H3 - 三级标题，用于卡片标题
  /// 18pt / Medium / 1.4 行高
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  // ============================================================================
  // 正文层级 - 用于主要内容
  // ============================================================================

  /// Body Large - 大号正文，用于重要说明
  /// 16pt / Regular / 1.5 行高
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  /// Body - 标准正文，用于主要内容
  /// 14pt / Regular / 1.5 行高
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
  );

  /// Body Small - 小号正文，用于次要内容
  /// 12pt / Regular / 1.5 行高
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  // ============================================================================
  // 辅助层级 - 用于标签、提示等
  // ============================================================================

  /// Caption - 说明文字，用于图片说明、时间戳等
  /// 12pt / Regular / 1.4 行高
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  /// Overline - 上标文字，用于分类标签（全大写）
  /// 10pt / Medium / 1.4 行高
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // ============================================================================
  // 按钮文字样式
  // ============================================================================

  /// 大按钮文字
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// 中等按钮文字
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// 小按钮文字
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 创建自定义颜色的文字样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 创建自定义字重的文字样式
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// 创建自定义大小的文字样式
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
