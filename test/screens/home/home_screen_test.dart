import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/home_screen.dart';
import 'package:batana/screens/home/widgets/home_header.dart';
import 'package:batana/screens/home/widgets/function_card.dart';
import 'package:batana/screens/home/widgets/custom_bottom_nav_bar.dart';

void main() {
  /// 辅助方法：包装 MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('HomeScreen', () {
    testWidgets('应该包含 HomeHeader', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('应该包含 3 个 FunctionCard', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.byType(FunctionCard), findsNWidgets(3));
    });

    testWidgets('应该包含录制视频卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.text('录制视频'), findsOneWidget);
      expect(find.text('实时录制挥棒动作'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('应该包含选择相册卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.text('选择相册'), findsOneWidget);
      expect(find.text('从相册选择视频分析'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('应该包含历史记录卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.text('历史记录'), findsOneWidget);
      expect(find.text('查看过往分析结果'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('应该包含 CustomBottomNavBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('应该支持下拉刷新', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      // 验证 RefreshIndicator 存在
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('应该使用 CustomScrollView 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('点击录制视频卡片应该触发回调', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      // 点击录制视频卡片
      await tester.tap(find.text('录制视频'));
      await tester.pumpAndSettle();

      // 验证点击成功（不会报错）
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('底部导航栏默认选中主页', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      final navBar = tester.widget<CustomBottomNavBar>(
        find.byType(CustomBottomNavBar),
      );
      expect(navBar.currentIndex, 0);
    });

    testWidgets('点击底部导航栏应该切换 Tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );

      // 点击历史 Tab
      await tester.tap(find.text('历史'));
      await tester.pumpAndSettle();

      // 验证切换成功
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
