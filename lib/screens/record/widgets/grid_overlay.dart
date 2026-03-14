import 'package:flutter/material.dart';

/// 九宫格辅助线叠加组件
///
/// 用于相机预览界面的构图辅助，显示九宫格线条
class GridOverlay extends StatelessWidget {
  /// 是否可见
  final bool visible;

  /// 线条颜色
  final Color lineColor;

  /// 线条不透明度
  final double lineOpacity;

  /// 线条宽度
  final double lineWidth;

  const GridOverlay({
    Key? key,
    this.visible = true,
    this.lineColor = Colors.white,
    this.lineOpacity = 0.3,
    this.lineWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridOverlayPainter(
          lineColor: lineColor,
          lineOpacity: lineOpacity,
          lineWidth: lineWidth,
        ),
      ),
    );
  }
}

/// 九宫格辅助线绘制器
class _GridOverlayPainter extends CustomPainter {
  final Color lineColor;
  final double lineOpacity;
  final double lineWidth;

  _GridOverlayPainter({
    required this.lineColor,
    required this.lineOpacity,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(lineOpacity)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 计算九宫格线位置
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    // 绘制垂直线
    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      paint,
    );

    // 绘制水平线
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridOverlayPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.lineOpacity != lineOpacity ||
        oldDelegate.lineWidth != lineWidth;
  }
}
