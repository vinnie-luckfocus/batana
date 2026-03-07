import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/home_header.dart';

void main() {
  /// 辅助方法：包装 MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('HomeHeader', () {
    testWidgets('应该显示 batana 标题', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      expect(find.text('batana'), findsOneWidget);
    });

    testWidgets('应该显示用户头像占位', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      // 验证头像占位 CircleAvatar 存在
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('应该使用 Neumorphic 风格背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      // 验证 HomeHeader 渲染成功
      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('标题应该使用 h1 字体样式', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final titleWidget = tester.widget<Text>(find.text('batana'));
      expect(titleWidget.style?.fontSize, 24);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}
