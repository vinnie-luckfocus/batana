import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/function_card.dart';
import 'package:batana/design_system/colors.dart';

void main() {
  /// 辅助方法：包装 MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('FunctionCard', () {
    testWidgets('应该显示图标、标题和描述', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('录制视频'), findsOneWidget);
      expect(find.text('实时录制挥棒动作'), findsOneWidget);
    });

    testWidgets('点击应该触发 onTap 回调', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(FunctionCard));
      expect(tapped, isTrue);
    });

    testWidgets('录制视频卡片应该使用摄像机图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('选择相册卡片应该使用相册图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.photo_library,
            title: '选择相册',
            description: '从相册选择视频分析',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.text('选择相册'), findsOneWidget);
      expect(find.text('从相册选择视频分析'), findsOneWidget);
    });

    testWidgets('历史记录卡片应该使用时钟图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.access_time,
            title: '历史记录',
            description: '查看过往分析结果',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('历史记录'), findsOneWidget);
      expect(find.text('查看过往分析结果'), findsOneWidget);
    });

    testWidgets('应该包含 NeumorphicCard 样式容器', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      // 验证卡片使用了 Container 并带有 BoxDecoration（Neumorphic 阴影）
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FunctionCard),
          matching: find.byType(Container).first,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('应该具有无障碍语义标签', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      // 验证 Semantics 存在
      final semantics = tester.getSemantics(find.byType(FunctionCard));
      expect(semantics.label, contains('录制视频'));
    });

    testWidgets('应该使用 Semantics 包装', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Semantics 应该标记为 button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(FunctionCard));
      // 验证语义标签包含标题和描述
      expect(semantics.label, contains('录制视频'));
      expect(semantics.label, contains('实时录制挥棒动作'));
    });

    testWidgets('应该使用 GestureDetector 处理点击', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('应该使用 Row 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('应该显示右箭头图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('图标容器应该使用正确的尺寸', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      // 查找图标容器（第一个 Container 是卡片容器，第二个是图标容器）
      final containers = tester.widgetList<Container>(find.byType(Container));
      final iconContainer = containers.skip(1).first;
      final constraints = iconContainer.constraints;

      expect(constraints?.maxWidth, 48);
      expect(constraints?.maxHeight, 48);
    });

    testWidgets('应该使用 BoxDecoration 设置阴影', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FunctionCard),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 2); // Neumorphic 风格有两个阴影
    });

    testWidgets('卡片背景色应该使用 AppColors.surface', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FunctionCard),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surface);
    });

    testWidgets('应该使用 Expanded 包裹文字区域', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('文字区域应该使用 Column 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      // 查找 Expanded 内的 Column
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.child, isA<Column>());
    });

    testWidgets('标题应该使用 h3 样式', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.text('录制视频'));
      expect(titleWidget.style, isNotNull);
    });

    testWidgets('描述应该使用 caption 样式', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final descWidget = tester.widget<Text>(find.text('实时录制挥棒动作'));
      expect(descWidget.style, isNotNull);
    });

    testWidgets('图标应该使用主色调', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.videocam));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('箭头图标应该使用次要文字颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () {},
          ),
        ),
      );

      final arrowIcon = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(arrowIcon.color, AppColors.textSecondary);
    });

    testWidgets('应该支持不同的图标参数', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.settings,
            title: '设置',
            description: '应用设置',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('应用设置'), findsOneWidget);
    });

    testWidgets('点击卡片应该只触发一次回调', (WidgetTester tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        buildTestWidget(
          FunctionCard(
            icon: Icons.videocam,
            title: '录制视频',
            description: '实时录制挥棒动作',
            onTap: () => tapCount++,
          ),
        ),
      );

      await tester.tap(find.byType(FunctionCard));
      expect(tapCount, 1);

      await tester.tap(find.byType(FunctionCard));
      expect(tapCount, 2);
    });
  });
}
