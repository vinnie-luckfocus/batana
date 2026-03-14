import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../lib/screens/record/record_screen.dart';
import '../../../lib/providers/record_state.dart';
import '../../../lib/screens/record/widgets/camera_preview_widget.dart';
import '../../../lib/screens/record/widgets/recording_controls.dart';

/// RecordScreen Widget 测试
///
/// 测试内容：
/// - RecordScreen 渲染测试
/// - 顶部栏组件存在性测试
/// - 录制按钮点击测试
/// - 网格开关切换测试
/// - 返回按钮存在性测试
void main() {
  group('RecordScreen', () {
    /// 包装 widget 以提供必要的依赖
    Widget _buildTestableWidget(Widget child) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets('应该正确渲染 RecordScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      // 等待初始化
      await tester.pump();

      // 验证 Scaffold 存在
      expect(find.byType(Scaffold), findsOneWidget);

      // 验证背景为黑色
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('应该显示相机预览组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证 CameraPreviewWidget 存在
      expect(find.byType(CameraPreviewWidget), findsOneWidget);
    });

    testWidgets('应该显示顶部栏组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证返回按钮存在（通过图标查找）
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // 验证网格开关存在
      expect(find.byIcon(Icons.grid_on), findsOneWidget);
    });

    testWidgets('应该显示录制控制组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证 RecordingControls 存在
      expect(find.byType(RecordingControls), findsOneWidget);
    });

    testWidgets('点击网格开关应该切换图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 初始状态应该显示 grid_on（默认显示网格）
      expect(find.byIcon(Icons.grid_on), findsOneWidget);

      // 点击网格开关
      await tester.tap(find.byIcon(Icons.grid_on));
      await tester.pump();

      // 点击后应该显示 grid_off
      expect(find.byIcon(Icons.grid_off), findsOneWidget);
    });

    testWidgets('返回按钮应该存在', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证返回按钮存在
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('应该显示录制时长', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证时长显示存在（格式 "00:00"）
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('未录制时应该显示提示文字', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证提示文字存在
      expect(find.text('保持设备稳定，录制 5-10 秒'), findsOneWidget);
    });

    testWidgets('应该使用 ChangeNotifierProvider 提供 RecordState', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证 Provider 存在
      expect(find.byType(ChangeNotifierProvider<RecordState>), findsOneWidget);
    });

    testWidgets('应该显示录制按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证录制控制区域存在
      expect(find.byType(RecordingControls), findsOneWidget);
    });

    testWidgets('应该使用 Stack 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证 Stack 存在（可能有多个，包括内部组件使用的）
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('顶部栏应该有 SafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证 SafeArea 存在（顶部栏使用）
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('录制时长显示应该有正确的样式', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 查找包含 "00:00" 的 Text widget
      final textWidget = tester.widget<Text>(find.text('00:00'));

      // 验证文字样式
      expect(textWidget.style, isNotNull);
    });

    testWidgets('应该包含 Positioned 组件用于布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestableWidget(const RecordScreen()),
      );

      await tester.pump();

      // 验证 Positioned 组件存在（用于顶部栏和底部控制）
      expect(find.byType(Positioned), findsAtLeastNWidgets(2));
    });
  });
}
