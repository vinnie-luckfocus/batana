import 'package:flutter/material.dart';

/// 设计系统间距定义
///
/// 基于 8px 网格系统，确保元素对齐和间距一致
/// 所有间距值都是 4 的倍数，符合设计规范
class AppSpacing {
  AppSpacing._();

  // ============================================================================
  // 基础间距值（基于 8px 网格）
  // ============================================================================

  /// XXS - 极小间距，用于图标与文字之间
  /// 4pt
  static const double xxs = 4.0;

  /// XS - 小间距，用于组件内部元素
  /// 8pt
  static const double xs = 8.0;

  /// S - 中小间距，用于相关元素之间
  /// 12pt
  static const double s = 12.0;

  /// M - 标准间距，默认使用
  /// 16pt
  static const double m = 16.0;

  /// L - 大间距，用于组件之间
  /// 24pt
  static const double l = 24.0;

  /// XL - 超大间距，用于区块之间
  /// 32pt
  static const double xl = 32.0;

  /// XXL - 页面级间距，用于大区块分隔
  /// 48pt
  static const double xxl = 48.0;

  // ============================================================================
  // EdgeInsets 快捷方式 - 常用的内边距组合
  // ============================================================================

  /// 全方向 XXS 内边距
  static const EdgeInsets allXXS = EdgeInsets.all(xxs);

  /// 全方向 XS 内边距
  static const EdgeInsets allXS = EdgeInsets.all(xs);

  /// 全方向 S 内边距
  static const EdgeInsets allS = EdgeInsets.all(s);

  /// 全方向 M 内边距（默认）
  static const EdgeInsets allM = EdgeInsets.all(m);

  /// 全方向 L 内边距
  static const EdgeInsets allL = EdgeInsets.all(l);

  /// 全方向 XL 内边距
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  /// 全方向 XXL 内边距
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  // ============================================================================
  // 水平内边距
  // ============================================================================

  /// 水平 XS 内边距
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);

  /// 水平 S 内边距
  static const EdgeInsets horizontalS = EdgeInsets.symmetric(horizontal: s);

  /// 水平 M 内边距
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(horizontal: m);

  /// 水平 L 内边距
  static const EdgeInsets horizontalL = EdgeInsets.symmetric(horizontal: l);

  /// 水平 XL 内边距
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // ============================================================================
  // 垂直内边距
  // ============================================================================

  /// 垂直 XS 内边距
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);

  /// 垂直 S 内边距
  static const EdgeInsets verticalS = EdgeInsets.symmetric(vertical: s);

  /// 垂直 M 内边距
  static const EdgeInsets verticalM = EdgeInsets.symmetric(vertical: m);

  /// 垂直 L 内边距
  static const EdgeInsets verticalL = EdgeInsets.symmetric(vertical: l);

  /// 垂直 XL 内边距
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // ============================================================================
  // 页面级内边距 - 常用的页面布局内边距
  // ============================================================================

  /// 页面标准内边距（水平 M，垂直 L）
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: m,
    vertical: l,
  );

  /// 页面紧凑内边距（水平 M，垂直 M）
  static const EdgeInsets pageCompact = EdgeInsets.symmetric(
    horizontal: m,
    vertical: m,
  );

  /// 页面宽松内边距（水平 L，垂直 XL）
  static const EdgeInsets pageRelaxed = EdgeInsets.symmetric(
    horizontal: l,
    vertical: xl,
  );

  // ============================================================================
  // 卡片内边距
  // ============================================================================

  /// 卡片标准内边距
  static const EdgeInsets cardPadding = EdgeInsets.all(m);

  /// 卡片紧凑内边距
  static const EdgeInsets cardCompact = EdgeInsets.all(s);

  /// 卡片宽松内边距
  static const EdgeInsets cardRelaxed = EdgeInsets.all(l);

  // ============================================================================
  // SizedBox 快捷方式 - 常用的间距盒子
  // ============================================================================

  /// 垂直 XXS 间距
  static const SizedBox verticalSpaceXXS = SizedBox(height: xxs);

  /// 垂直 XS 间距
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);

  /// 垂直 S 间距
  static const SizedBox verticalSpaceS = SizedBox(height: s);

  /// 垂直 M 间距
  static const SizedBox verticalSpaceM = SizedBox(height: m);

  /// 垂直 L 间距
  static const SizedBox verticalSpaceL = SizedBox(height: l);

  /// 垂直 XL 间距
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  /// 垂直 XXL 间距
  static const SizedBox verticalSpaceXXL = SizedBox(height: xxl);

  /// 水平 XXS 间距
  static const SizedBox horizontalSpaceXXS = SizedBox(width: xxs);

  /// 水平 XS 间距
  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);

  /// 水平 S 间距
  static const SizedBox horizontalSpaceS = SizedBox(width: s);

  /// 水平 M 间距
  static const SizedBox horizontalSpaceM = SizedBox(width: m);

  /// 水平 L 间距
  static const SizedBox horizontalSpaceL = SizedBox(width: l);

  /// 水平 XL 间距
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);

  /// 水平 XXL 间距
  static const SizedBox horizontalSpaceXXL = SizedBox(width: xxl);

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 创建自定义垂直间距
  static SizedBox verticalSpace(double height) => SizedBox(height: height);

  /// 创建自定义水平间距
  static SizedBox horizontalSpace(double width) => SizedBox(width: width);

  /// 创建自定义全方向内边距
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// 创建自定义对称内边距
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// 创建自定义方向内边距
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
}
