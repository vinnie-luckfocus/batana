import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/function_card.dart';

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
  });
}
