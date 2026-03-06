import 'package:flutter/material.dart';

/// Neumorphic 风格容器组件
/// 
/// 提供新拟态设计风格的容器，支持自定义宽高、圆角、颜色
/// 实现 Neumorphic 阴影效果（外阴影 + 内高光）
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final bool isPressed;
  final List<BoxShadow>? customShadows;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color,
    this.isPressed = false,
    this.customShadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? Colors.white;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: customShadows ?? _buildShadows(bgColor, isPressed),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }

  /// 构建 Neumorphic 阴影效果
  /// 
  /// 未按压状态：外阴影（下右）+ 内高光（上左）
  /// 按压状态：内阴影效果
  List<BoxShadow> _buildShadows(Color color, bool pressed) {
    if (pressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];
    }

    return [
      // 外阴影（下右）
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        offset: const Offset(6, 6),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      // 内高光（上左）
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: const Offset(-6, -6),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
}
