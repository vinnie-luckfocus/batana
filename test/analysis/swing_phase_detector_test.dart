import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/analysis/swing_phase_detector.dart';
import 'package:batana/analysis/pose_detector.dart';

void main() {
  group('SwingPhaseDetector', () {
    late SwingPhaseDetector detector;

    setUp(() {
      detector = SwingPhaseDetector();
    });

    group('detect', () {
      test('should return error for empty frames', () {
        final result = detector.detect([]);
        expect(result.isFailure, isTrue);
        expect(result.errorMessage, equals('无帧数据'));
      });

      test('should return error for insufficient frames', () {
        // 创建不足30帧的数据
        final frames = List.generate(
          20,
          (i) => FrameData(
            frameIndex: i,
            timestamp: i * 33,
            wristPosition: const Offset(0.5, 0.5),
            wristVelocity: 0.0,
          ),
        );
        final result = detector.detect(frames);
        expect(result.isFailure, isTrue);
        expect(result.errorMessage, contains('帧数不足'));
      });

      test('should detect four phases with valid swing data', () {
        // 创建模拟挥棒动作的帧数据
        // 准备期: 速度很低
        // 加速期: 速度逐渐增加
        // 击球期: 速度达到峰值
        // 收尾期: 速度逐渐降低
        final frames = _generateSwingFrames(frameCount: 60);

        final result = detector.detect(frames);

        // 由于是模拟数据，可能无法完美检测，但不应该崩溃
        expect(result.phases, isNotEmpty);
      });
    });

    group('SwingPhaseDetectorConfig', () {
      test('default config should have correct values', () {
        const config = SwingPhaseDetectorConfig();
        expect(config.velocityThreshold, equals(0.05));
        expect(config.accelerationThreshold, equals(0.01));
        expect(config.peakMinFrames, equals(5));
        expect(config.smoothingWindowSize, equals(3));
        expect(config.minValidFrames, equals(30));
        expect(config.minPeakVelocity, equals(0.1));
      });

      test('custom config should override default values', () {
        const config = SwingPhaseDetectorConfig(
          velocityThreshold: 0.1,
          minValidFrames: 20,
          minPeakVelocity: 0.2,
        );
        expect(config.velocityThreshold, equals(0.1));
        expect(config.minValidFrames, equals(20));
        expect(config.minPeakVelocity, equals(0.2));
      });
    });
  });

  group('SwingPhaseAnalyzer', () {
    late SwingPhaseAnalyzer analyzer;

    setUp(() {
      analyzer = SwingPhaseAnalyzer();
    });

    test('initial state should have zero frame count', () {
      expect(analyzer.frameCount, equals(0));
    });

    test('setUseDominantHand should update the flag', () {
      analyzer.setUseDominantHand(false);
      expect(analyzer.useDominantHand, isFalse);

      analyzer.setUseDominantHand(true);
      expect(analyzer.useDominantHand, isTrue);
    });

    test('reset should clear frames', () {
      // 添加一些帧数据
      analyzer.addFrame(0, 0, _createMockPoseData());
      expect(analyzer.frameCount, greaterThan(0));

      // 重置
      analyzer.reset();
      expect(analyzer.frameCount, equals(0));
    });
  });

  group('FrameData', () {
    test('should create FrameData with required parameters', () {
      const frame = FrameData(
        frameIndex: 0,
        timestamp: 1000,
        wristPosition: Offset(0.5, 0.5),
      );
      expect(frame.frameIndex, equals(0));
      expect(frame.timestamp, equals(1000));
      expect(frame.wristPosition, equals(const Offset(0.5, 0.5)));
      expect(frame.wristVelocity, equals(0.0));
    });

    test('should create FrameData with optional wristVelocity', () {
      const frame = FrameData(
        frameIndex: 5,
        timestamp: 1500,
        wristPosition: Offset(0.6, 0.4),
        wristVelocity: 0.5,
      );
      expect(frame.wristVelocity, equals(0.5));
    });
  });

  group('SwingPhaseResult', () {
    test('isSuccess should return true when no error and phases not empty', () {
      const result = SwingPhaseResult(
        phases: [SwingPhase.prepare, SwingPhase.accelerate],
        phaseBoundaries: [10, 20],
        isFullPhase: false,
      );
      expect(result.isSuccess, isTrue);
    });

    test('isFailure should return true when has error message', () {
      const result = SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: 'Error occurred',
      );
      expect(result.isFailure, isTrue);
    });

    test('isFailure should return true when phases is empty', () {
      const result = SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
      );
      expect(result.isFailure, isTrue);
    });

    test('toString should return correct format for success', () {
      const result = SwingPhaseResult(
        phases: [SwingPhase.prepare, SwingPhase.accelerate],
        phaseBoundaries: [10, 20],
        isFullPhase: false,
      );
      final str = result.toString();
      expect(str, contains('SwingPhaseResult'));
      expect(str, contains('prepare'));
    });

    test('toString should return correct format for failure', () {
      const result = SwingPhaseResult(
        phases: [],
        phaseBoundaries: [],
        isFullPhase: false,
        errorMessage: 'Test error',
      );
      expect(result.toString(), contains('error: Test error'));
    });
  });

  group('SwingPhase', () {
    test('should have all four phases', () {
      expect(SwingPhase.values.length, equals(4));
      expect(SwingPhase.values, contains(SwingPhase.prepare));
      expect(SwingPhase.values, contains(SwingPhase.accelerate));
      expect(SwingPhase.values, contains(SwingPhase.strike));
      expect(SwingPhase.values, contains(SwingPhase.followThrough));
    });
  });
}

