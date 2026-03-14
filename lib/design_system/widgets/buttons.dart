import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors.dart';
import '../radius.dart';

/// 按钮尺寸枚举
enum ButtonSize {
  small,
  medium,
  large,
}

/// 按钮样式枚举
enum NeumorphicButtonStyle {
  filled,
  outlined,
}

/// Neumorphic 按钮组件
///
/// 支持 3 种尺寸、4 种状态、2 种样式
/// 包含按压动画和触觉反馈
class NeumorphicButton extends StatefulWidget {
  /// 按钮子组件
  final Widget child;

  /// 点击回调（null 表示禁用状态）
  final VoidCallback? onPressed;

  /// 按钮尺寸（默认 medium）
  final ButtonSize size;

  /// 按钮样式（默认 filled）
  final NeumorphicButtonStyle style;

  /// 自定义颜色（可选）
  final Color? color;

  /// 自定义宽度（可选）
  final double? width;

  const NeumorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.style = NeumorphicButtonStyle.filled,
    this.color,
    this.width,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 获取按钮高度
  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return 32.0;
      case ButtonSize.medium:
        return 44.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  /// 获取按钮内边距
  EdgeInsets get _padding {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24.0);
    }
  }

  /// 获取按钮颜色
  Color get _buttonColor {
    if (widget.color != null) {
      return widget.color!;
    }
    return widget.style == NeumorphicButtonStyle.filled
        ? AppColors.primary
        : AppColors.surface;
  }

  /// 获取阴影列表（模拟 Neumorphic 效果）
  List<BoxShadow> get _shadows {
    if (widget.onPressed == null) {
      return []; // 禁用状态无阴影
    }
    if (_isPressed) {
      // 按压状态：凹陷效果（内阴影模拟）
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
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
    // 正常状态：浮起效果
    return [
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
    ];
  }

  /// 处理按钮按下
  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  /// 处理按钮释放
  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  /// 处理按钮取消
  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Container(
            width: widget.width,
            height: _height,
            padding: _padding,
            decoration: BoxDecoration(
              color: _buttonColor,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: _shadows,
              border: widget.style == NeumorphicButtonStyle.outlined
                  ? Border.all(
                      color: AppColors.primary,
                      width: 2.0,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.style == NeumorphicButtonStyle.filled
                    ? Colors.white
                    : AppColors.primary,
                fontSize: widget.size == ButtonSize.small ? 14.0 : 16.0,
                fontWeight: FontWeight.w600,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
