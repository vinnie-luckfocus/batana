import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// MediaPipe Pose 关键点枚举
///
/// 包含 33 个身体关键点的定义
enum PoseLandmark {
  // 面部关键点 (0-10)
  nose(0, '鼻子', 'nose'),
  leftEyeInner(1, '左眼内', 'left_eye_inner'),
  leftEye(2, '左眼', 'left_eye'),
  leftEyeOuter(3, '左眼外', 'left_eye_outer'),
  rightEyeInner(4, '右眼内', 'right_eye_inner'),
  rightEye(5, '右眼', 'right_eye'),
  rightEyeOuter(6, '右眼外', 'right_eye_outer'),
  leftEar(7, '左耳', 'left_ear'),
  rightEar(8, '右耳', 'right_ear'),
  leftMouth(9, '左嘴角', 'left_mouth'),
  rightMouth(10, '右嘴角', 'right_mouth'),

  // 肩部和手臂关键点 (11-22)
  leftShoulder(11, '左肩', 'left_shoulder'),
  rightShoulder(12, '右肩', 'right_shoulder'),
  leftElbow(13, '左手肘', 'left_elbow'),
  rightElbow(14, '右手肘', 'right_elbow'),
  leftWrist(15, '左手腕', 'left_wrist'),
  rightWrist(16, '右手腕', 'right_wrist'),
  leftPinky(17, '左手小指', 'left_pinky'),
  rightPinky(18, '右手小指', 'right_pinky'),
  leftIndex(19, '左手食指', 'left_index'),
  rightIndex(20, '右手食指', 'right_index'),
  leftThumb(21, '左手拇指', 'left_thumb'),
  rightThumb(22, '右手拇指', 'right_thumb'),

  // 髋部关键点 (23-24)
  leftHip(23, '左髋', 'left_hip'),
  rightHip(24, '右髋', 'right_hip'),

  // 膝盖和脚踝关键点 (25-30)
  leftKnee(25, '左膝盖', 'left_knee'),
  rightKnee(26, '右膝盖', 'right_knee'),
  leftAnkle(27, '左脚踝', 'left_ankle'),
  rightAnkle(28, '右脚踝', 'right_ankle'),
  leftHeel(29, '左脚跟', 'left_heel'),
  rightHeel(30, '右脚跟', 'right_heel'),

  // 脚部关键点 (31-32)
  leftFootIndex(31, '左脚趾', 'left_foot_index'),
  rightFootIndex(32, '右脚趾', 'right_foot_index');

  const PoseLandmark(this.landmarkIndex, this.chineseName, this.englishName);

  /// 关键点索引
  final int landmarkIndex;

  /// 中文名称
  final String chineseName;

  /// 英文名称
  final String englishName;

  /// 根据索引获取关键点
  static PoseLandmark? fromIndex(int index) {
    for (final landmark in PoseLandmark.values) {
      if (landmark.landmarkIndex == index) return landmark;
    }
    return null;
  }

  /// 根据英文名称获取关键点
  static PoseLandmark? fromEnglishName(String name) {
    for (final landmark in PoseLandmark.values) {
      if (landmark.englishName == name) return landmark;
    }
    return null;
  }
}

/// 单个关键点数据
class PoseLandmarkPoint {
  const PoseLandmarkPoint({
    required this.x,
    required this.y,
    required this.z,
    required this.visibility,
    required this.landmark,
  });

  /// X 坐标 (归一化 0-1)
  final double x;

  /// Y 坐标 (归一化 0-1)
  final double y;

  /// Z 坐标 (深度信息)
  final double z;

  /// 可见度/置信度 (0-1)
  final double visibility;

  /// 关键点枚举
  final PoseLandmark landmark;

  /// 关键点是否有效 (置信度 >= 阈值)
  bool get isValid => visibility >= confidenceThreshold;

  /// 置信度阈值
  static const double confidenceThreshold = 0.5;

  /// 转换为屏幕坐标
  Offset toOffset(double width, double height) {
    return Offset(x * width, y * height);
  }

  @override
  String toString() {
    return 'PoseLandmarkPoint(${landmark.chineseName}: x=$x, y=$y, z=$z, visibility=$visibility)';
  }
}

/// 姿态数据
class PoseData {
  const PoseData({
    required this.landmarks,
    required this.worldLandmarks,
    required this.timestamp,
  });

  /// 所有关键点列表
  final List<PoseLandmarkPoint> landmarks;

  /// 世界坐标关键点列表
  final List<PoseLandmarkPoint> worldLandmarks;

  /// 时间戳 (毫秒)
  final int timestamp;

  /// 是否包含有效的姿态数据
  bool get isValid => landmarks.isNotEmpty && hasMinimumLandmarks;

  /// 是否有最少数量的关键点 (至少需要 11 个关键点才能构成基本骨架)
  bool get hasMinimumLandmarks {
    int validCount = 0;
    for (final landmark in landmarks) {
      if (landmark.isValid) validCount++;
    }
    return validCount >= 11;
  }

  /// 获取指定关键点
  PoseLandmarkPoint? getLandmark(PoseLandmark type) {
    for (final landmark in landmarks) {
      if (landmark.landmark == type) return landmark;
    }
    return null;
  }

