import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/analysis/metrics_calculator.dart';
import 'package:batana/analysis/swing_phase_detector.dart';
import 'package:batana/analysis/pose_detector.dart';

void main() {
  group('SwingMetrics', () {
    test('should create SwingMetrics with required parameters', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );

      expect(metrics.velocity, equals(20.0));
      expect(metrics.velocityLevel, equals('中'));
      expect(metrics.maxAngle, equals(45.0));
      expect(metrics.hipShoulderDelay, equals(50.0));
      expect(metrics.transferSmoothness, equals(0.8));
      expect(metrics.isReference, isTrue);
    });

    test('velocityFormatted should include reference indicator when isReference is true', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
        isReference: true,
      );
      expect(metrics.velocityFormatted, contains('参考值'));
    });

    test('velocityFormatted should not include reference indicator when isReference is false', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
        isReference: false,
      );
      expect(metrics.velocityFormatted, isNot(contains('参考值')));
    });

    test('angleFormatted should format angle correctly', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );
      expect(metrics.angleFormatted, contains('45'));
    });

    test('coordinationLevel should return correct level for excellent coordination', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 100.0, // positive = hip leads
        transferSmoothness: 0.9,
      );
      expect(metrics.coordinationLevel, contains('优秀'));
    });

    test('coordinationLevel should return correct level for poor coordination', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: -100.0, // negative = shoulder leads
        transferSmoothness: 0.2,
      );
      expect(metrics.coordinationLevel, contains('较差'));
    });

    test('hipShoulderDelayFormatted should show hip leads when positive', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );
      expect(metrics.hipShoulderDelayFormatted, contains('髋部领先'));
    });

    test('hipShoulderDelayFormatted should show shoulder leads when negative', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: -50.0,
        transferSmoothness: 0.8,
      );
      expect(metrics.hipShoulderDelayFormatted, contains('肩部领先'));
    });

    test('hipShoulderDelayFormatted should show sync when zero', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 0.0,
        transferSmoothness: 0.8,
      );
      expect(metrics.hipShoulderDelayFormatted, contains('同步'));
    });

    test('transferSmoothnessFormatted should show percentage', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );
      expect(metrics.transferSmoothnessFormatted, contains('80'));
    });
  });

  group('SwingMetricsCalculator', () {
    late SwingMetricsCalculator calculator;

    setUp(() {
      calculator = SwingMetricsCalculator();
    });

    group('calculate', () {
      test('should return default metrics for empty frames', () {
        final result = calculator.calculate(
          [],
          const SwingPhaseResult(
            phases: [],
            phaseBoundaries: [],
            isFullPhase: false,
          ),
        );

        expect(result.velocity, equals(0.0));
        expect(result.velocityLevel, equals('未知'));
        expect(result.maxAngle, equals(0.0));
      });

      test('should calculate velocity from frames', () {
        final frames = _generateFramesWithVelocity(frameCount: 40);
        final phaseResult = _createMockPhaseResult();

        final result = calculator.calculate(frames, phaseResult);

        expect(result.velocity, greaterThan(0.0));
      });

      test('should calculate max angle from frames', () {
        final frames = _generateFramesWithAngle(frameCount: 40, maxAngle: 50.0);
        final phaseResult = _createMockPhaseResult();

        final result = calculator.calculate(frames, phaseResult);

        expect(result.maxAngle, greaterThan(0.0));
      });
    });

    group('MetricsCalculatorConfig', () {
      test('default config should have correct values', () {
        const config = MetricsCalculatorConfig();
        expect(config.defaultHeightCm, equals(170.0));
        expect(config.defaultShoulderWidthCm, equals(40.0));
        expect(config.frameRate, equals(30.0));
        expect(config.velocitySmoothingWindow, equals(3));
        expect(config.angleSmoothingWindow, equals(5));
      });

      test('custom config should override default values', () {
        const config = MetricsCalculatorConfig(
          defaultHeightCm: 180.0,
          frameRate: 60.0,
        );
        expect(config.defaultHeightCm, equals(180.0));
        expect(config.frameRate, equals(60.0));
        expect(config.defaultShoulderWidthCm, equals(40.0));
      });
    });
  });

  group('ExtendedFrameData', () {
    test('should create ExtendedFrameData with required parameters', () {
      const frame = ExtendedFrameData(
        frameIndex: 0,
        timestamp: 1000,
        wristPosition: Offset(0.5, 0.5),
        shoulderPosition: Offset(0.5, 0.3),
        hipCenter: Offset(0.5, 0.7),
      );

      expect(frame.frameIndex, equals(0));
      expect(frame.timestamp, equals(1000));
      expect(frame.wristPosition, equals(const Offset(0.5, 0.5)));
      expect(frame.shoulderPosition, equals(const Offset(0.5, 0.3)));
      expect(frame.hipCenter, equals(const Offset(0.5, 0.7)));
    });

    test('should create ExtendedFrameData with optional parameters', () {
      const frame = ExtendedFrameData(
        frameIndex: 5,
        timestamp: 1500,
        wristPosition: Offset(0.6, 0.4),
        shoulderPosition: Offset(0.5, 0.3),
        hipCenter: Offset(0.5, 0.7),
        wristVelocity: 0.5,
        swingAngle: 45.0,
        hipRotation: 30.0,
        shoulderRotation: 20.0,
      );

      expect(frame.wristVelocity, equals(0.5));
      expect(frame.swingAngle, equals(45.0));
      expect(frame.hipRotation, equals(30.0));
      expect(frame.shoulderRotation, equals(20.0));
    });
  });

  group('ExtendedFrameBuilder', () {
    late ExtendedFrameBuilder builder;

    setUp(() {
      builder = ExtendedFrameBuilder();
    });

    test('should create ExtendedFrameBuilder with default config', () {
      expect(builder.useDominantHand, isTrue);
    });

    test('should create ExtendedFrameBuilder with custom useDominantHand', () {
      final customBuilder = ExtendedFrameBuilder(useDominantHand: false);
      expect(customBuilder.useDominantHand, isFalse);
    });

    test('build should create ExtendedFrameData from PoseData', () {
      final poseData = _createMockPoseData();

      final result = builder.build(0, 1000, poseData);

      expect(result.frameIndex, equals(0));
      expect(result.timestamp, equals(1000));
      expect(result.wristPosition, isNotNull);
      expect(result.shoulderPosition, isNotNull);
      expect(result.hipCenter, isNotNull);
    });
  });
}

