import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as camera;
import '../analysis/pose_detector.dart';
import '../ui/widgets/pose_painter.dart';

/// 摄像头预览组件
///
/// 提供实时摄像头预览功能，支持前后摄像头切换和姿态叠加
class CameraPreview extends StatefulWidget {
  /// 摄像头控制器
  final camera.CameraController? controller;

  /// 摄像头切换回调
  final VoidCallback? onSwitchCamera;

  /// 是否显示切换摄像头按钮
  final bool showSwitchButton;

  /// 姿态数据 (用于叠加显示)
  final PoseData? poseData;

  /// 是否显示姿态关键点
  final bool showPoseLandmarks;

  /// 是否显示姿态骨架
  final bool showPoseSkeleton;

  const CameraPreview({
    super.key,
    this.controller,
    this.onSwitchCamera,
    this.showSwitchButton = true,
    this.poseData,
    this.showPoseLandmarks = true,
    this.showPoseSkeleton = true,
  });

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return _buildPlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 摄像头预览
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: camera.CameraPreview(widget.controller!),
        ),

        // 姿态叠加层
        if (widget.poseData != null)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PoseOverlay(
                poseData: widget.poseData,
                showLandmarks: widget.showPoseLandmarks,
                showSkeleton: widget.showPoseSkeleton,
              ),
            ),
          ),

        // 切换摄像头按钮
        if (widget.showSwitchButton)
          Positioned(
            top: 16,
            right: 16,
            child: _buildSwitchButton(),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '摄像头初始化中...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchButton() {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: widget.onSwitchCamera,
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.flip_camera_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// 摄像头管理器
///
/// 负责摄像头的初始化、切换和控制
class CameraManager {
  List<camera.CameraDescription> _cameras = [];
  camera.CameraController? _controller;
  int _currentCameraIndex = 0;
  bool _isInitialized = false;

  /// 当前摄像头控制器
  camera.CameraController? get controller => _controller;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 是否有多个摄像头
  bool get hasMultipleCameras => _cameras.length > 1;

  /// 初始化摄像头
  Future<void> initialize() async {
    try {
      _cameras = await camera.availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('未检测到可用摄像头');
      }

      // 默认使用后置摄像头
      _currentCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == camera.CameraLensDirection.back,
      );
      if (_currentCameraIndex < 0) _currentCameraIndex = 0;

      await _initializeController();
    } catch (e) {
      rethrow;
    }
  }

  /// 初始化控制器
  Future<void> _initializeController() async {
    if (_cameras.isEmpty) return;

    // 释放旧控制器
    await disposeController();

    _controller = camera.CameraController(
      _cameras[_currentCameraIndex],
      camera.ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  /// 切换摄像头
  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initializeController();
  }

  /// 释放控制器
  Future<void> disposeController() async {
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        await _controller!.dispose();
      }
      _controller = null;
      _isInitialized = false;
    }
  }

  /// 释放所有资源
  Future<void> dispose() async {
    await disposeController();
  }
}
