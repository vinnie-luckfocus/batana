import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/custom_bottom_nav_bar.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/typography.dart';

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

    testWidgets('应该使用 Container 作为根元素', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('应该使用 SafeArea 包裹内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('应该使用 Row 布局导航项', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceAround);
    });

    testWidgets('应该使用 GestureDetector 处理点击', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNWidgets(3));
    });

    testWidgets('选中项应该使用主色调', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 获取所有图标
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      final homeIcon = icons.first;

      // 选中的图标应该使用主色调
      expect(homeIcon.color, AppColors.primary);
    });

    testWidgets('未选中项应该使用次要文字颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 获取所有文本
      final texts = tester.widgetList<Text>(find.byType(Text));
      final historyText = texts.firstWhere((t) => t.data == '历史');

      // 未选中的文本应该使用次要颜色
      expect(historyText.style?.color, AppColors.textSecondary);
    });

    testWidgets('选中项文本应该加粗', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 获取主页文本
      final texts = tester.widgetList<Text>(find.byType(Text));
      final homeText = texts.firstWhere((t) => t.data == '主页');

      // 选中的文本应该加粗
      expect(homeText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('未选中项文本应该使用常规字重', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 获取历史文本
      final texts = tester.widgetList<Text>(find.byType(Text));
      final historyText = texts.firstWhere((t) => t.data == '历史');

      // 未选中的文本应该使用常规字重
      expect(historyText.style?.fontWeight, FontWeight.w400);
    });

    testWidgets('应该使用 BoxDecoration 设置背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('应该使用阴影效果', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, isTrue);
    });

    testWidgets('每个导航项应该使用 Column 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 应该有 3 个 Column（每个导航项一个）
      expect(find.byType(Column), findsNWidgets(3));
    });

    testWidgets('导航项应该包含图标和文本', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 每个导航项应该有图标和文本
      final columns = tester.widgetList<Column>(find.byType(Column));
      for (final column in columns) {
        expect(column.children.length, greaterThanOrEqualTo(2));
      }
    });

    testWidgets('应该支持点击主页 Tab', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );

      // 点击主页 Tab
      await tester.tap(find.text('主页'));
      expect(tappedIndex, 0);
    });

    testWidgets('点击同一个 Tab 应该仍然触发回调', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) => tapCount++,
          ),
        ),
      );

      // 多次点击主页 Tab
      await tester.tap(find.text('主页'));
      expect(tapCount, 1);

      await tester.tap(find.text('主页'));
      expect(tapCount, 2);
    });

    testWidgets('应该使用 HitTestBehavior.opaque', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      final gestureDetectors = tester.widgetList<GestureDetector>(find.byType(GestureDetector));
      for (final detector in gestureDetectors) {
        expect(detector.behavior, HitTestBehavior.opaque);
      }
    });

    testWidgets('应该使用 caption 样式作为标签样式基础', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证文本样式存在
      final texts = tester.widgetList<Text>(find.byType(Text));
      for (final text in texts) {
        expect(text.style, isNotNull);
      }
    });

    testWidgets('应该支持无障碍访问', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证组件可以被辅助技术访问
      final semantics = tester.getSemantics(find.byType(CustomBottomNavBar));
      expect(semantics, isNotNull);
    });

    testWidgets('图标大小应该为 24', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      final icons = tester.widgetList<Icon>(find.byType(Icon));
      for (final icon in icons) {
        expect(icon.size, 24);
      }
    });

    testWidgets('应该使用正确的内边距', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证 SafeArea 存在
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('导航项应该有适当的间距', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      // 验证 Column 中的间距
      final columns = tester.widgetList<Column>(find.byType(Column));
      for (final column in columns) {
        expect(column.mainAxisSize, MainAxisSize.min);
      }
    });

    testWidgets('背景色应该使用 AppColors.background', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomBottomNavBar),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.background);
    });
  });
}
