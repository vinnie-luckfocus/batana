import 'package:flutter/material.dart';

/// 设计系统圆角定义
///
/// 定义 4 个层级的圆角规范，统一视觉语言
/// 所有圆角值都是 4 的倍数，符合设计规范
class AppRadius {
  AppRadius._();

  // ============================================================================
  // 基础圆角值
  // ============================================================================

  /// Small - 小圆角，用于按钮、标签
  /// 8pt
  static const double small = 8.0;

  /// Medium - 中等圆角，用于卡片、输入框
  /// 12pt
  static const double medium = 12.0;

  /// Large - 大圆角，用于大卡片、弹窗
  /// 16pt
  static const double large = 16.0;

  /// XLarge - 超大圆角，用于特殊容器
  /// 24pt
  static const double xLarge = 24.0;

  // ============================================================================
  // BorderRadius 快捷方式 - 常用的圆角组合
  // ============================================================================

  /// 全方向 Small 圆角
  static const BorderRadius allSmall = BorderRadius.all(
    Radius.circular(small),
  );

  /// 全方向 Medium 圆角（默认）
  static const BorderRadius allMedium = BorderRadius.all(
    Radius.circular(medium),
  );

  /// 全方向 Large 圆角
  static const BorderRadius allLarge = BorderRadius.all(
    Radius.circular(large),
  );

  /// 全方向 XLarge 圆角
  static const BorderRadius allXLarge = BorderRadius.all(
    Radius.circular(xLarge),
  );

  // ============================================================================
  // 顶部圆角 - 用于卡片顶部、弹窗顶部
  // ============================================================================

  /// 顶部 Small 圆角
  static const BorderRadius topSmall = BorderRadius.only(
    topLeft: Radius.circular(small),
    topRight: Radius.circular(small),
  );

  /// 顶部 Medium 圆角
  static const BorderRadius topMedium = BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
  );

  /// 顶部 Large 圆角
  static const BorderRadius topLarge = BorderRadius.only(
    topLeft: Radius.circular(large),
    topRight: Radius.circular(large),
  );

  /// 顶部 XLarge 圆角
  static const BorderRadius topXLarge = BorderRadius.only(
    topLeft: Radius.circular(xLarge),
    topRight: Radius.circular(xLarge),
  );

  // ============================================================================
  // 底部圆角 - 用于卡片底部、弹窗底部
  // ============================================================================

  /// 底部 Small 圆角
  static const BorderRadius bottomSmall = BorderRadius.only(
    bottomLeft: Radius.circular(small),
    bottomRight: Radius.circular(small),
  );

  /// 底部 Medium 圆角
  static const BorderRadius bottomMedium = BorderRadius.only(
    bottomLeft: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );

  /// 底部 Large 圆角
  static const BorderRadius bottomLarge = BorderRadius.only(
    bottomLeft: Radius.circular(large),
    bottomRight: Radius.circular(large),
  );

  /// 底部 XLarge 圆角
  static const BorderRadius bottomXLarge = BorderRadius.only(
    bottomLeft: Radius.circular(xLarge),
    bottomRight: Radius.circular(xLarge),
  );

  // ============================================================================
  // 左侧圆角 - 用于特殊布局
  // ============================================================================

  /// 左侧 Small 圆角
  static const BorderRadius leftSmall = BorderRadius.only(
    topLeft: Radius.circular(small),
    bottomLeft: Radius.circular(small),
  );

  /// 左侧 Medium 圆角
  static const BorderRadius leftMedium = BorderRadius.only(
    topLeft: Radius.circular(medium),
    bottomLeft: Radius.circular(medium),
  );

  /// 左侧 Large 圆角
  static const BorderRadius leftLarge = BorderRadius.only(
    topLeft: Radius.circular(large),
    bottomLeft: Radius.circular(large),
  );

  // ============================================================================
  // 右侧圆角 - 用于特殊布局
  // ============================================================================

  /// 右侧 Small 圆角
  static const BorderRadius rightSmall = BorderRadius.only(
    topRight: Radius.circular(small),
    bottomRight: Radius.circular(small),
  );

  /// 右侧 Medium 圆角
  static const BorderRadius rightMedium = BorderRadius.only(
    topRight: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );

  /// 右侧 Large 圆角
  static const BorderRadius rightLarge = BorderRadius.only(
    topRight: Radius.circular(large),
    bottomRight: Radius.circular(large),
  );

  // ============================================================================
  // 圆形 - 用于头像、图标按钮
  // ============================================================================

  /// 完全圆形（使用极大的圆角值）
  static const BorderRadius circle = BorderRadius.all(
    Radius.circular(9999),
  );

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 创建自定义圆角
  static BorderRadius circular(double radius) {
    return BorderRadius.circular(radius);
  }

  /// 创建自定义方向圆角
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  /// 创建椭圆形圆角
  static BorderRadius elliptical(double x, double y) {
    return BorderRadius.all(Radius.elliptical(x, y));
  }
}
