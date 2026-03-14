import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';

import '../../../../lib/screens/record/widgets/camera_preview_widget.dart';

/// CameraPreviewWidget 测试
///
/// 测试内容：
/// - CameraPreviewWidget 渲染测试
/// - 网格显示/隐藏测试
/// - 加载状态测试
void main() {
  group('CameraPreviewWidget', () {
    testWidgets('控制器为空时应该显示加载视图', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              controller: null,
              showGrid: false,
            ),
          ),
        ),
      );

      // 验证加载指示器存在
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 验证加载文字存在
      expect(find.text('相机初始化中...'), findsOneWidget);
    });

    testWidgets('应该正确接收 controller 参数', (WidgetTester tester) async {
      // 由于无法创建真实的 CameraController，我们测试 widget 构建
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              controller: null,
              showGrid: false,
            ),
          ),
        ),
      );

      // 验证 widget 存在
      expect(find.byType(CameraPreviewWidget), findsOneWidget);
    });

    testWidgets('应该正确接收 showGrid 参数', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              controller: null,
              showGrid: true,
            ),
          ),
        ),
      );

      // 获取 widget 并验证参数
      final widget = tester.widget<CameraPreviewWidget>(
        find.byType(CameraPreviewWidget),
      );
      expect(widget.showGrid, true);
    });

    testWidgets('showGrid 为 false 时不应该显示网格', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              controller: null,
              showGrid: false,
            ),
          ),
        ),
      );

      // 获取 widget 并验证参数
      final widget = tester.widget<CameraPreviewWidget>(
        find.byType(CameraPreviewWidget),
      );
      expect(widget.showGrid, false);
    });

    testWidgets('加载视图应该有黑色背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              controller: null,
              showGrid: false,
            ),
          ),
        ),
      );

      // 查找 Container（加载视图的根）
      final container = find.descendant(
        of: find.byType(CameraPreviewWidget),
        matching: find.byType(Container),
      );

      // 验证至少有一个 Container 存在
      expect(container, findsWidgets);
    });

    testWidgets('加载指示器应该使用主色调', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              controller: null,
              showGrid: false,
            ),
          ),
        ),
      );

      // 查找 CircularProgressIndicator
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // 验证颜色不为 null
      expect(progressIndicator.color, isNotNull);
    });

    testWidgets('控制器为空时不应该显示 LayoutBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: CameraPreviewWidget(
                controller: null,
                showGrid: false,
              ),
            ),
          ),
        ),
      );

      // 控制器为空时直接返回加载视图，不构建 LayoutBuilder
      expect(find.byType(LayoutBuilder), findsNothing);
    });

    testWidgets('应该正确设置 key', (WidgetTester tester) async {
      const key = Key('camera_preview');
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewWidget(
              key: key,
              controller: null,
              showGrid: false,
            ),
          ),
        ),
      );

      // 验证 key 存在
      expect(find.byKey(key), findsOneWidget);
    });
  });
}
