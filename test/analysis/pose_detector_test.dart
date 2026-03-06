import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/analysis/pose_detector.dart';

void main() {
  group('PoseLandmark', () {
    test('fromIndex should return correct landmark', () {
      expect(PoseLandmark.fromIndex(0), equals(PoseLandmark.nose));
      expect(PoseLandmark.fromIndex(11), equals(PoseLandmark.leftShoulder));
      expect(PoseLandmark.fromIndex(24), equals(PoseLandmark.rightHip));
    });

    test('fromIndex should return null for invalid index', () {
      expect(PoseLandmark.fromIndex(-1), isNull);
      expect(PoseLandmark.fromIndex(33), isNull);
    });

    test('fromEnglishName should return correct landmark', () {
      expect(PoseLandmark.fromEnglishName('nose'), equals(PoseLandmark.nose));
      expect(PoseLandmark.fromEnglishName('left_shoulder'), equals(PoseLandmark.leftShoulder));
      expect(PoseLandmark.fromEnglishName('right_wrist'), equals(PoseLandmark.rightWrist));
    });

    test('fromEnglishName should return null for invalid name', () {
      expect(PoseLandmark.fromEnglishName('invalid'), isNull);
      expect(PoseLandmark.fromEnglishName(''), isNull);
    });
  });

  group('PoseLandmarkPoint', () {
    test('isValid should return true when visibility >= threshold', () {
      final point = PoseLandmarkPoint(
        x: 0.5,
        y: 0.5,
        z: 0.0,
        visibility: 0.6,
        landmark: PoseLandmark.nose,
      );
      expect(point.isValid, isTrue);
    });

    test('isValid should return false when visibility < threshold', () {
      final point = PoseLandmarkPoint(
        x: 0.5,
        y: 0.5,
        z: 0.0,
        visibility: 0.4,
        landmark: PoseLandmark.nose,
      );
      expect(point.isValid, isFalse);
    });

    test('toOffset should convert to screen coordinates', () {
      final point = PoseLandmarkPoint(
        x: 0.5,
        y: 0.5,
        z: 0.0,
        visibility: 0.6,
        landmark: PoseLandmark.nose,
      );
      final offset = point.toOffset(1920, 1080);
      expect(offset.dx, equals(960.0));
      expect(offset.dy, equals(540.0));
    });

    test('confidenceThreshold should be 0.5', () {
      expect(PoseLandmarkPoint.confidenceThreshold, equals(0.5));
    });
  });

  group('PoseData', () {
    late List<PoseLandmarkPoint> validLandmarks;
    late List<PoseLandmarkPoint> invalidLandmarks;

    setUp(() {
      validLandmarks = [
        PoseLandmarkPoint(x: 0.5, y: 0.3, z: 0.0, visibility: 0.8, landmark: PoseLandmark.nose),
        PoseLandmarkPoint(x: 0.4, y: 0.25, z: 0.0, visibility: 0.7, landmark: PoseLandmark.leftEye),
        PoseLandmarkPoint(x: 0.6, y: 0.25, z: 0.0, visibility: 0.7, landmark: PoseLandmark.rightEye),
        PoseLandmarkPoint(x: 0.35, y: 0.35, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftEar),
        PoseLandmarkPoint(x: 0.65, y: 0.35, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightEar),
        PoseLandmarkPoint(x: 0.4, y: 0.5, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftShoulder),
        PoseLandmarkPoint(x: 0.6, y: 0.5, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightShoulder),
        PoseLandmarkPoint(x: 0.35, y: 0.7, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftHip),
        PoseLandmarkPoint(x: 0.65, y: 0.7, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightHip),
        PoseLandmarkPoint(x: 0.4, y: 0.9, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftKnee),
        PoseLandmarkPoint(x: 0.6, y: 0.9, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightKnee),
      ];

      invalidLandmarks = [
        PoseLandmarkPoint(x: 0.5, y: 0.3, z: 0.0, visibility: 0.3, landmark: PoseLandmark.nose),
      ];
    });

    test('isValid should return true for valid pose data', () {
      final poseData = PoseData(
        landmarks: validLandmarks,
        worldLandmarks: validLandmarks,
        timestamp: 1000,
      );
      expect(poseData.isValid, isTrue);
    });

    test('isValid should return false for empty landmarks', () {
      final poseData = PoseData(
        landmarks: [],
        worldLandmarks: [],
        timestamp: 1000,
      );
      expect(poseData.isValid, isFalse);
    });

    test('isValid should return false for insufficient valid landmarks', () {
      final poseData = PoseData(
        landmarks: invalidLandmarks,
        worldLandmarks: invalidLandmarks,
        timestamp: 1000,
      );
      expect(poseData.isValid, isFalse);
    });

    test('hasMinimumLandmarks should return true for 11+ valid landmarks', () {
      final poseData = PoseData(
        landmarks: validLandmarks,
        worldLandmarks: validLandmarks,
        timestamp: 1000,
      );
      expect(poseData.hasMinimumLandmarks, isTrue);
    });

    test('getLandmark should return correct landmark', () {
      final poseData = PoseData(
        landmarks: validLandmarks,
        worldLandmarks: validLandmarks,
        timestamp: 1000,
      );
      final nose = poseData.getLandmark(PoseLandmark.nose);
      expect(nose, isNotNull);
      expect(nose!.landmark, equals(PoseLandmark.nose));
    });

    test('getLandmark should return null for missing landmark', () {
      final poseData = PoseData(
        landmarks: [],
        worldLandmarks: [],
        timestamp: 1000,
      );
      expect(poseData.getLandmark(PoseLandmark.nose), isNull);
    });

    test('validLandmarks should return only valid landmarks', () {
      final mixedLandmarks = [
        PoseLandmarkPoint(x: 0.5, y: 0.3, z: 0.0, visibility: 0.8, landmark: PoseLandmark.nose),
        PoseLandmarkPoint(x: 0.4, y: 0.3, z: 0.0, visibility: 0.3, landmark: PoseLandmark.leftEye),
      ];
      final poseData = PoseData(
        landmarks: mixedLandmarks,
        worldLandmarks: mixedLandmarks,
        timestamp: 1000,
      );
      expect(poseData.validLandmarks.length, equals(1));
      expect(poseData.validLandmarks.first.landmark, equals(PoseLandmark.nose));
    });

    test('shoulderCenter should return correct center', () {
      final poseData = PoseData(
        landmarks: validLandmarks,
        worldLandmarks: validLandmarks,
        timestamp: 1000,
      );
      final center = poseData.shoulderCenter;
      expect(center, isNotNull);
      expect(center!.dx, equals(0.5));
      expect(center.dy, equals(0.5));
    });

    test('shoulderCenter should return null when shoulders invalid', () {
      final poseData = PoseData(
        landmarks: invalidLandmarks,
        worldLandmarks: invalidLandmarks,
        timestamp: 1000,
      );
      expect(poseData.shoulderCenter, isNull);
    });

    test('hipCenter should return correct center', () {
      final poseData = PoseData(
        landmarks: validLandmarks,
        worldLandmarks: validLandmarks,
        timestamp: 1000,
      );
      final center = poseData.hipCenter;
      expect(center, isNotNull);
      expect(center!.dx, equals(0.5));
      expect(center.dy, equals(0.7));
    });

    test('hipCenter should return null when hips invalid', () {
      final poseData = PoseData(
        landmarks: invalidLandmarks,
        worldLandmarks: invalidLandmarks,
        timestamp: 1000,
      );
      expect(poseData.hipCenter, isNull);
    });
  });

  group('PoseDetectionResult', () {
    test('isSuccess should return true when poseData is present', () {
      final result = PoseDetectionResult(
        poseData: PoseData(
          landmarks: [],
          worldLandmarks: [],
          timestamp: 0,
        ),
      );
      expect(result.isSuccess, isTrue);
    });

    test('isFailure should return true when error is present', () {
      final result = PoseDetectionResult(
        poseData: null,
        error: 'Detection failed',
      );
      expect(result.isFailure, isTrue);
    });

    test('isFailure should return true when poseData is null', () {
      final result = PoseDetectionResult();
      expect(result.isFailure, isTrue);
    });
  });

  group('SkeletonConnection', () {
    test('defaultConnections should contain expected connections', () {
      final connections = SkeletonConnection.defaultConnections;
      expect(connections, isNotEmpty);

      // 验证躯干连接
      expect(connections.any((c) =>
        c.start == PoseLandmark.leftShoulder &&
        c.end == PoseLandmark.rightShoulder
      ), isTrue);

      // 验证左臂连接
      expect(connections.any((c) =>
        c.start == PoseLandmark.leftShoulder &&
        c.end == PoseLandmark.leftElbow
      ), isTrue);
    });
  });

  group('PoseDetectorConfig', () {
    test('default config should have correct values', () {
      const config = PoseDetectorConfig();
      expect(config.modelComplexity, equals(1));
      expect(config.smoothLandmarks, isTrue);
      expect(config.enableSegmentation, isFalse);
      expect(config.minDetectionConfidence, equals(0.5));
      expect(config.minTrackingConfidence, equals(0.5));
    });

    test('custom config should override default values', () {
      const config = PoseDetectorConfig(
        modelComplexity: 2,
        smoothLandmarks: false,
        minDetectionConfidence: 0.7,
      );
      expect(config.modelComplexity, equals(2));
      expect(config.smoothLandmarks, isFalse);
      expect(config.minDetectionConfidence, equals(0.7));
      expect(config.enableSegmentation, isFalse);
    });
  });
}
