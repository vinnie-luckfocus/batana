import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/design_system/widgets/cards.dart' as custom;

void main() {
  group('NeumorphicCard', () {
    testWidgets('应该渲染基本卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: custom.NeumorphicCard(
              child: Text('测试卡片'),
            ),
          ),
        ),
      );

      expect(find.text('测试卡片'), findsOneWidget);
      expect(find.byType(custom.NeumorphicCard), findsOneWidget);
    });

    group('内边距测试', () {
      testWidgets('标准内边距应该是 16pt', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                padding: custom.CardPadding.standard,
                child: Text('Standard Padding'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.padding, custom.CardPadding.standard);
      });

      testWidgets('宽松内边距应该是 24pt', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                padding: custom.CardPadding.relaxed,
                child: Text('Relaxed Padding'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.padding, custom.CardPadding.relaxed);
      });

      testWidgets('应该支持自定义内边距', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(32.0);
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                customPadding: customPadding,
                child: Text('Custom Padding'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.customPadding, customPadding);
      });
    });

    group('阴影深度测试', () {
      testWidgets('默认阴影深度应该是 Depth 2', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                child: Text('Default Depth'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.depth, 2.0);
      });

      testWidgets('应该支持自定义阴影深度', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                depth: 3.0,
                child: Text('Custom Depth'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.depth, 3.0);
      });
    });

    group('头部图片测试', () {
      testWidgets('应该支持头部图片', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                headerImage: Container(
                  height: 200,
                  color: Colors.blue,
                ),
                child: const Text('With Header'),
              ),
            ),
          ),
        );

        expect(find.byType(custom.NeumorphicCard), findsOneWidget);
        expect(find.text('With Header'), findsOneWidget);
      });

      testWidgets('没有头部图片时应该正常渲染', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                child: Text('No Header'),
              ),
            ),
          ),
        );

        expect(find.byType(custom.NeumorphicCard), findsOneWidget);
        expect(find.text('No Header'), findsOneWidget);
      });
    });

    group('布局测试', () {
      testWidgets('应该支持标题', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                title: Text('Card Title'),
                child: Text('Card Content'),
              ),
            ),
          ),
        );

        expect(find.text('Card Title'), findsOneWidget);
        expect(find.text('Card Content'), findsOneWidget);
      });

      testWidgets('应该支持操作区', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                child: const Text('Card Content'),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Action 1'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Action 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Card Content'), findsOneWidget);
        expect(find.text('Action 1'), findsOneWidget);
        expect(find.text('Action 2'), findsOneWidget);
      });

      testWidgets('完整布局：标题 + 内容 + 操作区', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                title: const Text('Complete Card'),
                child: const Text('This is the content'),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Complete Card'), findsOneWidget);
        expect(find.text('This is the content'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
      });
    });

    group('自定义属性测试', () {
      testWidgets('应该支持自定义圆角', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                borderRadius: 16.0,
                child: Text('Custom Radius'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.borderRadius, 16.0);
      });

      testWidgets('应该支持自定义背景色', (WidgetTester tester) async {
        const customColor = Colors.amber;
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                color: customColor,
                child: Text('Custom Color'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.color, customColor);
      });

      testWidgets('应该支持自定义宽度', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicCard(
                width: 300,
                child: Text('Custom Width'),
              ),
            ),
          ),
        );

        final card = tester.widget<custom.NeumorphicCard>(find.byType(custom.NeumorphicCard));
        expect(card.width, 300);
      });
    });
  });
}
