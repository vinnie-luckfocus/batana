import 'package:flutter/material.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/animations.dart';
import 'dart:math' as math;

/// 进度指示器尺寸枚举
enum ProgressSize {
  small(diameter: 48.0, strokeWidth: 4.0),
  medium(diameter: 64.0, strokeWidth: 6.0),
  large(diameter: 80.0, strokeWidth: 8.0);

  final double diameter;
  final double strokeWidth;

  const ProgressSize({
    required this.diameter,
    required this.strokeWidth,
  });
}

/// 线性进度条高度枚举
enum ProgressHeight {
  standard(height: 4.0, borderRadius: 2.0),
  thick(height: 6.0, borderRadius: 3.0);

  final double height;
  final double borderRadius;

  const ProgressHeight({
    required this.height,
    required this.borderRadius,
  });
}

/// Neumorphic 圆形进度指示器
class NeumorphicCircularProgressIndicator extends StatefulWidget {
  final ProgressSize size;
  final double? value;
  final Color color;

  const NeumorphicCircularProgressIndicator({
    super.key,
    this.size = ProgressSize.medium,
    this.value,
    this.color = AppColors.primary,
  });

  @override
  State<NeumorphicCircularProgressIndicator> createState() =>
      _NeumorphicCircularProgressIndicatorState();
}

class _NeumorphicCircularProgressIndicatorState
    extends State<NeumorphicCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(NeumorphicCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.diameter,
      height: widget.size.diameter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: widget.value ?? _controller.value,
              color: widget.color,
              strokeWidth: widget.size.strokeWidth,
              isIndeterminate: widget.value == null,
              rotation: _controller.value * 2 * math.pi,
            ),
          );
        },
      ),
    );
  }
}

/// 圆形进度条绘制器
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isIndeterminate;
  final double rotation;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.isIndeterminate,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 绘制背景圆环
    final backgroundPaint = Paint()
      ..color = AppColors.surface
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度圆环
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isIndeterminate) {
      // 不确定状态：绘制旋转的弧
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 1.5,
        false,
        progressPaint,
      );

      canvas.restore();
    } else {
      // 确定状态：绘制进度弧
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.color != color;
  }
}

/// Neumorphic 线性进度指示器
class NeumorphicLinearProgressIndicator extends StatefulWidget {
  final ProgressHeight height;
  final double? value;
  final Color color;

  const NeumorphicLinearProgressIndicator({
    super.key,
    this.height = ProgressHeight.standard,
    this.value,
    this.color = AppColors.primary,
  });

  @override
  State<NeumorphicLinearProgressIndicator> createState() =>
      _NeumorphicLinearProgressIndicatorState();
}

class _NeumorphicLinearProgressIndicatorState
    extends State<NeumorphicLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(NeumorphicLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(widget.height.borderRadius),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final progress = widget.value ?? _animation.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius:
                          BorderRadius.circular(widget.height.borderRadius),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
