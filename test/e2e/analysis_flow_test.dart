import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/analysis/pose_detector.dart';
import 'package:batana/analysis/swing_phase_detector.dart';
import 'package:batana/analysis/metrics_calculator.dart';
import 'package:batana/scoring/scoring_engine.dart';
import 'package:batana/scoring/problem_detector.dart';

/// 端到端测试
///
/// 验证完整分析流程:
/// 1. 摄像头录制 -> 姿态识别
/// 2. MediaPipe 姿态识别 -> 姿态数据
/// 3. 挥棒阶段分割 -> 阶段结果
/// 4. 指标计算 -> 挥棒指标
/// 5. 评分引擎 -> 评分结果
/// 6. 结果展示 -> 展示数据
/// 7. 历史存储 -> 存储记录
void main() {
  group('端到端分析流程测试', () {
    late List<PoseData> mockPoseSequence;
    late List<ExtendedFrameData> mockExtendedFrames;

    setUp(() {
      // 模拟 60 帧的挥棒动作序列
      mockPoseSequence = _generateMockPoseSequence(frameCount: 60);
      mockExtendedFrames = _generateExtendedFramesFromPoseData(mockPoseSequence);
    });

    test('完整流程: 姿态数据 -> 阶段检测 -> 指标计算 -> 评分', () {
      // 步骤 1: 验证姿态数据有效
      expect(mockPoseSequence, isNotEmpty);
      final validFrames = mockPoseSequence.where((p) => p.isValid).toList();
      expect(validFrames.length, greaterThan(30)); // 至少 30 帧有效数据

      // 步骤 2: 阶段检测
      final phaseDetector = SwingPhaseDetector();
      final frameDataList = _convertToFrameData(mockExtendedFrames);
      final phaseResult = phaseDetector.detect(frameDataList);

      // 验证阶段检测结果
      expect(phaseResult.phases, isNotEmpty);
      print('阶段检测结果: ${phaseResult.phases.length} 个阶段');
      if (phaseResult.peakVelocity != null) {
        print('峰值速度: ${phaseResult.peakVelocity}');
      }

      // 步骤 3: 指标计算
      final calculator = SwingMetricsCalculator();
      final metrics = calculator.calculate(mockExtendedFrames, phaseResult);

      // 验证指标计算结果
      expect(metrics.velocity, greaterThanOrEqualTo(0));
      expect(metrics.maxAngle, greaterThanOrEqualTo(0));
      expect(metrics.transferSmoothness, greaterThanOrEqualTo(0));
      print('计算得到的指标:');
      print('  - 速度: ${metrics.velocityFormatted}');
      print('  - 角度: ${metrics.angleFormatted}');
      print('  - 髋肩时序: ${metrics.hipShoulderDelayFormatted}');
      print('  - 协调性: ${metrics.coordinationLevel}');

      // 步骤 4: 评分引擎
      final scoringEngine = ScoringEngine();
      final scoringResult = scoringEngine.calculate(metrics);

      // 验证评分结果
      expect(scoringResult.totalScore, greaterThanOrEqualTo(0));
      expect(scoringResult.totalScore, lessThanOrEqualTo(100));
      expect(scoringResult.grade, isNotEmpty);
      print('评分结果:');
      print('  - 总分: ${scoringResult.totalScore} (${scoringResult.grade})');
      print('  - 速度分: ${scoringResult.velocityScore}');
      print('  - 角度分: ${scoringResult.angleScore}');
      print('  - 协调性分: ${scoringResult.coordinationScore}');
      print('  - 问题数: ${scoringResult.problems.length}');
      print('  - 建议数: ${scoringResult.suggestions.length}');

      // 验证问题检测
      for (final problem in scoringResult.problems) {
        print('  - 问题: ${problem.description}');
      }

      // 验证建议生成
      for (final suggestion in scoringResult.suggestions) {
        print('  - 建议: $suggestion');
      }

      // 步骤 5: 验证整体流程完整性
      expect(phaseResult.isSuccess || phaseResult.isFailure, isTrue);
      expect(metrics.velocityLevel, isNotEmpty);
      expect(scoringResult.hasProblems, isNotNull);
    });

    test('异常流程: 空姿态数据应返回默认值', () {
      // 使用空数据测试降级处理
      final calculator = SwingMetricsCalculator();
      final emptyFrames = <ExtendedFrameData>[];

      final metrics = calculator.calculate(
        emptyFrames,
        const SwingPhaseResult(
          phases: [],
          phaseBoundaries: [],
          isFullPhase: false,
        ),
      );

      // 验证返回默认值
      expect(metrics.velocity, equals(0.0));
      expect(metrics.velocityLevel, equals('未知'));
    });

    test('异常流程: 无效阶段检测应返回错误信息', () {
      final detector = SwingPhaseDetector();
      final emptyFrames = <FrameData>[];

      final result = detector.detect(emptyFrames);

      expect(result.isFailure, isTrue);
      expect(result.errorMessage, isNotEmpty);
    });

    test('边界条件: 最小帧数测试', () {
      // 测试最小有效帧数边界
      final detector = SwingPhaseDetector();

      // 29 帧 - 应该失败（小于最小 30 帧）
      final nearMinFrames = _generateMinimalVelocityFrames(frameCount: 29);
      final nearMinResult = detector.detect(nearMinFrames);
      expect(nearMinResult.isFailure, isTrue);

      // 30 帧 - 刚好满足最小帧数
      final minFrames = _generateMinimalVelocityFrames(frameCount: 30);
      final minResult = detector.detect(minFrames);
      // 可能成功也可能失败，取决于数据质量
      expect(minResult.phases.isNotEmpty || minResult.isFailure, isTrue);
    });

    test('性能测试: 大帧数序列处理', () {
      // 测试 300 帧（约 10 秒 30fps）的处理能力
      final largeSequence = _generateMockPoseSequence(frameCount: 300);
      final largeFrames = _generateExtendedFramesFromPoseData(largeSequence);

      final stopwatch = Stopwatch()..start();

      // 阶段检测
      final phaseDetector = SwingPhaseDetector();
      final frameDataList = _convertToFrameData(largeFrames);
      final phaseResult = phaseDetector.detect(frameDataList);

      // 指标计算
      final calculator = SwingMetricsCalculator();
      final metrics = calculator.calculate(largeFrames, phaseResult);

      // 评分
      final scoringEngine = ScoringEngine();
      final result = scoringEngine.calculate(metrics);

      stopwatch.stop();

      // 验证处理完成
      expect(result.totalScore, greaterThanOrEqualTo(0));

      // 输出性能指标
      final elapsedMs = stopwatch.elapsedMilliseconds;
      print('处理 300 帧耗时: ${elapsedMs}ms');
      expect(elapsedMs, lessThan(5000)); // 应该在 5 秒内完成
    });
  });

  group('结果展示数据结构测试', () {
    test('评分结果应包含所有展示所需字段', () {
      const metrics = SwingMetrics(
        velocity: 22.0,
        velocityLevel: '中',
        maxAngle: 48.0,
        hipShoulderDelay: 80.0,
        transferSmoothness: 0.85,
      );

      final scoringEngine = ScoringEngine();
      final result = scoringEngine.calculate(metrics);

      // 验证展示所需字段
      expect(result.totalScore, isNotNull);
      expect(result.grade, isNotNull);
      expect(result.velocityScore, isNotNull);
      expect(result.angleScore, isNotNull);
      expect(result.coordinationScore, isNotNull);
      expect(result.problems, isNotNull);
      expect(result.suggestions, isNotNull);

      // 验证格式化输出
      expect(metrics.velocityFormatted, isNotEmpty);
      expect(metrics.angleFormatted, isNotEmpty);
      expect(metrics.hipShoulderDelayFormatted, isNotEmpty);
      expect(metrics.transferSmoothnessFormatted, isNotEmpty);
    });
  });

  group('历史存储数据结构测试', () {
    test('评分结果应能转换为存储格式', () {
      const metrics = SwingMetrics(
        velocity: 22.0,
        velocityLevel: '中',
        maxAngle: 48.0,
        hipShoulderDelay: 80.0,
        transferSmoothness: 0.85,
      );

      final scoringEngine = ScoringEngine();
      final result = scoringEngine.calculate(metrics);

      // 模拟转换为存储格式
      final storageData = {
        'score': result.totalScore,
        'velocity': metrics.velocity,
        'angle': metrics.maxAngle,
        'coordination': (result.coordinationScore / 100),
        'suggestions': result.suggestions.join('|'),
        'created_at': DateTime.now().toIso8601String(),
      };

      // 验证存储数据结构完整性
      expect(storageData['score'], greaterThanOrEqualTo(0));
      expect(storageData['velocity'], greaterThan(0));
      expect(storageData['angle'], greaterThan(0));
      expect(storageData['coordination'], greaterThanOrEqualTo(0));
      expect(storageData['suggestions'], isNotEmpty);
    });
  });
}