  /// 获取所有有效关键点
  List<PoseLandmarkPoint> get validLandmarks {
    return landmarks.where((l) => l.isValid).toList();
  }

  /// 获取左右肩膀中心点
  Offset? get shoulderCenter {
    final left = getLandmark(PoseLandmark.leftShoulder);
    final right = getLandmark(PoseLandmark.rightShoulder);
    if (left != null && right != null && left.isValid && right.isValid) {
      return Offset((left.x + right.x) / 2, (left.y + right.y) / 2);
    }
    return null;
  }

  /// 获取左右髋部中心点
  Offset? get hipCenter {
    final left = getLandmark(PoseLandmark.leftHip);
    final right = getLandmark(PoseLandmark.rightHip);
    if (left != null && right != null && left.isValid && right.isValid) {
      return Offset((left.x + right.x) / 2, (left.y + right.y) / 2);
    }
    return null;
  }

  @override
  String toString() {
    return 'PoseData(landmarks: ${landmarks.length}, valid: ${validLandmarks.length}, timestamp: $timestamp)';
  }
}

/// 姿态检测结果
class PoseDetectionResult {
  const PoseDetectionResult({
    this.poseData,
    this.error,
  });

  /// 姿态数据 (如果有)
  final PoseData? poseData;

  /// 错误信息 (如果有)
  final String? error;

  /// 是否成功
  bool get isSuccess => poseData != null && error == null;

  /// 是否失败
  bool get isFailure => !isSuccess;
}

/// 骨骼连接定义
class SkeletonConnection {
  const SkeletonConnection(this.start, this.end, [this.color]);

  /// 起始关键点
  final PoseLandmark start;

  /// 结束关键点
  final PoseLandmark end;

  /// 线条颜色 (可选)
  final int? color;

  /// 默认骨骼连接
  static const List<SkeletonConnection> defaultConnections = [
    // 躯干
    SkeletonConnection(PoseLandmark.leftShoulder, PoseLandmark.rightShoulder),
    SkeletonConnection(PoseLandmark.leftShoulder, PoseLandmark.leftHip),
    SkeletonConnection(PoseLandmark.rightShoulder, PoseLandmark.rightHip),
    SkeletonConnection(PoseLandmark.leftHip, PoseLandmark.rightHip),

    // 左臂
    SkeletonConnection(PoseLandmark.leftShoulder, PoseLandmark.leftElbow),
    SkeletonConnection(PoseLandmark.leftElbow, PoseLandmark.leftWrist),

    // 右臂
    SkeletonConnection(PoseLandmark.rightShoulder, PoseLandmark.rightElbow),
    SkeletonConnection(PoseLandmark.rightElbow, PoseLandmark.rightWrist),

    // 左腿
    SkeletonConnection(PoseLandmark.leftHip, PoseLandmark.leftKnee),
    SkeletonConnection(PoseLandmark.leftKnee, PoseLandmark.leftAnkle),
    SkeletonConnection(PoseLandmark.leftAnkle, PoseLandmark.leftHeel),
    SkeletonConnection(PoseLandmark.leftAnkle, PoseLandmark.leftFootIndex),

    // 右腿
    SkeletonConnection(PoseLandmark.rightHip, PoseLandmark.rightKnee),
    SkeletonConnection(PoseLandmark.rightKnee, PoseLandmark.rightAnkle),
    SkeletonConnection(PoseLandmark.rightAnkle, PoseLandmark.rightHeel),
    SkeletonConnection(PoseLandmark.rightAnkle, PoseLandmark.rightFootIndex),

    // 面部 (鼻子到耳朵)
    SkeletonConnection(PoseLandmark.nose, PoseLandmark.leftEyeInner),
    SkeletonConnection(PoseLandmark.leftEyeInner, PoseLandmark.leftEye),
    SkeletonConnection(PoseLandmark.leftEye, PoseLandmark.leftEyeOuter),
    SkeletonConnection(PoseLandmark.leftEyeOuter, PoseLandmark.leftEar),
    SkeletonConnection(PoseLandmark.nose, PoseLandmark.rightEyeInner),
    SkeletonConnection(PoseLandmark.rightEyeInner, PoseLandmark.rightEye),
    SkeletonConnection(PoseLandmark.rightEye, PoseLandmark.rightEyeOuter),
    SkeletonConnection(PoseLandmark.rightEyeOuter, PoseLandmark.rightEar),
  ];
}

/// 姿态检测器配置
class PoseDetectorConfig {
  const PoseDetectorConfig({
    this.modelComplexity = 1,
    this.smoothLandmarks = true,
    this.enableSegmentation = false,
    this.smoothSegmentation = true,
    this.minDetectionConfidence = 0.5,
    this.minTrackingConfidence = 0.5,
  });

  /// 模型复杂度 (0, 1, 2)
  final int modelComplexity;

  /// 是否平滑关键点
  final bool smoothLandmarks;

  /// 是否启用分割
  final bool enableSegmentation;

  /// 是否平滑分割
  final bool smoothSegmentation;

  /// 最小检测置信度
  final double minDetectionConfidence;

  /// 最小跟踪置信度
  final double minTrackingConfidence;
}
