import 'package:flutter_test/flutter_test.dart';
import 'package:batana/scoring/scoring_engine.dart';
import 'package:batana/scoring/problem_detector.dart';
import 'package:batana/analysis/metrics_calculator.dart';

void main() {
  group('ScoringEngine', () {
    late ScoringEngine scoringEngine;

    setUp(() {
      scoringEngine = ScoringEngine();
    });

    group('calculate', () {
      test('should calculate total score with valid metrics', () {
        const metrics = SwingMetrics(
          velocity: 20.0,
          velocityLevel: '中',
          maxAngle: 45.0,
          hipShoulderDelay: 50.0,
          transferSmoothness: 0.8,
        );

        final result = scoringEngine.calculate(metrics);

        expect(result.totalScore, greaterThanOrEqualTo(0));
        expect(result.totalScore, lessThanOrEqualTo(100));
        expect(result.velocityScore, greaterThanOrEqualTo(0));
        expect(result.velocityScore, lessThanOrEqualTo(100));
        expect(result.angleScore, greaterThanOrEqualTo(0));
        expect(result.angleScore, lessThanOrEqualTo(100));
        expect(result.coordinationScore, greaterThanOrEqualTo(0));
        expect(result.coordinationScore, lessThanOrEqualTo(100));
      });

      test('should detect problems from metrics', () {
        // 速度不足的角度问题
        const metrics = SwingMetrics(
          velocity: 5.0,
          velocityLevel: '慢',
          maxAngle: 20.0,
          hipShoulderDelay: -50.0,
          transferSmoothness: 0.2,
        );

        final result = scoringEngine.calculate(metrics);

        expect(result.problems, isNotEmpty);
        expect(result.problems, contains(ProblemType.insufficientSpeed));
      });

      test('should generate suggestions for detected problems', () {
        const metrics = SwingMetrics(
          velocity: 5.0,
          velocityLevel: '慢',
          maxAngle: 20.0,
          hipShoulderDelay: -50.0,
          transferSmoothness: 0.2,
        );

        final result = scoringEngine.calculate(metrics);

        expect(result.suggestions, isNotEmpty);
        expect(result.suggestions.first, isNotEmpty);
      });

      test('should return positive feedback when no problems', () {
        const metrics = SwingMetrics(
          velocity: 25.0,
          velocityLevel: '快',
          maxAngle: 45.0,
          hipShoulderDelay: 100.0,
          transferSmoothness: 0.9,
        );

        final result = scoringEngine.calculate(metrics);

        expect(result.hasProblems, isFalse);
        expect(result.suggestions, isNotEmpty);
      });
    });

    group('ScoringEngineConfig', () {
      test('default config should have correct values', () {
        const config = ScoringEngineConfig();
        expect(config.velocityWeight, equals(0.35));
        expect(config.angleWeight, equals(0.35));
        expect(config.coordinationWeight, equals(0.30));
        expect(config.velocityMin, equals(10.0));
        expect(config.velocityMax, equals(30.0));
        expect(config.angleMin, equals(20.0));
        expect(config.angleMax, equals(70.0));
      });

      test('isValid should return true when weights sum to 1', () {
        const config = ScoringEngineConfig();
        expect(config.isValid, isTrue);
      });

      test('isValid should return false when weights do not sum to 1', () {
        const config = ScoringEngineConfig(
          velocityWeight: 0.5,
          angleWeight: 0.3,
          coordinationWeight: 0.3,
        );
        expect(config.isValid, isFalse);
      });

      test('custom config should override default values', () {
        const config = ScoringEngineConfig(
          velocityWeight: 0.4,
          velocityMin: 15.0,
          velocityMax: 35.0,
        );
        expect(config.velocityWeight, equals(0.4));
        expect(config.velocityMin, equals(15.0));
        expect(config.velocityMax, equals(35.0));
      });
    });
  });

  group('ScoringResult', () {
    test('should create ScoringResult with required parameters', () {
      const result = ScoringResult(
        totalScore: 85,
        velocityScore: 90.0,
        angleScore: 80.0,
        coordinationScore: 85.0,
        problems: [],
        suggestions: ['继续保持'],
      );

      expect(result.totalScore, equals(85));
      expect(result.velocityScore, equals(90.0));
      expect(result.angleScore, equals(80.0));
      expect(result.coordinationScore, equals(85.0));
    });

    test('grade should return correct grade for score ranges', () {
      expect(_createResultWithScore(95).grade, equals('优秀'));
      expect(_createResultWithScore(80).grade, equals('良好'));
      expect(_createResultWithScore(65).grade, equals('及格'));
      expect(_createResultWithScore(50).grade, equals('需改进'));
    });

    test('hasProblems should return correct value', () {
      const resultWithProblems = ScoringResult(
        totalScore: 50,
        velocityScore: 40.0,
        angleScore: 50.0,
        coordinationScore: 60.0,
        problems: [ProblemType.insufficientSpeed],
        suggestions: [],
      );
      expect(resultWithProblems.hasProblems, isTrue);

      const resultWithoutProblems = ScoringResult(
        totalScore: 90,
        velocityScore: 95.0,
        angleScore: 85.0,
        coordinationScore: 90.0,
        problems: [],
        suggestions: ['继续保持'],
      );
      expect(resultWithoutProblems.hasProblems, isFalse);
    });

    test('toString should contain key information', () {
      const result = ScoringResult(
        totalScore: 85,
        velocityScore: 90.0,
        angleScore: 80.0,
        coordinationScore: 85.0,
        problems: [],
        suggestions: ['继续保持'],
      );

      final str = result.toString();
      expect(str, contains('85'));
      expect(str, contains('速度'));
      expect(str, contains('角度'));
    });
  });

  group('SuggestionGenerator', () {
    late SuggestionGenerator generator;

    setUp(() {
      generator = SuggestionGenerator();
    });

    test('should generate suggestions for early shoulder problem', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: -150.0, // 严重的过早开肩
        transferSmoothness: 0.5,
      );

      final suggestions = generator.generateSuggestions(
        metrics,
        [ProblemType.earlyShoulder],
      );

      expect(suggestions, isNotEmpty);
      expect(suggestions.first, isNotEmpty);
    });

    test('should generate suggestions for insufficient speed', () {
      const metrics = SwingMetrics(
        velocity: 3.0, // 非常慢
        velocityLevel: '慢',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.5,
      );

      final suggestions = generator.generateSuggestions(
        metrics,
        [ProblemType.insufficientSpeed],
      );

      expect(suggestions, isNotEmpty);
    });

    test('should generate suggestions for angle too small', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 15.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );

      final suggestions = generator.generateSuggestions(
        metrics,
        [ProblemType.angleTooSmall],
      );

      expect(suggestions, isNotEmpty);
    });

    test('should generate suggestions for angle too large', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 80.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );

      final suggestions = generator.generateSuggestions(
        metrics,
        [ProblemType.angleTooLarge],
      );

      expect(suggestions, isNotEmpty);
    });

    test('should generate suggestions for poor coordination', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.1, // 非常不流畅
      );

      final suggestions = generator.generateSuggestions(
        metrics,
        [ProblemType.poorCoordination],
      );

      expect(suggestions, isNotEmpty);
    });

    test('should not generate duplicate suggestions', () {
      const metrics = SwingMetrics(
        velocity: 3.0,
        velocityLevel: '慢',
        maxAngle: 15.0,
        hipShoulderDelay: -50.0,
        transferSmoothness: 0.1,
      );

      final suggestions = generator.generateSuggestions(
        metrics,
        [
          ProblemType.insufficientSpeed,
          ProblemType.angleTooSmall,
          ProblemType.poorCoordination,
        ],
      );

      // 检查是否有重复建议
      final uniqueSuggestions = suggestions.toSet();
      expect(suggestions.length, equals(uniqueSuggestions.length));
    });

    test('should return positive feedback when no problems', () {
      const metrics = SwingMetrics(
        velocity: 25.0,
        velocityLevel: '快',
        maxAngle: 45.0,
        hipShoulderDelay: 100.0,
        transferSmoothness: 0.9,
      );

      final suggestions = generator.generateSuggestions(metrics, []);

      expect(suggestions, isNotEmpty);
      expect(
        suggestions.first.contains('优秀') || suggestions.first.contains('保持'),
        isTrue,
      );
    });
  });

  group('ProblemDetector', () {
    late ProblemDetector detector;

    setUp(() {
      detector = ProblemDetector();
    });

    test('should detect early shoulder problem', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: -50.0, // 肩部领先
        transferSmoothness: 0.8,
      );

      final problems = detector.detectProblems(metrics);

      expect(problems, contains(ProblemType.earlyShoulder));
    });

    test('should detect insufficient speed', () {
      const metrics = SwingMetrics(
        velocity: 5.0, // 低于默认值 10.0
        velocityLevel: '慢',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );

      final problems = detector.detectProblems(metrics);

      expect(problems, contains(ProblemType.insufficientSpeed));
    });

    test('should detect angle too small', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 20.0, // 低于默认值 30.0
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );

      final problems = detector.detectProblems(metrics);

      expect(problems, contains(ProblemType.angleTooSmall));
    });

    test('should detect angle too large', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 70.0, // 高于默认值 60.0
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.8,
      );

      final problems = detector.detectProblems(metrics);

      expect(problems, contains(ProblemType.angleTooLarge));
    });

    test('should detect poor coordination', () {
      const metrics = SwingMetrics(
        velocity: 20.0,
        velocityLevel: '中',
        maxAngle: 45.0,
        hipShoulderDelay: 50.0,
        transferSmoothness: 0.2, // 低于默认值 0.5
      );

      final problems = detector.detectProblems(metrics);

      expect(problems, contains(ProblemType.poorCoordination));
    });

    test('should detect multiple problems', () {
      const metrics = SwingMetrics(
        velocity: 5.0,
        velocityLevel: '慢',
        maxAngle: 20.0,
        hipShoulderDelay: -50.0,
        transferSmoothness: 0.2,
      );

      final problems = detector.detectProblems(metrics);

      expect(problems.length, greaterThan(1));
    });

    test('should not detect problems for good metrics', () {
      const metrics = SwingMetrics(
        velocity: 25.0,
        velocityLevel: '快',
        maxAngle: 45.0,
        hipShoulderDelay: 100.0,
        transferSmoothness: 0.9,
      );

      final problems = detector.detectProblems(metrics);

      expect(problems, isEmpty);
    });
  });

  group('ProblemType', () {
    test('should have all problem types', () {
      expect(ProblemType.values.length, equals(6));
      expect(ProblemType.values, contains(ProblemType.earlyShoulder));
      expect(ProblemType.values, contains(ProblemType.insufficientWeightShift));
      expect(ProblemType.values, contains(ProblemType.insufficientSpeed));
      expect(ProblemType.values, contains(ProblemType.angleTooSmall));
      expect(ProblemType.values, contains(ProblemType.angleTooLarge));
      expect(ProblemType.values, contains(ProblemType.poorCoordination));
    });

    test('description should return non-empty string', () {
      for (final problem in ProblemType.values) {
        expect(problem.description, isNotEmpty);
      }
    });

    test('severity should return positive integer', () {
      for (final problem in ProblemType.values) {
        expect(problem.severity, greaterThan(0));
      }
    });
  });

  group('ProblemDetectorConfig', () {
    test('default config should have correct values', () {
      const config = ProblemDetectorConfig();
      expect(config.minVelocity, equals(10.0));
      expect(config.minAngle, equals(30.0));
      expect(config.maxAngle, equals(60.0));
      expect(config.minCoordination, equals(0.5));
      expect(config.hipShoulderDelayThreshold, equals(0.0));
    });

    test('custom config should override default values', () {
      const config = ProblemDetectorConfig(
        minVelocity: 15.0,
        minAngle: 25.0,
        maxAngle: 65.0,
      );
      expect(config.minVelocity, equals(15.0));
      expect(config.minAngle, equals(25.0));
      expect(config.maxAngle, equals(65.0));
    });
  });
}

/// 创建带有特定总分的 ScoringResult 的辅助函数
ScoringResult _createResultWithScore(int score) {
  return ScoringResult(
    totalScore: score,
    velocityScore: score.toDouble(),
    angleScore: score.toDouble(),
    coordinationScore: score.toDouble(),
    problems: [],
    suggestions: [],
  );
}