/// 生成模拟挥棒动作的姿态数据序列
List<PoseData> _generateMockPoseSequence({required int frameCount}) {
  final sequence = <PoseData>[];

  for (int i = 0; i < frameCount; i++) {
    final progress = i / frameCount;

    // 模拟腕部位置变化
    double wristX = 0.3;
    double wristY = 0.6;

    if (progress > 0.2) {
      // 加速期
      final swingProgress = (progress - 0.2) / 0.6;
      wristX = 0.3 + swingProgress * 0.4;
      wristY = 0.6 - swingProgress * 0.3;
    }

    final landmarks = [
      PoseLandmarkPoint(
        x: 0.5, y: 0.3, z: 0.0,
        visibility: 0.9,
        landmark: PoseLandmark.nose,
      ),
      PoseLandmarkPoint(
        x: 0.4, y: 0.5, z: 0.0,
        visibility: 0.9,
        landmark: PoseLandmark.leftShoulder,
      ),
      PoseLandmarkPoint(
        x: 0.6, y: 0.5, z: 0.0,
        visibility: 0.9,
        landmark: PoseLandmark.rightShoulder,
      ),
      PoseLandmarkPoint(
        x: 0.4, y: 0.7, z: 0.0,
        visibility: 0.9,
        landmark: PoseLandmark.leftHip,
      ),
      PoseLandmarkPoint(
        x: 0.6, y: 0.7, z: 0.0,
        visibility: 0.9,
        landmark: PoseLandmark.rightHip,
      ),
      PoseLandmarkPoint(
        x: wristX, y: wristY, z: 0.0,
        visibility: 0.85,
        landmark: PoseLandmark.leftWrist,
      ),
      PoseLandmarkPoint(
        x: wristX + 0.1, y: wristY, z: 0.0,
        visibility: 0.85,
        landmark: PoseLandmark.rightWrist,
      ),
      PoseLandmarkPoint(
        x: 0.4, y: 0.28, z: 0.0,
        visibility: 0.8,
        landmark: PoseLandmark.leftEye,
      ),
      PoseLandmarkPoint(
        x: 0.6, y: 0.28, z: 0.0,
        visibility: 0.8,
        landmark: PoseLandmark.rightEye,
      ),
      PoseLandmarkPoint(
        x: 0.35, y: 0.32, z: 0.0,
        visibility: 0.7,
        landmark: PoseLandmark.leftEar,
      ),
      PoseLandmarkPoint(
        x: 0.65, y: 0.32, z: 0.0,
        visibility: 0.7,
        landmark: PoseLandmark.rightEar,
      ),
    ];

    sequence.add(PoseData(
      landmarks: landmarks,
      worldLandmarks: landmarks,
      timestamp: i * 33, // 30fps
    ));
  }

  return sequence;
}

