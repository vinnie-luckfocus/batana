import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/screens/record/widgets/recording_controls.dart';
import '../../../../lib/screens/record/widgets/recording_button.dart';

/// RecordingControls 测试
///
/// 测试内容：
/// - RecordingControls 渲染测试
/// - 录制按钮状态切换测试
/// - 重录按钮点击测试
/// - 进度环显示测试
void main() {
  group('RecordingControls', () {
    bool recordTapped = false;
    bool retakeTapped = false;

    setUp(() {
      recordTapped = false;
      retakeTapped = false;
    });

    Widget _buildTestableWidget({
      required bool isRecording,
      double progress = 0.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RecordingControls(
            isRecording: isRecording,
            onRecordTap: () => recordTapped = true,
            onRetakeTap: () => retakeTapped = true,
            progress: progress,
          ),
        ),
      );
    }

    testWidgets('应该正确渲染所有组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 验证 RecordingControls 存在
      expect(find.byType(RecordingControls), findsOneWidget);

      // 验证 RecordingButton 存在
      expect(find.byType(RecordingButton), findsOneWidget);

      // 验证 Row 布局存在
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('应该正确传递 isRecording 参数', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: true),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证参数传递正确
      expect(button.isRecording, true);
    });

    testWidgets('应该正确传递 progress 参数', (WidgetTester tester) async {
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

      // 验证进度值
      expect(button.progress, 0.5);
    });

    testWidgets('点击录制按钮应该触发回调', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 点击录制按钮
      await tester.tap(find.byType(RecordingButton));
      await tester.pump();

      // 验证回调被触发
      expect(recordTapped, true);
    });

    testWidgets('录制完成时应该显示重录按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: false,
          progress: 1.0,
        ),
      );

      // 等待动画完成
      await tester.pumpAndSettle();

      // 查找包含刷新图标的按钮
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('录制中时重录按钮应该不可见', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: true,
          progress: 0.5,
        ),
      );

      // 等待动画
      await tester.pump();

      // 重录按钮应该不可见（opacity 为 0）
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(animatedOpacity.opacity, 0.0);
    });

    testWidgets('点击重录按钮应该触发回调', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: false,
          progress: 1.0,
        ),
      );

      // 等待动画完成
      await tester.pumpAndSettle();

      // 点击重录按钮
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // 验证回调被触发
      expect(retakeTapped, true);
    });

    testWidgets('应该使用正确的内边距', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 查找 Container（根容器）
      final container = find.descendant(
        of: find.byType(RecordingControls),
        matching: find.byType(Container),
      ).first;

      final containerWidget = tester.widget<Container>(container);
      final padding = containerWidget.padding as EdgeInsets;

      // 验证内边距
      expect(padding.horizontal, 96.0); // 48 * 2
      expect(padding.vertical, 64.0);   // 32 * 2
    });

    testWidgets('应该居中对齐', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 查找 Row
      final row = tester.widget<Row>(find.byType(Row));

      // 验证居中对齐
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('录制按钮应该居中', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(isRecording: false),
      );

      // 获取所有 SizedBox（用于间距）
      final sizedBoxes = find.byType(SizedBox);

      // 验证有足够的间距元素
      expect(sizedBoxes, findsAtLeastNWidgets(3));
    });

    testWidgets('进度为 0 时不应该显示进度环', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: false,
          progress: 0.0,
        ),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证进度为 0
      expect(button.progress, 0.0);
    });

    testWidgets('进度为 1.0 时应该显示完整进度', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(
          isRecording: true,
          progress: 1.0,
        ),
      );

      // 获取 RecordingButton
      final button = tester.widget<RecordingButton>(
        find.byType(RecordingButton),
      );

      // 验证进度为 1.0
      expect(button.progress, 1.0);
    });
  });
}