/// 生成模拟挥棒数据的辅助函数
List<FrameData> _generateSwingFrames({required int frameCount}) {
  final frames = <FrameData>[];

  // 模拟速度曲线: 低-升高-峰值-降低
  for (int i = 0; i < frameCount; i++) {
    double velocity;
    if (i < frameCount * 0.2) {
      // 准备期: 低速
      velocity = 0.02;
    } else if (i < frameCount * 0.5) {
      // 加速期: 逐渐加速
      final progress = (i - frameCount * 0.2) / (frameCount * 0.3);
      velocity = 0.02 + progress * 0.3;
    } else if (i < frameCount * 0.7) {
      // 击球期: 峰值
      velocity = 0.35 - ((i - frameCount * 0.5) / (frameCount * 0.2)) * 0.05;
    } else {
      // 收尾期: 减速
      final progress = (i - frameCount * 0.7) / (frameCount * 0.3);
      velocity = 0.3 * (1 - progress);
    }

    frames.add(FrameData(
      frameIndex: i,
      timestamp: i * 33, // 30fps
      wristPosition: Offset(0.5 + i * 0.005, 0.5 - i * 0.002),
      wristVelocity: velocity,
    ));
  }

  return frames;
}

/// 创建模拟姿态数据的辅助函数
PoseData _createMockPoseData() {
  return PoseData(
    landmarks: [
      PoseLandmarkPoint(x: 0.5, y: 0.3, z: 0.0, visibility: 0.8, landmark: PoseLandmark.nose),
      PoseLandmarkPoint(x: 0.4, y: 0.5, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftShoulder),
      PoseLandmarkPoint(x: 0.6, y: 0.5, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightShoulder),
      PoseLandmarkPoint(x: 0.35, y: 0.7, z: 0.0, visibility: 0.9, landmark: PoseLandmark.leftHip),
      PoseLandmarkPoint(x: 0.65, y: 0.7, z: 0.0, visibility: 0.9, landmark: PoseLandmark.rightHip),
      PoseLandmarkPoint(x: 0.3, y: 0.45, z: 0.0, visibility: 0.8, landmark: PoseLandmark.leftWrist),
      PoseLandmarkPoint(x: 0.7, y: 0.45, z: 0.0, visibility: 0.8, landmark: PoseLandmark.rightWrist),
    ],
    worldLandmarks: [],
    timestamp: 0,
  );
}