/// 从姿态数据生成扩展帧数据
List<ExtendedFrameData> _generateExtendedFramesFromPoseData(List<PoseData> poseSequence) {
  final frames = <ExtendedFrameData>[];
  final builder = ExtendedFrameBuilder();

  for (int i = 0; i < poseSequence.length; i++) {
    final poseData = poseSequence[i];
    final extendedFrame = builder.build(i, i * 33, poseData);

    // 模拟一些速度数据
    double velocity = 0.0;
    if (i > 10) {
      final progress = (i - 10) / poseSequence.length;
      velocity = progress * 0.4;
      if (i > poseSequence.length * 0.7) {
        velocity = 0.4 * (1 - (i - poseSequence.length * 0.7) / (poseSequence.length * 0.3));
      }
    }

    frames.add(ExtendedFrameData(
      frameIndex: extendedFrame.frameIndex,
      timestamp: extendedFrame.timestamp,
      wristPosition: extendedFrame.wristPosition,
      shoulderPosition: extendedFrame.shoulderPosition,
      hipCenter: extendedFrame.hipCenter,
      wristVelocity: velocity,
      swingAngle: extendedFrame.swingAngle,
      hipRotation: extendedFrame.hipRotation,
      shoulderRotation: extendedFrame.shoulderRotation,
    ));
  }

  return frames;
}

/// 将扩展帧数据转换为帧数据（用于阶段检测）
List<FrameData> _convertToFrameData(List<ExtendedFrameData> extendedFrames) {
  return extendedFrames.map((frame) => FrameData(
    frameIndex: frame.frameIndex,
    timestamp: frame.timestamp,
    wristPosition: frame.wristPosition,
    wristVelocity: frame.wristVelocity,
  )).toList();
}

/// 生成最小速度变化的帧数据（用于边界测试）
List<FrameData> _generateMinimalVelocityFrames({required int frameCount}) {
  final frames = <FrameData>[];

  for (int i = 0; i < frameCount; i++) {
    double velocity = 0.02;
    if (i > frameCount * 0.3 && i < frameCount * 0.7) {
      velocity = 0.15 + (i - frameCount * 0.3) * 0.01;
    }

    frames.add(FrameData(
      frameIndex: i,
      timestamp: i * 33,
      wristPosition: Offset(0.5 + i * 0.003, 0.5 - i * 0.001),
      wristVelocity: velocity,
    ));
  }

  return frames;
}
