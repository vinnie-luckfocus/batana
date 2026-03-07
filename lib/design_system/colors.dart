import 'package:flutter/material.dart';

/// 设计系统色彩定义
///
/// 遵循 60-30-10 原则：
/// - 主色调 60%：专业、可信赖的深邃蓝
/// - 辅助色 30%：温暖、舒适的灰色系
/// - 强调色 10%：活力、引导的橙色系
class AppColors {
  AppColors._();

  // ============================================================================
  // 主色调（60%）- 专业感与可信赖
  // ============================================================================

  /// 主色 - 深邃蓝，传达专业与可信赖
  static const Color primary = Color(0xFF1E88E5);

  /// 主色浅色 - 用于悬停状态和辅助元素
  static const Color primaryLight = Color(0xFF64B5F6);

  /// 主色深色 - 用于强调和按压状态
  static const Color primaryDark = Color(0xFF1565C0);

  // ============================================================================
  // 辅助色（30%）- 温暖舒适的背景
  // ============================================================================

  /// 表面色 - 卡片、组件背景
  static const Color surface = Color(0xFFECEFF1);

  /// 背景色 - 页面主背景
  static const Color background = Color(0xFFF5F7FA);

  /// 分割线色
  static const Color divider = Color(0xFFCFD8DC);

  // ============================================================================
  // 强调色（10%）- 活力与引导
  // ============================================================================

  /// 强调色 - 活力橙，用于 CTA 按钮和重要操作（WCAG AA 3:1 with white）
  static const Color accent = Color(0xFFE65100);

  /// 成功色 - 绿色，表示成功状态
  static const Color success = Color(0xFF43A047);

  /// 警告色 - 橙色，表示警告状态
  static const Color warning = Color(0xFFFFA726);

  /// 错误色 - 红色，表示错误状态
  static const Color error = Color(0xFFE53935);

  // ============================================================================
  // 文字色 - 清晰的层次结构
  // ============================================================================

  /// 主要文字色 - 87% 不透明度，用于标题和重要内容
  static const Color textPrimary = Color(0xFF212121);

  /// 次要文字色 - 用于辅助说明（WCAG AA 4.5:1 on background）
  static const Color textSecondary = Color(0xFF6D6D6D);

  /// 禁用文字色 - 38% 不透明度，用于禁用状态
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ============================================================================
  // Neumorphic 阴影色
  // ============================================================================

  /// 浅色阴影 - 用于 Neumorphic 效果的高光
  static const Color lightShadow = Color(0x1AFFFFFF);

  /// 深色阴影 - 用于 Neumorphic 效果的阴影
  static const Color darkShadow = Color(0x33000000);

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 根据背景色获取合适的文字颜色
  static Color getTextColorForBackground(Color backgroundColor) {
    // 计算亮度
    final luminance = backgroundColor.computeLuminance();
    // 亮度 > 0.5 使用深色文字，否则使用浅色文字
    return luminance > 0.5 ? textPrimary : Colors.white;
  }

  /// 获取颜色的半透明版本
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
