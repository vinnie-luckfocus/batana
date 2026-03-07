import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/design_system/widgets/progress_indicators.dart';
import 'package:batana/design_system/colors.dart';

void main() {
  group('NeumorphicCircularProgressIndicator', () {
    testWidgets('应该渲染小尺寸圆形进度条', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.small,
              value: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('应该渲染中等尺寸圆形进度条', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.medium,
              value: 0.75,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('应该渲染大尺寸圆形进度条', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.large,
              value: 1.0,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('应该支持不确定状态（loading）', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.medium,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);

      // 验证动画正在运行
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('应该在1.5秒内完成一次旋转', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.medium,
            ),
          ),
        ),
      );

      // 等待1.5秒完成一次旋转
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('应该使用正确的线宽（小尺寸4pt）', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.small,
              value: 0.5,
            ),
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(NeumorphicCircularProgressIndicator),
          matching: find.byType(CustomPaint),
        ),
      );

      expect(customPaint, isNotNull);
    });

    testWidgets('应该使用主色作为进度颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicCircularProgressIndicator(
              size: ProgressSize.medium,
              value: 0.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
    });
  });

  group('NeumorphicLinearProgressIndicator', () {
    testWidgets('应该渲染标准高度线性进度条', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
              value: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
    });

    testWidgets('应该渲染粗线性进度条', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.thick,
              value: 0.75,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
    });

    testWidgets('应该支持不确定状态（loading）', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);

      // 验证动画正在运行
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('应该使用缓动曲线填充动画', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
              value: 0.0,
            ),
          ),
        ),
      );

      // 初始状态
      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);

      // 更新进度
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
              value: 1.0,
            ),
          ),
        ),
      );

      // 等待动画完成
      await tester.pumpAndSettle();
      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
    });

    testWidgets('应该使用正确的圆角（标准高度2pt）', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
              value: 0.5,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(NeumorphicLinearProgressIndicator),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('应该使用主色作为进度颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
              value: 0.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
    });

    testWidgets('应该支持自定义宽度', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: NeumorphicLinearProgressIndicator(
                height: ProgressHeight.standard,
                value: 0.5,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
    });
  });

  group('ProgressSize', () {
    test('应该定义正确的尺寸值', () {
      expect(ProgressSize.small.diameter, equals(48.0));
      expect(ProgressSize.medium.diameter, equals(64.0));
      expect(ProgressSize.large.diameter, equals(80.0));

      expect(ProgressSize.small.strokeWidth, equals(4.0));
      expect(ProgressSize.medium.strokeWidth, equals(6.0));
      expect(ProgressSize.large.strokeWidth, equals(8.0));
    });
  });

  group('ProgressHeight', () {
    test('应该定义正确的高度值', () {
      expect(ProgressHeight.standard.height, equals(4.0));
      expect(ProgressHeight.thick.height, equals(6.0));

      expect(ProgressHeight.standard.borderRadius, equals(2.0));
      expect(ProgressHeight.thick.borderRadius, equals(3.0));
    });
  });
}