/// 生成带速度变化的帧数据
List<ExtendedFrameData> _generateFramesWithVelocity({
  required int frameCount,
  double baseVelocity = 0.1,
}) {
  final frames = <ExtendedFrameData>[];

  for (int i = 0; i < frameCount; i++) {
    // 模拟速度曲线
    double velocity = baseVelocity;
    if (i > frameCount * 0.3 && i < frameCount * 0.7) {
      velocity = baseVelocity + (i - frameCount * 0.3) * 0.02;
    }

    frames.add(ExtendedFrameData(
      frameIndex: i,
      timestamp: i * 33,
      wristPosition: Offset(0.5 + i * 0.005, 0.5 - i * 0.002),
      shoulderPosition: const Offset(0.5, 0.3),
      hipCenter: const Offset(0.5, 0.7),
      wristVelocity: velocity,
    ));
  }

  return frames;
}

/// 生成带角度变化的帧数据
List<ExtendedFrameData> _generateFramesWithAngle({
  required int frameCount,
  required double maxAngle,
}) {
  final frames = <ExtendedFrameData>[];

  for (int i = 0; i < frameCount; i++) {
    // 模拟角度变化
    double angle = 0.0;
    if (i > frameCount * 0.3) {
      final progress = min(1.0, (i - frameCount * 0.3) / (frameCount * 0.4));
      angle = progress * maxAngle;
    }

    frames.add(ExtendedFrameData(
      frameIndex: i,
      timestamp: i * 33,
      wristPosition: Offset(0.5 + i * 0.005, 0.5 - i * 0.002),
      shoulderPosition: const Offset(0.5, 0.3),
      hipCenter: const Offset(0.5, 0.7),
      swingAngle: angle,
    ));
  }

  return frames;
}

/// 创建模拟阶段检测结果
SwingPhaseResult _createMockPhaseResult() {
  return const SwingPhaseResult(
    phases: [SwingPhase.prepare, SwingPhase.accelerate, SwingPhase.strike, SwingPhase.followThrough],
    phaseBoundaries: [10, 25, 35],
    isFullPhase: true,
    peakVelocity: 0.3,
  );
}

/// 创建模拟姿态数据
PoseData _createMockPoseData() {
  return PoseData(
    landmarks: [
      const PoseLandmarkPoint(x: 0.5, y: 0.3, z: 0.0, visibility: 0.8, landmark: PoseLandmark.nose),
      const PoseLandmarkPoint(x: 0.4, y: 0.5, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftShoulder),
      const PoseLandmarkPoint(x: 0.6, y: 0.5, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightShoulder),
      const PoseLandmarkPoint(x: 0.35, y: 0.7, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftHip),
      const PoseLandmarkPoint(x: 0.65, y: 0.7, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightHip),
      const PoseLandmarkPoint(x: 0.3, y: 0.45, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftWrist),
      const PoseLandmarkPoint(x: 0.7, y: 0.45, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightWrist),
      const PoseLandmarkPoint(x: 0.45, y: 0.28, z: 0.0, visibility: 0.7, landmark: PoseLandmark.leftEye),
      const PoseLandmarkPoint(x: 0.55, y: 0.28, z: 0.0, visibility: 0.7, landmark: PoseLandmark.rightEye),
      const PoseLandmarkPoint(x: 0.35, y: 0.32, z: 0.0, visibility: 0.7, landmark: PoseLandmark.leftEar),
      const PoseLandmarkPoint(x: 0.65, y: 0.32, z: 0.0, visibility: 0.7, landmark: PoseLandmark.rightEar),
    ],
    worldLandmarks: [],
    timestamp: 0,
  );
}
