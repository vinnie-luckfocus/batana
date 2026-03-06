import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart' as camera;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as mlkit;
import '../analysis/pose_detector.dart';
import '../analysis/pose_processor.dart';
import 'camera_preview.dart';

/// 实时姿态检测预览组件
///
/// 集成摄像头预览和姿态检测，实时显示检测结果
class RealtimePoseCameraPreview extends StatefulWidget {
  const RealtimePoseCameraPreview({
    super.key,
    required this.cameraManager,
    this.showSwitchCameraButton = true,
    this.showPoseOverlay = true,
    this.showLandmarks = true,
    this.showSkeleton = true,
    this.onPoseDetected,
    this.onError,
  });

  /// 摄像头管理器
  final CameraManager cameraManager;

  /// 是否显示切换摄像头按钮
  final bool showSwitchCameraButton;

  /// 是否显示姿态叠加层
  final bool showPoseOverlay;

  /// 是否显示关键点
  final bool showLandmarks;

  /// 是否显示骨架
  final bool showSkeleton;

  /// 姿态检测回调
  final void Function(PoseData)? onPoseDetected;

  /// 错误回调
  final void Function(String)? onError;

  @override
  State<RealtimePoseCameraPreview> createState() => _RealtimePoseCameraPreviewState();
}

class _RealtimePoseCameraPreviewState extends State<RealtimePoseCameraPreview> {
  final PoseDetector _poseDetector = PoseDetector();
  PoseData? _currentPoseData;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _initializePoseDetector();
  }

  /// 初始化姿态检测器
  Future<void> _initializePoseDetector() async {
    try {
      await _poseDetector.initialize();
      _startFrameProcessing();
    } catch (e) {
      widget.onError?.call('初始化姿态检测器失败: $e');
    }
  }

  /// 开始处理视频帧
  void _startFrameProcessing() {
    if (widget.cameraManager.controller == null) return;

    // 监听相机图像流
    widget.cameraManager.controller!.startImageStream((cameraImage) async {
      if (_isProcessingFrame) return;

      _isProcessingFrame = true;

      try {
        // 将 CameraImage 转换为 ML Kit InputImage
        final inputImage = _convertCameraImageToInputImage(cameraImage);
        if (inputImage != null) {
          // 处理图像并检测姿态
          final result = await _poseDetector.processImage(inputImage);

          if (result.isSuccess && result.poseData != null) {
            setState(() {
              _currentPoseData = result.poseData;
            });
            widget.onPoseDetected?.call(result.poseData!);
          }
        }
      } catch (e) {
        widget.onError?.call('处理帧失败: $e');
      } finally {
        _isProcessingFrame = false;
      }
    }).catchError((e) {
      widget.onError?.call('图像流错误: $e');
    });
  }

  /// 将 CameraImage 转换为 ML Kit InputImage
  mlkit.InputImage? _convertCameraImageToInputImage(camera.CameraImage cameraImage) {
    try {
      final controller = widget.cameraManager.controller!;
      final cameraDescription = controller.description;

      // 获取图像旋转角度
      final rotation = _getImageRotation(cameraDescription.sensorOrientation);

      // 创建 InputImageMetadata
      final inputImageMetadata = mlkit.InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation,
        format: _getInputImageFormat(cameraImage.format.group),
        bytesPerRow: cameraImage.planes.first.bytesPerRow,
      );

      // 合并所有平面的字节数据
      final bytes = _mergePlanes(cameraImage.planes);

      return mlkit.InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageMetadata,
      );
    } catch (e) {
      debugPrint('转换相机图像失败: $e');
      return null;
    }
  }

  /// 获取图像旋转角度
  mlkit.InputImageRotation _getImageRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return mlkit.InputImageRotation.rotation0deg;
      case 90:
        return mlkit.InputImageRotation.rotation90deg;
      case 180:
        return mlkit.InputImageRotation.rotation180deg;
      case 270:
        return mlkit.InputImageRotation.rotation270deg;
      default:
        return mlkit.InputImageRotation.rotation0deg;
    }
  }

  /// 获取输入图像格式
  mlkit.InputImageFormat _getInputImageFormat(camera.ImageFormatGroup format) {
    switch (format) {
      case camera.ImageFormatGroup.yuv420:
        return mlkit.InputImageFormat.yuv420;
      case camera.ImageFormatGroup.bgra8888:
        return mlkit.InputImageFormat.bgra8888;
      default:
        return mlkit.InputImageFormat.nv21;
    }
  }

  /// 合并图像平面数据
  Uint8List _mergePlanes(List<camera.Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  /// 切换摄像头
  Future<void> _switchCamera() async {
    await widget.cameraManager.switchCamera();

    // 重新启动帧处理
    _startFrameProcessing();
  }

  @override
  void dispose() {
    // 停止图像流
    widget.cameraManager.controller?.stopImageStream().catchError((_) {});
    _poseDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(
      controller: widget.cameraManager.controller,
      onSwitchCamera: _switchCamera,
      showSwitchButton: widget.showSwitchCameraButton,
      poseData: widget.showPoseOverlay ? _currentPoseData : null,
      showPoseLandmarks: widget.showLandmarks,
      showPoseSkeleton: widget.showSkeleton,
    );
  }
}

/// 姿态检测结果小部件
///
/// 显示当前姿态检测状态的组件
class PoseStatusIndicator extends StatelessWidget {
  const PoseStatusIndicator({
    super.key,
    required this.poseData,
    this.showDetails = false,
  });

  /// 姿态数据
  final PoseData? poseData;

  /// 是否显示详细信息
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    if (poseData == null) {
      return _buildNoPoseIndicator();
    }

    if (!poseData!.isValid) {
      return _buildInvalidPoseIndicator();
    }

    return _buildValidPoseIndicator();
  }

  Widget _buildNoPoseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            '未检测到姿态',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidPoseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            '姿态不稳定',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildValidPoseIndicator() {
    final validCount = poseData!.validLandmarks.length;
    final totalCount = poseData!.landmarks.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            showDetails
                ? '检测到 $validCount/$totalCount 关键点'
                : '姿态检测中',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
