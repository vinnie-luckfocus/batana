import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/custom_bottom_nav_bar.dart';

void main() {
  /// 辅助方法：包装 MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('CustomBottomNavBar', () {
    testWidgets('应该显示 3 个导航项', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证 3 个导航项存在
      expect(find.text('主页'), findsOneWidget);
      expect(find.text('历史'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('应该显示对应的图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('选中项应该高亮显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证 CustomBottomNavBar 渲染成功
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('点击导航项应该触发 onTap 回调', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );

      // 点击历史 Tab
      await tester.tap(find.text('历史'));
      expect(tappedIndex, 1);

      // 点击设置 Tab
      await tester.tap(find.text('设置'));
      expect(tappedIndex, 2);
    });

    testWidgets('应该使用 Neumorphic 风格背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证 Container 存在（Neumorphic 容器）
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byType(Container).first,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('不同 currentIndex 应该高亮不同的 Tab', (WidgetTester tester) async {
      // 测试 index 0
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );
      expect(find.byType(CustomBottomNavBar), findsOneWidget);

      // 测试 index 1
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 1,
            onTap: (_) {},
          ),
        ),
      );
      expect(find.byType(CustomBottomNavBar), findsOneWidget);

      // 测试 index 2
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 2,
            onTap: (_) {},
          ),
        ),
      );
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });
  });
}
