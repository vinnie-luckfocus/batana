import 'package:flutter_test/flutter_test.dart';
import 'package:batana/analysis/pose_detector.dart';

/// PoseProcessor 单元测试
///
/// 测试 ML Kit 适配层的核心转换逻辑
void main() {
  group('PoseLandmark', () {
    test('should have correct landmark indices', () {
      // 验证关键点索引与 ML Kit 定义一致
      expect(PoseLandmark.nose.landmarkIndex, equals(0));
      expect(PoseLandmark.leftShoulder.landmarkIndex, equals(11));
      expect(PoseLandmark.rightShoulder.landmarkIndex, equals(12));
      expect(PoseLandmark.leftElbow.landmarkIndex, equals(13));
      expect(PoseLandmark.rightElbow.landmarkIndex, equals(14));
      expect(PoseLandmark.leftWrist.landmarkIndex, equals(15));
      expect(PoseLandmark.rightWrist.landmarkIndex, equals(16));
      expect(PoseLandmark.leftHip.landmarkIndex, equals(23));
      expect(PoseLandmark.rightHip.landmarkIndex, equals(24));
      expect(PoseLandmark.leftKnee.landmarkIndex, equals(25));
      expect(PoseLandmark.rightKnee.landmarkIndex, equals(26));
      expect(PoseLandmark.leftAnkle.landmarkIndex, equals(27));
      expect(PoseLandmark.rightAnkle.landmarkIndex, equals(28));
    });

    test('should find landmark by index', () {
      expect(PoseLandmark.fromIndex(0), equals(PoseLandmark.nose));
      expect(PoseLandmark.fromIndex(11), equals(PoseLandmark.leftShoulder));
      expect(PoseLandmark.fromIndex(12), equals(PoseLandmark.rightShoulder));
      expect(PoseLandmark.fromIndex(999), isNull);
    });

    test('should find landmark by english name', () {
      expect(PoseLandmark.fromEnglishName('nose'), equals(PoseLandmark.nose));
      expect(PoseLandmark.fromEnglishName('left_shoulder'),
          equals(PoseLandmark.leftShoulder));
      expect(PoseLandmark.fromEnglishName('unknown'), isNull);
    });

    test('should have correct names', () {
      expect(PoseLandmark.nose.chineseName, equals('鼻子'));
      expect(PoseLandmark.nose.englishName, equals('nose'));
      expect(PoseLandmark.leftShoulder.chineseName, equals('左肩'));
      expect(PoseLandmark.leftShoulder.englishName, equals('left_shoulder'));
    });
  });

  group('PoseLandmarkPoint', () {
    test('should create valid point', () {
      const point = PoseLandmarkPoint(
        x: 0.5,
        y: 0.5,
        z: 0.0,
        visibility: 0.9,
        landmark: PoseLandmark.nose,
      );

      expect(point.x, equals(0.5));
      expect(point.y, equals(0.5));
      expect(point.z, equals(0.0));
      expect(point.visibility, equals(0.9));
      expect(point.isValid, isTrue);
    });

    test('should detect invalid point by visibility', () {
      const point = PoseLandmarkPoint(
        x: 0.5,
        y: 0.5,
        z: 0.0,
        visibility: 0.3, // 低于阈值 0.5
        landmark: PoseLandmark.nose,
      );

      expect(point.isValid, isFalse);
    });

    test('should convert to offset', () {
      const point = PoseLandmarkPoint(
        x: 0.5,
        y: 0.5,
        z: 0.0,
        visibility: 1.0,
        landmark: PoseLandmark.nose,
      );

      final offset = point.toOffset(100, 200);
      expect(offset.dx, equals(50));
      expect(offset.dy, equals(100));
    });
  });

  group('PoseData', () {
    test('should create valid pose data', () {
      // 创建 12 个有效关键点以满足 hasMinimumLandmarks 要求
      final landmarks = [
        const PoseLandmarkPoint(x: 0.5, y: 0.1, z: 0.0, visibility: 0.9, landmark: PoseLandmark.nose),
        const PoseLandmarkPoint(x: 0.3, y: 0.2, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftEye),
        const PoseLandmarkPoint(x: 0.7, y: 0.2, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightEye),
        const PoseLandmarkPoint(x: 0.3, y: 0.4, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftShoulder),
        const PoseLandmarkPoint(x: 0.7, y: 0.4, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightShoulder),
        const PoseLandmarkPoint(x: 0.2, y: 0.6, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftElbow),
        const PoseLandmarkPoint(x: 0.8, y: 0.6, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightElbow),
        const PoseLandmarkPoint(x: 0.1, y: 0.8, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftWrist),
        const PoseLandmarkPoint(x: 0.9, y: 0.8, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightWrist),
        const PoseLandmarkPoint(x: 0.3, y: 0.7, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftHip),
        const PoseLandmarkPoint(x: 0.7, y: 0.7, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightHip),
        const PoseLandmarkPoint(x: 0.3, y: 0.9, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftKnee),
      ];

      final poseData = PoseData(
        landmarks: landmarks,
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      expect(poseData.isValid, isTrue);
      expect(poseData.hasMinimumLandmarks, isTrue);
      expect(poseData.landmarks.length, equals(12));
    });

    test('should detect invalid pose data with too few landmarks', () {
      final landmarks = [
        const PoseLandmarkPoint(
          x: 0.5,
          y: 0.2,
          z: 0.0,
          visibility: 0.9,
          landmark: PoseLandmark.nose,
        ),
      ];

      final poseData = PoseData(
        landmarks: landmarks,
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      expect(poseData.isValid, isFalse); // 少于 11 个关键点
      expect(poseData.hasMinimumLandmarks, isFalse);
    });

    test('should get specific landmark', () {
      final landmarks = [
        const PoseLandmarkPoint(
          x: 0.5,
          y: 0.2,
          z: 0.0,
          visibility: 0.9,
          landmark: PoseLandmark.nose,
        ),
        const PoseLandmarkPoint(
          x: 0.3,
          y: 0.4,
          z: 0.0,
          visibility: 0.8,
          landmark: PoseLandmark.leftShoulder,
        ),
      ];

      final poseData = PoseData(
        landmarks: landmarks,
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      final nose = poseData.getLandmark(PoseLandmark.nose);
      expect(nose, isNotNull);
      expect(nose?.landmark, equals(PoseLandmark.nose));

      final rightShoulder = poseData.getLandmark(PoseLandmark.rightShoulder);
      expect(rightShoulder, isNull); // 未添加
    });

    test('should get valid landmarks only', () {
      final landmarks = [
        const PoseLandmarkPoint(
          x: 0.5,
          y: 0.2,
          z: 0.0,
          visibility: 0.9,
          landmark: PoseLandmark.nose,
        ),
        const PoseLandmarkPoint(
          x: 0.3,
          y: 0.4,
          z: 0.0,
          visibility: 0.3, // 无效
          landmark: PoseLandmark.leftShoulder,
        ),
      ];

      final poseData = PoseData(
        landmarks: landmarks,
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      expect(poseData.validLandmarks.length, equals(1));
      expect(poseData.validLandmarks.first.landmark, equals(PoseLandmark.nose));
    });

    test('should calculate shoulder center', () {
      final landmarks = [
        const PoseLandmarkPoint(
          x: 0.3,
          y: 0.4,
          z: 0.0,
          visibility: 0.8,
          landmark: PoseLandmark.leftShoulder,
        ),
        const PoseLandmarkPoint(
          x: 0.7,
          y: 0.4,
          z: 0.0,
          visibility: 0.8,
          landmark: PoseLandmark.rightShoulder,
        ),
      ];

      final poseData = PoseData(
        landmarks: landmarks,
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      final center = poseData.shoulderCenter;
      expect(center, isNotNull);
      expect(center!.dx, equals(0.5));
      expect(center.dy, equals(0.4));
    });

    test('should calculate hip center', () {
      final landmarks = [
        const PoseLandmarkPoint(
          x: 0.3,
          y: 0.7,
          z: 0.0,
          visibility: 0.8,
          landmark: PoseLandmark.leftHip,
        ),
        const PoseLandmarkPoint(
          x: 0.7,
          y: 0.7,
          z: 0.0,
          visibility: 0.8,
          landmark: PoseLandmark.rightHip,
        ),
      ];

      final poseData = PoseData(
        landmarks: landmarks,
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      final center = poseData.hipCenter;
      expect(center, isNotNull);
      expect(center!.dx, equals(0.5));
      expect(center.dy, equals(0.7));
    });
  });

  group('PoseDetectionResult', () {
    test('should create success result', () {
      final poseData = PoseData(
        landmarks: [
          const PoseLandmarkPoint(
            x: 0.5,
            y: 0.5,
            z: 0.0,
            visibility: 0.9,
            landmark: PoseLandmark.nose,
          ),
        ],
        worldLandmarks: [],
        timestamp: 1234567890,
      );

      final result = PoseDetectionResult(poseData: poseData);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      const result = PoseDetectionResult(error: 'Detection failed');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.poseData, isNull);
      expect(result.error, equals('Detection failed'));
    });
  });

  group('SkeletonConnection', () {
    test('should have default connections', () {
      expect(SkeletonConnection.defaultConnections, isNotEmpty);

      // 检查包含关键连接
      final hasTorso = SkeletonConnection.defaultConnections.any(
        (c) =>
            c.start == PoseLandmark.leftShoulder &&
            c.end == PoseLandmark.rightShoulder,
      );
      expect(hasTorso, isTrue);

      final hasLeftArm = SkeletonConnection.defaultConnections.any(
        (c) =>
            c.start == PoseLandmark.leftShoulder &&
            c.end == PoseLandmark.leftElbow,
      );
      expect(hasLeftArm, isTrue);
    });
  });

  group('PoseDetectorConfig', () {
    test('should have default values', () {
      const config = PoseDetectorConfig();

      expect(config.modelComplexity, equals(1));
      expect(config.smoothLandmarks, isTrue);
      expect(config.enableSegmentation, isFalse);
      expect(config.minDetectionConfidence, equals(0.5));
      expect(config.minTrackingConfidence, equals(0.5));
    });

    test('should allow custom values', () {
      const config = PoseDetectorConfig(
        modelComplexity: 2,
        smoothLandmarks: false,
        minDetectionConfidence: 0.8,
      );

      expect(config.modelComplexity, equals(2));
      expect(config.smoothLandmarks, isFalse);
      expect(config.minDetectionConfidence, equals(0.8));
    });
  });
}
