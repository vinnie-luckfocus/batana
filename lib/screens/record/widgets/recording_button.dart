import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/colors.dart';

/// 录制按钮组件
///
/// 支持两种状态：
/// - 未录制：红色圆形按钮，中间白色圆点
/// - 录制中：红色方形（圆角），外围有进度环
///
/// 尺寸：72x72
/// 具有 Neumorphic 阴影效果和点击反馈动画
class RecordingButton extends StatefulWidget {
  /// 是否正在录制
  final bool isRecording;

  /// 点击回调
  final VoidCallback onTap;

  /// 录制进度 0.0 - 1.0
  final double progress;

  const RecordingButton({
    Key? key,
    required this.isRecording,
    required this.onTap,
    this.progress = 0.0,
  }) : super(key: key);

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  /// 处理按下
  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  /// 处理释放
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap();
  }

  /// 处理取消
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 72.0,
          height: 72.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            boxShadow: _isPressed ? _pressedShadows : _normalShadows,
          ),
          child: CustomPaint(
            painter: _RecordingButtonPainter(
              isRecording: widget.isRecording,
              progress: widget.progress,
            ),
            size: const Size(72.0, 72.0),
          ),
        ),
      ),
    );
  }

  /// 正常状态阴影（Neumorphic 浮起效果）
  List<BoxShadow> get _normalShadows {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        offset: const Offset(4, 4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.8),
        offset: const Offset(-4, -4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ];
  }

  /// 按压状态阴影（凹陷效果）
  List<BoxShadow> get _pressedShadows {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: const Offset(2, 2),
        blurRadius: 6,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.7),
        offset: const Offset(-2, -2),
        blurRadius: 6,
        spreadRadius: -1,
      ),
    ];
  }
}

/// 录制按钮绘制器
class _RecordingButtonPainter extends CustomPainter {
  final bool isRecording;
  final double progress;

  _RecordingButtonPainter({
    required this.isRecording,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (isRecording) {
      _paintRecordingState(canvas, center, size);
    } else {
      _paintIdleState(canvas, center, size);
    }
  }

  /// 绘制录制中状态（红色方形 + 进度环）
  void _paintRecordingState(Canvas canvas, Offset center, Size size) {
    // 外圈进度环背景
    final ringBackgroundPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, 32.0, ringBackgroundPaint);

    // 进度环
    if (progress > 0) {
      final ringProgressPaint = Paint()
        ..color = AppColors.error
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 32.0),
        -3.14159 / 2, // -90度开始
        2 * 3.14159 * progress,
        false,
        ringProgressPaint,
      );
    }

    // 红色方形（圆角）
    final squareRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 28.0, height: 28.0),
      const Radius.circular(8.0),
    );

    final squarePaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    canvas.drawRRect(squareRect, squarePaint);
  }

  /// 绘制未录制状态（红色圆形 + 白色圆点）
  void _paintIdleState(Canvas canvas, Offset center, Size size) {
    // 红色圆形背景
    final circlePaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 28.0, circlePaint);

    // 白色圆点
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8.0, dotPaint);
  }

  @override
  bool shouldRepaint(_RecordingButtonPainter oldDelegate) {
    return oldDelegate.isRecording != isRecording ||
        oldDelegate.progress != progress;
  }
}
