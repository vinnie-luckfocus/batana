import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as mlkit;
import 'pose_detector.dart';

/// 姿态检测器
///
/// 使用 Google ML Kit Pose Detection 进行实时姿态检测
class PoseDetector {
  PoseDetector({PoseDetectorConfig? config}) : _config = config ?? const PoseDetectorConfig();

  final PoseDetectorConfig _config;
  mlkit.PoseDetector? _poseDetector;
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
      // 配置 ML Kit Pose Detector 选项
      final options = mlkit.PoseDetectorOptions(
        mode: mlkit.PoseDetectionMode.stream,
        model: _config.modelComplexity == 2
            ? mlkit.PoseDetectionModel.accurate
            : mlkit.PoseDetectionModel.base,
      );

      _poseDetector = mlkit.PoseDetector(options: options);

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// 处理图像并检测姿态
  ///
  /// 返回检测到的姿态数据
  Future<PoseDetectionResult> processImage(mlkit.InputImage inputImage) async {
    if (!_isInitialized || _poseDetector == null) {
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

      // 使用 ML Kit 处理图像
      final poses = await _poseDetector!.processImage(inputImage);

      // 检查是否检测到姿态
      if (poses.isEmpty) {
        return const PoseDetectionResult(
          poseData: null,
        );
      }

      // 取第一个检测到的姿态
      final pose = poses.first;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 转换 ML Kit 关键点到应用数据模型
      final poseData = _convertLandmarks(pose.landmarks, timestamp);

      // 存储当前帧数据供下一帧使用
      _previousPoseData = poseData;

      return PoseDetectionResult(poseData: poseData);
    } catch (e) {
      return PoseDetectionResult(error: '姿态检测失败: $e');
    }
  }

  /// 转换 ML Kit 关键点到应用数据模型
  PoseData _convertLandmarks(Map<mlkit.PoseLandmarkType, mlkit.PoseLandmark> landmarks, int timestamp) {
    final List<PoseLandmarkPoint> landmarkPoints = [];
    final List<PoseLandmarkPoint> worldLandmarkPoints = [];

    landmarks.forEach((type, landmark) {
      final poseLandmark = _convertLandmarkType(type);

      if (poseLandmark != null) {
        landmarkPoints.add(
          PoseLandmarkPoint(
            x: landmark.x,
            y: landmark.y,
            z: landmark.z,
            visibility: landmark.likelihood,
            landmark: poseLandmark,
          ),
        );
      }
    });

    return PoseData(
      landmarks: landmarkPoints,
      worldLandmarks: worldLandmarkPoints,
      timestamp: timestamp,
    );
  }

  /// 将 ML Kit 关键点类型转换为应用内类型
  PoseLandmark? _convertLandmarkType(mlkit.PoseLandmarkType type) {
    switch (type) {
      case mlkit.PoseLandmarkType.nose:
        return PoseLandmark.nose;
      case mlkit.PoseLandmarkType.leftEyeInner:
        return PoseLandmark.leftEyeInner;
      case mlkit.PoseLandmarkType.leftEye:
        return PoseLandmark.leftEye;
      case mlkit.PoseLandmarkType.leftEyeOuter:
        return PoseLandmark.leftEyeOuter;
      case mlkit.PoseLandmarkType.rightEyeInner:
        return PoseLandmark.rightEyeInner;
      case mlkit.PoseLandmarkType.rightEye:
        return PoseLandmark.rightEye;
      case mlkit.PoseLandmarkType.rightEyeOuter:
        return PoseLandmark.rightEyeOuter;
      case mlkit.PoseLandmarkType.leftEar:
        return PoseLandmark.leftEar;
      case mlkit.PoseLandmarkType.rightEar:
        return PoseLandmark.rightEar;
      case mlkit.PoseLandmarkType.leftMouth:
        return PoseLandmark.leftMouth;
      case mlkit.PoseLandmarkType.rightMouth:
        return PoseLandmark.rightMouth;
      case mlkit.PoseLandmarkType.leftShoulder:
        return PoseLandmark.leftShoulder;
      case mlkit.PoseLandmarkType.rightShoulder:
        return PoseLandmark.rightShoulder;
      case mlkit.PoseLandmarkType.leftElbow:
        return PoseLandmark.leftElbow;
      case mlkit.PoseLandmarkType.rightElbow:
        return PoseLandmark.rightElbow;
      case mlkit.PoseLandmarkType.leftWrist:
        return PoseLandmark.leftWrist;
      case mlkit.PoseLandmarkType.rightWrist:
        return PoseLandmark.rightWrist;
      case mlkit.PoseLandmarkType.leftPinky:
        return PoseLandmark.leftPinky;
      case mlkit.PoseLandmarkType.rightPinky:
        return PoseLandmark.rightPinky;
      case mlkit.PoseLandmarkType.leftIndex:
        return PoseLandmark.leftIndex;
      case mlkit.PoseLandmarkType.rightIndex:
        return PoseLandmark.rightIndex;
      case mlkit.PoseLandmarkType.leftThumb:
        return PoseLandmark.leftThumb;
      case mlkit.PoseLandmarkType.rightThumb:
        return PoseLandmark.rightThumb;
      case mlkit.PoseLandmarkType.leftHip:
        return PoseLandmark.leftHip;
      case mlkit.PoseLandmarkType.rightHip:
        return PoseLandmark.rightHip;
      case mlkit.PoseLandmarkType.leftKnee:
        return PoseLandmark.leftKnee;
      case mlkit.PoseLandmarkType.rightKnee:
        return PoseLandmark.rightKnee;
      case mlkit.PoseLandmarkType.leftAnkle:
        return PoseLandmark.leftAnkle;
      case mlkit.PoseLandmarkType.rightAnkle:
        return PoseLandmark.rightAnkle;
      case mlkit.PoseLandmarkType.leftHeel:
        return PoseLandmark.leftHeel;
      case mlkit.PoseLandmarkType.rightHeel:
        return PoseLandmark.rightHeel;
      case mlkit.PoseLandmarkType.leftFootIndex:
        return PoseLandmark.leftFootIndex;
      case mlkit.PoseLandmarkType.rightFootIndex:
        return PoseLandmark.rightFootIndex;
      default:
        return null;
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    if (_poseDetector != null) {
      await _poseDetector!.close();
      _poseDetector = null;
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
  StreamSubscription<mlkit.InputImage>? _imageStreamSubscription;

  /// 是否正在运行
  bool get isRunning => _isRunning;

  /// 初始化
  Future<void> initialize() async {
    await _detector.initialize();
  }

  /// 开始处理图像流
  Future<void> startProcessing(Stream<mlkit.InputImage> imageStream) async {
    if (_isRunning) return;

    _isRunning = true;

    await _detector.initialize();

    _imageStreamSubscription = imageStream.listen(
      (inputImage) async {
        try {
          final result = await _detector.processImage(inputImage);
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
