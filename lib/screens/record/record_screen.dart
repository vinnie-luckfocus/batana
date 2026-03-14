import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors.dart';
import '../../design_system/neumorphic_theme.dart';
import '../../providers/record_state.dart';
import 'widgets/camera_preview_widget.dart';
import 'widgets/recording_controls.dart';

/// 录制主界面
///
/// 整合所有录制相关组件：
/// - 全屏相机预览（无黑边）
/// - 顶部状态栏（返回、时长、网格开关）
/// - 底部录制控制按钮
/// - 录制提示文字
///
/// 支持横竖屏切换，Neumorphic 风格按钮
class RecordScreen extends StatelessWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecordState()..initializeCamera(),
      child: const _RecordScreenContent(),
    );
  }
}

/// 录制屏幕内容组件
///
/// 使用 Consumer 监听状态变化，管理 UI 布局
class _RecordScreenContent extends StatelessWidget {
  const _RecordScreenContent();

  @override
  Widget build(BuildContext context) {
    final recordState = context.watch<RecordState>();

    // 监听录制完成状态，自动跳转到分析页面
    if (recordState.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/analysis');
      });
    }

    return Scaffold(
      // 全屏，无 AppBar
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 相机预览（全屏）
          CameraPreviewWidget(
            controller: recordState.cameraController,
            showGrid: recordState.showGrid,
          ),

          // 2. 顶部状态栏（半透明）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context, recordState),
          ),

          // 3. 浮动控制按钮（底部居中）
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: RecordingControls(
              isRecording: recordState.isRecording,
              progress: recordState.recordingProgress.clamp(0.0, 1.0),
              onRecordTap: () => _handleRecordTap(context, recordState),
              onRetakeTap: recordState.reset,
            ),
          ),

          // 4. 底部提示文字
          if (!recordState.isRecording && !recordState.isCompleted)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: _buildHint(),
            ),
        ],
      ),
    );
  }

  /// 构建顶部栏
  ///
  /// 包含：返回按钮（左）、录制时长（中）、网格开关（右）
  Widget _buildTopBar(BuildContext context, RecordState recordState) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 返回按钮
            _NeumorphicIconButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),

            // 录制时长
            _buildDurationDisplay(recordState),

            // 网格开关
            _NeumorphicIconButton(
              icon: recordState.showGrid ? Icons.grid_on : Icons.grid_off,
              onTap: recordState.toggleGrid,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建录制时长显示
  ///
  /// 格式："00:05"，红色录制中指示器
  Widget _buildDurationDisplay(RecordState recordState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 录制指示器（仅在录制中显示）
          if (recordState.isRecording)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),

          // 时长文字
          Text(
            recordState.formattedDuration,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部提示
  ///
  /// 白色文字，半透明背景，圆角矩形
  Widget _buildHint() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          '保持设备稳定，录制 5-10 秒',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 处理录制按钮点击
  ///
  /// 根据当前状态决定开始或停止录制
  void _handleRecordTap(BuildContext context, RecordState recordState) {
    HapticFeedback.mediumImpact();

    if (recordState.isRecording) {
      // 停止录制
      recordState.stopRecording();
    } else if (recordState.isIdle) {
      // 开始录制
      recordState.startRecording();
    }
  }
}

/// Neumorphic 风格图标按钮
///
/// 圆形按钮，带有阴影效果
class _NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NeumorphicIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<_NeumorphicIconButton>
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

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap();
  }

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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.4),
            boxShadow: _isPressed ? _pressedShadows : _normalShadows,
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  /// 正常状态阴影
  List<BoxShadow> get _normalShadows {
    return [
      BoxShadow(
        color: Colors.white.withOpacity(0.15),
        offset: const Offset(-2, -2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(2, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];
  }

  /// 按压状态阴影
  List<BoxShadow> get _pressedShadows {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        offset: const Offset(1, 1),
        blurRadius: 4,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.1),
        offset: const Offset(-1, -1),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ];
  }
}
