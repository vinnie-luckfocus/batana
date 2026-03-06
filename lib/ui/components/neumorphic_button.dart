import 'package:flutter/material.dart';

/// Neumorphic 风格按钮组件
/// 
/// 继承 NeumorphicContainer 的样式，实现按压动画效果
/// 支持 onPressed 回调和自定义样式
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color ?? Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _buildShadows(_isPressed),
        ),
        child: widget.child,
      ),
    );
  }

  /// 构建 Neumorphic 阴影效果
  /// 
  /// 未按压状态：外阴影（下右）+ 内高光（上左）
  /// 按压状态：内阴影效果
  List<BoxShadow> _buildShadows(bool pressed) {
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
