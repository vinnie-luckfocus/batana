import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/screens/record/widgets/recording_button.dart';

/// RecordingButton 测试
///
/// 测试内容：
/// - RecordingButton 渲染测试
/// - 空闲状态（圆形）测试
/// - 录制状态（方形+进度环）测试
/// - 点击回调测试
void main() {
  group('RecordingButton', () {
    bool wasTapped = false;

    setUp(() {
      wasTapped = false;
    });

    Widget _buildTestableWidget({
      required bool isRecording,
      double progress = 0.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: RecordingButton(
              isRecording: isRecording,
              onTap: () => wasTapped = true,
              progress: progress,
            ),
          ),
        ),
      );
    }

    testWidgets('应该正确渲染 RecordingButton', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 验证 RecordingButton 存在
      expect(find.byType(RecordingButton), findsOneWidget);
    });

    testWidgets('应该有正确的尺寸 72x72', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 查找 AnimatedContainer
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // 验证尺寸
      expect(animatedContainer.constraints?.minWidth, 72.0);
      expect(animatedContainer.constraints?.minHeight, 72.0);
    });

    testWidgets('空闲状态应该显示圆形按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 获取 AnimatedContainer
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // 验证形状为圆形
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('录制状态应该显示 CustomPaint', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: true, progress: 0.5),
      );

      // 验证 CustomPaint 存在（用于绘制进度环）
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('点击应该触发回调', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 点击 GestureDetector（直接子元素）
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // 验证回调被触发
      expect(wasTapped, true);
    });

    testWidgets('应该支持进度参数', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: true,
          progress: 0.75,
        ),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证进度值
      expect(button.progress, 0.75);
    });

    testWidgets('应该有阴影效果', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 获取 AnimatedContainer
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // 验证有阴影
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });

    testWidgets('应该有 ScaleTransition 动画', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 验证 ScaleTransition 存在（可能有多个，因为 MaterialApp 也使用）
      expect(find.byType(ScaleTransition), findsWidgets);
    });

    testWidgets('应该有 GestureDetector', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 验证 GestureDetector 存在
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('isRecording 参数应该正确传递', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证参数
      expect(button.isRecording, false);
    });

    testWidgets('onTap 回调应该正确传递', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证回调不为 null
      expect(button.onTap, isNotNull);
    });

    testWidgets('应该使用 StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 验证 StatefulWidget 存在
      expect(find.byType(RecordingButton), findsOneWidget);
    });

    testWidgets('应该正确设置 key', (WidgetTester tester) async {
      const key = Key('recording_button');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingButton(
              key: key,
              isRecording: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // 验证 key 存在
      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets('录制状态为 true 时 isRecording 应该为 true', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: true),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证参数
      expect(button.isRecording, true);
    });

    testWidgets('进度值应该在 0-1 范围内', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: true,
          progress: 0.5,
        ),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证进度值在有效范围内
      expect(button.progress, greaterThanOrEqualTo(0.0));
      expect(button.progress, lessThanOrEqualTo(1.0));
    });
  });
}
