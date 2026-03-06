import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:mediapipe_pose/mediapipe_pose.dart';
import 'pose_detector.dart';

/// 姿态检测器
///
/// 使用 MediaPipe Pose 进行实时姿态检测
class PoseDetector {
  PoseDetector({PoseDetectorConfig? config}) : _config = config ?? const PoseDetectorConfig();

  final PoseDetectorConfig _config;
  Pose? _pose;
  bool _isInitialized = false;
  int _frameCount = 0;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 帧采样间隔 (每 N 帧处理一次)
  final int frameSamplingInterval = 2;

  /// 上一帧的姿态数据 (用于平滑)
  PoseData? _previousPoseData;

  /// 初始化姿态检测器
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _pose = Pose(
        poseDetectorOptions: PoseDetectorOptions(
          modelComplexity: _config.modelComplexity,
          smoothLandmarks: _config.smoothLandmarks,
          enableSegmentation: _config.enableSegmentation,
          smoothSegmentation: _config.smoothSegmentation,
          minDetectionConfidence: _config.minDetectionConfidence,
          minTrackingConfidence: _config.minTrackingConfidence,
        ),
      );

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// 处理图像并检测姿态
  ///
  /// 返回检测到的姿态数据
  Future<PoseDetectionResult> processImage(Uint8List imageBytes) async {
    if (!_isInitialized || _pose == null) {
      return const PoseDetectionResult(
        error: '姿态检测器未初始化',
      );
    }

    try {
      // 帧采样: 跳过部分帧以优化性能
      _frameCount++;
      if (_frameCount % frameSamplingInterval != 0) {
        // 返回上一帧的数据或空结果
        return PoseDetectionResult(
          poseData: _previousPoseData,
        );
      }

      // 使用 MediaPipe 处理图像
      final result = await _pose!.processImage(imageBytes);

      // 检查是否检测到姿态
      if (result.poseLandmarks == null || result.poseLandmarks!.isEmpty) {
        return const PoseDetectionResult(
          poseData: null,
        );
      }

      // 转换 MediaPipe 关键点到应用数据模型
      final poseData = _convertLandmarks(result.poseLandmarks!, result.timestamp ?? 0);

      // 存储当前帧数据供下一帧使用
      _previousPoseData = poseData;

      return PoseDetectionResult(poseData: poseData);
    } catch (e) {
      return PoseDetectionResult(error: '姿态检测失败: $e');
    }
  }

  /// 处理相机图像 (CameraImage)
  Future<PoseDetectionResult> processCameraImage(dynamic cameraImage) async {
    try {
      // 将 CameraImage 转换为 MediaPipe 输入格式
      final imageBytes = _convertCameraImageToBytes(cameraImage);
      if (imageBytes == null) {
        return const PoseDetectionResult(
          error: '无法转换相机图像',
        );
      }

      return await processImage(imageBytes);
    } catch (e) {
      return PoseDetectionResult(error: '处理相机图像失败: $e');
    }
  }

  /// 将 CameraImage 转换为字节数据
  Uint8List? _convertCameraImageToBytes(dynamic cameraImage) {
    try {
      // 假设 cameraImage 是 camera 包中的 CameraImage
      // 需要根据实际相机图像格式进行转换

      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        // YUV420 格式转换
        return _convertYuv420ToRgb(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.jpeg) {
        // JPEG 格式直接使用
        return cameraImage.planes[0].bytes;
      }

      return null;
    } catch (e) {
      debugPrint('转换相机图像失败: $e');
      return null;
    }
  }

  /// YUV420 转 RGB (简化版)
  Uint8List? _convertYuv420ToRgb(dynamic cameraImage) {
    try {
      // 这里需要根据实际的 CameraImage 实现进行转换
      // 简化处理: 实际项目中需要使用 image 包进行转换

      // 返回原始数据作为占位符
      // 实际实现需要将 YUV 转换为 RGB 字节
      return cameraImage.planes[0].bytes;
    } catch (e) {
      debugPrint('YUV420 转换失败: $e');
      return null;
    }
  }

  /// 转换 MediaPipe 关键点到应用数据模型
  PoseData _convertLandmarks(List<NormalizedLandmark> landmarks, int timestamp) {
    final List<PoseLandmarkPoint> landmarkPoints = [];
    final List<PoseLandmarkPoint> worldLandmarkPoints = [];

    for (int i = 0; i < landmarks.length; i++) {
      final landmark = landmarks[i];
      final poseLandmark = PoseLandmark.fromIndex(i);

      if (poseLandmark != null) {
        landmarkPoints.add(
          PoseLandmarkPoint(
            x: landmark.x,
            y: landmark.y,
            z: landmark.z,
            visibility: landmark.visibility ?? 0.0,
            landmark: poseLandmark,
          ),
        );
      }
    }

    // 如果有世界坐标数据也进行转换
    // 注意: worldLandmarks 需要单独请求

    return PoseData(
      landmarks: landmarkPoints,
      worldLandmarks: worldLandmarkPoints,
      timestamp: timestamp,
    );
  }

  /// 释放资源
  Future<void> dispose() async {
    if (_pose != null) {
      _pose!.close();
      _pose = null;
    }
    _isInitialized = false;
    _previousPoseData = null;
  }
}

/// 实时姿态处理器
///
/// 用于连续帧的实时姿态检测
class RealtimePoseProcessor {
  RealtimePoseProcessor({
    PoseDetectorConfig? config,
    this.onPoseDetected,
    this.onError,
  }) : _detector = PoseDetector(config: config);

  final PoseDetector _detector;

  /// 姿态检测回调
  final void Function(PoseData)? onPoseDetected;

  /// 错误回调
  final void Function(String)? onError;

  bool _isRunning = false;
  StreamSubscription? _imageStreamSubscription;

  /// 是否正在运行
  bool get isRunning => _isRunning;

  /// 初始化
  Future<void> initialize() async {
    await _detector.initialize();
  }

  /// 开始处理图像流
  Future<void> startProcessing(Stream<Uint8List> imageStream) async {
    if (_isRunning) return;

    _isRunning = true;

    await _detector.initialize();

    _imageStreamSubscription = imageStream.listen(
      (imageBytes) async {
        try {
          final result = await _detector.processImage(imageBytes);
          if (result.isSuccess && result.poseData != null) {
            onPoseDetected?.call(result.poseData!);
          } else if (result.error != null) {
            onError?.call(result.error!);
          }
        } catch (e) {
          onError?.call('处理图像失败: $e');
        }
      },
      onError: (e) {
        onError?.call('图像流错误: $e');
      },
    );
  }

  /// 停止处理
  Future<void> stopProcessing() async {
    _isRunning = false;
    await _imageStreamSubscription?.cancel();
    _imageStreamSubscription = null;
  }

  /// 释放资源
  Future<void> dispose() async {
    await stopProcessing();
    await _detector.dispose();
  }
}
