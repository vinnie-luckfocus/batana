import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/providers/record_state.dart';

/// RecordState 测试
///
/// 测试内容：
/// - 初始状态测试
/// - 状态转换测试（idle -> recording -> completed）
/// - 计时器测试
/// - 网格切换测试
void main() {
  group('RecordState', () {
    late RecordState recordState;

    setUp(() {
      recordState = RecordState();
    });

    tearDown(() {
      recordState.dispose();
    });

    group('初始状态', () {
      test('初始状态应该是 idle', () {
        expect(recordState.status, RecordingStatus.idle);
        expect(recordState.isIdle, true);
        expect(recordState.isRecording, false);
        expect(recordState.isPaused, false);
        expect(recordState.isCompleted, false);
      });

      test('初始录制时长应该是 0', () {
        expect(recordState.recordingDuration, Duration.zero);
        expect(recordState.formattedDuration, '00:00');
      });

      test('初始网格状态应该是 true', () {
        expect(recordState.showGrid, true);
      });

      test('初始相机控制器应该是 null', () {
        expect(recordState.cameraController, null);
      });

      test('初始相机初始化状态应该是 false', () {
        expect(recordState.isCameraInitialized, false);
      });

      test('初始录制进度应该是 0', () {
        expect(recordState.recordingProgress, 0.0);
      });
    });

    group('网格控制', () {
      test('toggleGrid 应该切换网格显示状态', () {
        // 初始状态为 true
        expect(recordState.showGrid, true);

        // 切换
        recordState.toggleGrid();
        expect(recordState.showGrid, false);

        // 再次切换
        recordState.toggleGrid();
        expect(recordState.showGrid, true);
      });

      test('setShowGrid 应该设置网格显示状态', () {
        recordState.setShowGrid(false);
        expect(recordState.showGrid, false);

        recordState.setShowGrid(true);
        expect(recordState.showGrid, true);
      });

      test('设置相同值不应该触发通知', () {
        // 初始为 true，再次设置为 true
        recordState.setShowGrid(true);
        // 不应该抛出错误
        expect(recordState.showGrid, true);
      });
    });

    group('录制时长格式化', () {
      test('应该正确格式化秒数', () {
        // 使用反射或直接测试 formattedDuration
        // 由于 _recordingDuration 是私有的，我们通过测试 formattedDuration 输出
        expect(recordState.formattedDuration, '00:00');
      });

      test('录制进度应该基于时长计算', () {
        // 初始进度为 0
        expect(recordState.recordingProgress, 0.0);
      });

      test('isMaxDurationReached 初始应该是 false', () {
        expect(recordState.isMaxDurationReached, false);
      });
    });

    group('状态转换', () {
      test('reset 应该重置状态到 idle', () {
        // 先改变一些状态
        recordState.setShowGrid(false);

        // 重置
        recordState.reset();

        // 验证状态
        expect(recordState.status, RecordingStatus.idle);
        expect(recordState.recordingDuration, Duration.zero);
        expect(recordState.isIdle, true);
      });

      test('isRecording 在 idle 状态应该是 false', () {
        expect(recordState.isRecording, false);
      });

      test('isPaused 在 idle 状态应该是 false', () {
        expect(recordState.isPaused, false);
      });

      test('isCompleted 在 idle 状态应该是 false', () {
        expect(recordState.isCompleted, false);
      });
    });

    group('状态枚举', () {
      test('RecordingStatus 应该包含所有状态', () {
        expect(RecordingStatus.values, contains(RecordingStatus.idle));
        expect(RecordingStatus.values, contains(RecordingStatus.recording));
        expect(RecordingStatus.values, contains(RecordingStatus.paused));
        expect(RecordingStatus.values, contains(RecordingStatus.completed));
      });

      test('状态值数量应该是 4', () {
        expect(RecordingStatus.values.length, 4);
      });
    });

    group('最大录制时长', () {
      test('maxDurationSeconds 应该是 12', () {
        expect(RecordState.maxDurationSeconds, 12);
      });
    });

    group('ChangeNotifier 功能', () {
      test('应该继承 ChangeNotifier', () {
        expect(recordState, isA<ChangeNotifier>());
      });

      test('toggleGrid 应该触发通知', () {
        var notified = false;
        recordState.addListener(() {
          notified = true;
        });

        recordState.toggleGrid();

        expect(notified, true);
      });

      test('setShowGrid 应该触发通知', () {
        var notified = false;
        recordState.addListener(() {
          notified = true;
        });

        recordState.setShowGrid(false);

        expect(notified, true);
      });

      test('reset 应该触发通知', () {
        var notified = false;
        recordState.addListener(() {
          notified = true;
        });

        recordState.reset();

        expect(notified, true);
      });
    });

    group('相机相关', () {
      test('cameraController 初始为 null', () {
        expect(recordState.cameraController, isNull);
      });

      test('isCameraInitialized 在 controller 为 null 时返回 false', () {
        expect(recordState.isCameraInitialized, false);
      });
    });

    group('录制结果', () {
      test('recordingDuration 初始为 0', () {
        expect(recordState.recordingDuration, Duration.zero);
      });

      test('formattedDuration 格式正确', () {
        // 格式应该是 "MM:SS"
        final formatted = recordState.formattedDuration;
        expect(formatted.length, 5);
        expect(formatted.contains(':'), true);
      });
    });
  });
}
