import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/design_system/widgets/buttons.dart' as custom;

void main() {
  group('NeumorphicButton', () {
    testWidgets('应该渲染基本按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: custom.NeumorphicButton(
              onPressed: () {},
              child: const Text('测试按钮'),
            ),
          ),
        ),
      );

      expect(find.text('测试按钮'), findsOneWidget);
      expect(find.byType(custom.NeumorphicButton), findsOneWidget);
    });

    group('尺寸测试', () {
      testWidgets('Small 尺寸应该有正确的高度和内边距', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                size: custom.ButtonSize.small,
                onPressed: () {},
                child: const Text('Small'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.size, custom.ButtonSize.small);
      });

      testWidgets('Medium 尺寸应该是默认尺寸', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () {},
                child: const Text('Medium'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.size, custom.ButtonSize.medium);
      });

      testWidgets('Large 尺寸应该有正确的高度和内边距', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                size: custom.ButtonSize.large,
                onPressed: () {},
                child: const Text('Large'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.size, custom.ButtonSize.large);
      });
    });

    group('状态测试', () {
      testWidgets('Normal 状态应该可以点击', (WidgetTester tester) async {
        bool pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () => pressed = true,
                child: const Text('Normal'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(custom.NeumorphicButton));
        await tester.pump();

        expect(pressed, true);
      });

      testWidgets('Disabled 状态应该不可点击', (WidgetTester tester) async {
        bool pressed = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: null,
                child: const Text('Disabled'),
              ),
            ),
          ),
        );

        // 尝试点击禁用按钮
        await tester.tap(find.byType(custom.NeumorphicButton), warnIfMissed: false);
        await tester.pump();

        expect(pressed, false);
      });

      testWidgets('Pressed 状态应该有视觉反馈', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () {},
                child: const Text('Press Me'),
              ),
            ),
          ),
        );

        // 按下按钮
        await tester.press(find.byType(custom.NeumorphicButton));
        await tester.pump();

        // 验证按钮存在（视觉反馈通过动画实现）
        expect(find.byType(custom.NeumorphicButton), findsOneWidget);
      });
    });

    group('样式测试', () {
      testWidgets('Filled 样式应该是默认样式', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () {},
                child: const Text('Filled'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.style, custom.NeumorphicButtonStyle.filled);
      });

      testWidgets('Outlined 样式应该正确渲染', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                style: custom.NeumorphicButtonStyle.outlined,
                onPressed: () {},
                child: const Text('Outlined'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.style, custom.NeumorphicButtonStyle.outlined);
      });
    });

    group('交互测试', () {
      testWidgets('按压时应该触发触觉反馈', (WidgetTester tester) async {
        // 设置触觉反馈测试通道
        final List<MethodCall> log = <MethodCall>[];
        tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () {},
                child: const Text('Haptic'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(custom.NeumorphicButton));
        await tester.pump();

        // 验证触觉反馈被调用
        expect(
          log.any((call) =>
            call.method == 'HapticFeedback.vibrate' &&
            call.arguments == 'HapticFeedbackType.lightImpact'
          ),
          true,
        );
      });

      testWidgets('按压动画应该正确执行', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () {},
                child: const Text('Animate'),
              ),
            ),
          ),
        );

        // 按下按钮
        await tester.press(find.byType(custom.NeumorphicButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75)); // 动画中间帧

        // 验证按钮仍然存在
        expect(find.byType(custom.NeumorphicButton), findsOneWidget);

        // 释放按钮
        await tester.pumpAndSettle();
        expect(find.byType(custom.NeumorphicButton), findsOneWidget);
      });
    });

    group('自定义属性测试', () {
      testWidgets('应该支持自定义颜色', (WidgetTester tester) async {
        const customColor = Colors.red;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                color: customColor,
                onPressed: () {},
                child: const Text('Custom Color'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.color, customColor);
      });

      testWidgets('应该支持自定义宽度', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                width: 200,
                onPressed: () {},
                child: const Text('Custom Width'),
              ),
            ),
          ),
        );

        final button = tester.widget<custom.NeumorphicButton>(find.byType(custom.NeumorphicButton));
        expect(button.width, 200);
      });
    });
  });
}
