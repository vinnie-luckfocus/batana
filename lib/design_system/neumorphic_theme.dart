import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'colors.dart';
import 'radius.dart';

/// Neumorphic 主题配置
///
/// 配置 Neumorphic 设计风格的阴影、深度、曲率等参数
/// 营造柔和、立体的视觉效果
class AppNeumorphicTheme {
  AppNeumorphicTheme._();

  // ============================================================================
  // 阴影配置 - 模拟真实光照效果
  // ============================================================================

  /// 浅色阴影 - 模拟高光
  /// 颜色: 白色半透明，偏移: (-4, -4)，模糊: 8
  static const LightSource lightSource = LightSource.topLeft;

  /// 阴影强度
  static const double shadowIntensity = 0.15;

  /// 高光强度
  static const double lightIntensity = 0.7;

  // ============================================================================
  // 深度级别 - 控制元素的浮起/凹陷程度
  // ============================================================================

  /// Depth 1 - 浅浮起，用于按钮默认状态
  static const double depth1 = 4.0;

  /// Depth 2 - 中等浮起，用于卡片
  static const double depth2 = 8.0;

  /// Depth 3 - 深度浮起，用于弹窗
  static const double depth3 = 12.0;

  /// Depth -1 - 凹陷，用于输入框、开关
  static const double depthInset = -4.0;

  // ============================================================================
  // 曲率配置 - 控制表面的凹凸程度
  // ============================================================================

  /// Flat - 完全平面，无凹凸
  static const double flat = 0.0;

  /// Concave - 轻微凹陷
  static const double concave = 0.5;

  /// Convex - 轻微凸起
  static const double convex = 1.0;

  // ============================================================================
  // 主题数据 - 完整的 Neumorphic 主题配置
  // ============================================================================

  /// 亮色主题
  static NeumorphicThemeData lightTheme = NeumorphicThemeData(
    baseColor: AppColors.background,
    accentColor: AppColors.primary,
    lightSource: lightSource,
    depth: depth2,
    intensity: shadowIntensity,

    // 按钮样式
    buttonStyle: NeumorphicStyle(
      depth: depth1,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(AppRadius.allSmall),
      lightSource: lightSource,
    ),

    // 图标主题
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // 文字主题
    textTheme: TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary),
      displayMedium: TextStyle(color: AppColors.textPrimary),
      displaySmall: TextStyle(color: AppColors.textPrimary),
      headlineMedium: TextStyle(color: AppColors.textPrimary),
      headlineSmall: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(color: AppColors.textPrimary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),
  );

  /// 暗色主题（预留，暂不实现）
  static NeumorphicThemeData darkTheme = NeumorphicThemeData(
    baseColor: Color(0xFF2C2C2C),
    accentColor: AppColors.primary,
    lightSource: lightSource,
    depth: depth2,
    intensity: shadowIntensity,
  );

  // ============================================================================
  // 预设样式 - 常用的 Neumorphic 样式组合
  // ============================================================================

  /// 按钮样式 - 浅浮起
  static NeumorphicStyle buttonStyle({
    Color? color,
    double? depth,
    NeumorphicShape shape = NeumorphicShape.flat,
  }) {
    return NeumorphicStyle(
      depth: depth ?? depth1,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: shape,
      boxShape: NeumorphicBoxShape.roundRect(AppRadius.allSmall),
      lightSource: lightSource,
      color: color,
    );
  }

  /// 卡片样式 - 中等浮起
  static NeumorphicStyle cardStyle({
    Color? color,
    double? depth,
  }) {
    return NeumorphicStyle(
      depth: depth ?? depth2,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(AppRadius.allMedium),
      lightSource: lightSource,
      color: color,
    );
  }

  /// 输入框样式 - 凹陷
  static NeumorphicStyle inputStyle({
    Color? color,
  }) {
    return NeumorphicStyle(
      depth: depthInset,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.concave,
      boxShape: NeumorphicBoxShape.roundRect(AppRadius.allMedium),
      lightSource: lightSource,
      color: color ?? AppColors.surface,
    );
  }

  /// 开关样式 - 凹陷轨道
  static NeumorphicStyle switchStyle({
    Color? color,
  }) {
    return NeumorphicStyle(
      depth: depthInset,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.concave,
      boxShape: NeumorphicBoxShape.stadium(),
      lightSource: lightSource,
      color: color ?? AppColors.surface,
    );
  }

  /// 进度条样式 - 凹陷轨道
  static NeumorphicStyle progressStyle({
    Color? color,
  }) {
    return NeumorphicStyle(
      depth: depthInset,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.concave,
      boxShape: NeumorphicBoxShape.roundRect(
        BorderRadius.circular(AppRadius.small / 2),
      ),
      lightSource: lightSource,
      color: color ?? AppColors.surface,
    );
  }

  /// 弹窗样式 - 深度浮起
  static NeumorphicStyle dialogStyle({
    Color? color,
  }) {
    return NeumorphicStyle(
      depth: depth3,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(AppRadius.allLarge),
      lightSource: lightSource,
      color: color ?? AppColors.background,
    );
  }

  /// 图标按钮样式 - 圆形浅浮起
  static NeumorphicStyle iconButtonStyle({
    Color? color,
    double? depth,
  }) {
    return NeumorphicStyle(
      depth: depth ?? depth1,
      intensity: shadowIntensity,
      surfaceIntensity: lightIntensity,
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.circle(),
      lightSource: lightSource,
      color: color,
    );
  }

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 创建自定义 Neumorphic 样式
  static NeumorphicStyle customStyle({
    required double depth,
    required NeumorphicShape shape,
    required NeumorphicBoxShape boxShape,
    Color? color,
    double? intensity,
    double? surfaceIntensity,
  }) {
    return NeumorphicStyle(
      depth: depth,
      intensity: intensity ?? shadowIntensity,
      surfaceIntensity: surfaceIntensity ?? lightIntensity,
      shape: shape,
      boxShape: boxShape,
      lightSource: lightSource,
      color: color,
    );
  }

  /// 获取按压状态的深度（反转深度）
  static double getPressedDepth(double normalDepth) {
    return -normalDepth.abs() / 2;
  }

  /// 获取悬停状态的深度（增加 20%）
  static double getHoverDepth(double normalDepth) {
    return normalDepth * 1.2;
  }
}
