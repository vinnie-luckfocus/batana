import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/colors.dart';
import 'recording_button.dart';

/// 录制控制组件
///
/// 布局：
/// - 底部居中
/// - 录制按钮居中（大号 72x72）
/// - 重录按钮在左侧（仅在录制完成后显示）
/// - 对称布局
///
/// 支持点击反馈和动画过渡效果
class RecordingControls extends StatelessWidget {
  /// 是否正在录制
  final bool isRecording;

  /// 录制按钮点击回调
  final VoidCallback onRecordTap;

  /// 重录按钮点击回调
  final VoidCallback onRetakeTap;

  /// 录制进度 0.0 - 1.0
  final double progress;

  const RecordingControls({
    super.key,
    required this.isRecording,
    required this.onRecordTap,
    required this.onRetakeTap,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧：重录按钮（仅在录制完成后显示，且不在录制中时）
          SizedBox(
            width: 56.0,
            height: 56.0,
            child: _buildRetakeButton(),
          ),

          // 中间间距
          const SizedBox(width: 48.0),

          // 中间：录制按钮（大号）
          RecordingButton(
            isRecording: isRecording,
            onTap: onRecordTap,
            progress: progress,
          ),

          // 右侧间距（保持对称）
          const SizedBox(width: 48.0),

          // 右侧：占位（保持对称布局）
          const SizedBox(
            width: 56.0,
            height: 56.0,
          ),
        ],
      ),
    );
  }

  /// 构建重录按钮
  ///
  /// 仅在录制完成后显示（progress == 1.0 且不在录制中）
  Widget _buildRetakeButton() {
    final bool showRetake = !isRecording && progress >= 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: showRetake ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !showRetake,
        child: _RetakeButton(
          onTap: onRetakeTap,
        ),
      ),
    );
  }
}

/// 重录按钮组件
///
/// 圆形图标按钮，带有 Neumorphic 阴影效果
class _RetakeButton extends StatefulWidget {
  final VoidCallback onTap;

  const _RetakeButton({
    required this.onTap,
  });

  @override
  State<_RetakeButton> createState() => _RetakeButtonState();
}

class _RetakeButtonState extends State<_RetakeButton>
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
          duration: const Duration(milliseconds: 150),
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
            boxShadow: _isPressed ? _pressedShadows : _normalShadows,
          ),
          child: const Icon(
            Icons.refresh,
            color: AppColors.textSecondary,
            size: 24.0,
          ),
        ),
      ),
    );
  }

  /// 正常状态阴影（Neumorphic 浮起效果）
  List<BoxShadow> get _normalShadows {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        offset: const Offset(3, 3),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.8),
        offset: const Offset(-3, -3),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  /// 按压状态阴影（凹陷效果）
  List<BoxShadow> get _pressedShadows {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        offset: const Offset(2, 2),
        blurRadius: 5,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.7),
        offset: const Offset(-2, -2),
        blurRadius: 5,
        spreadRadius: -1,
      ),
    ];
  }
}
