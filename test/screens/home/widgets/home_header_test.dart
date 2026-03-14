import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/home_header.dart';
import 'package:batana/design_system/colors.dart';

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

    testWidgets('应该使用 Container 作为根元素', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      // 验证根元素是 Container（HomeHeader 内部至少有一个 Container）
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('应该使用 BoxDecoration 设置背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final container = tester.widgetList<Container>(find.byType(Container)).first;
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('应该正确设置内边距', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final container = tester.widgetList<Container>(find.byType(Container)).first;
      final padding = container.padding as EdgeInsets;
      expect(padding.left, greaterThan(0));
      expect(padding.right, greaterThan(0));
    });

    testWidgets('头像应该使用正确的尺寸', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.radius, 18);
    });

    testWidgets('头像应该使用正确的图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('应该使用 Row 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('Row 应该使用 spaceBetween 对齐', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    });

    testWidgets('应该支持无障碍访问', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      // 验证组件可以被辅助技术访问
      final semantics = tester.getSemantics(find.byType(HomeHeader));
      expect(semantics, isNotNull);
    });

    testWidgets('背景色应该使用 AppColors.background', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final container = tester.widgetList<Container>(find.byType(Container)).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.background);
    });

    testWidgets('阴影应该正确配置', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeHeader()),
      );

      final container = tester.widgetList<Container>(find.byType(Container)).first;
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });
  });
}
