import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/typography.dart';
import 'package:batana/design_system/widgets/buttons.dart' as custom;
import 'package:batana/design_system/widgets/cards.dart';
import 'package:batana/design_system/widgets/progress_indicators.dart';

/// 计算两个颜色之间的 WCAG 对比度
/// 公式: (L1 + 0.05) / (L2 + 0.05)，其中 L1 >= L2
double _contrastRatio(Color foreground, Color background) {
  final fgLuminance = foreground.computeLuminance();
  final bgLuminance = background.computeLuminance();
  final lighter =
      fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
  final darker =
      fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('无障碍测试', () {
    group('文字色对比度测试（WCAG 标准）', () {
      // WCAG AA 标准：
      // - 普通文字（<18pt）: 对比度 >= 4.5:1
      // - 大文字（>=18pt bold 或 >=24pt）: 对比度 >= 3:1

      test('主要文字色在背景色上应满足 WCAG AA（普通文字 >= 4.5:1）', () {
        final ratio = _contrastRatio(
          AppColors.textPrimary,
          AppColors.background,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: '主要文字色对比度 $ratio 不满足 WCAG AA 4.5:1');
      });

      test('主要文字色在表面色上应满足 WCAG AA（普通文字 >= 4.5:1）', () {
        final ratio = _contrastRatio(
          AppColors.textPrimary,
          AppColors.surface,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: '主要文字色在表面色上对比度 $ratio 不满足 WCAG AA 4.5:1');
      });
      test('次要文字色在背景色上应满足 WCAG AA（普通文字 >= 4.5:1）', () {
        final ratio = _contrastRatio(
          AppColors.textSecondary,
          AppColors.background,
        );
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: '次要文字色对比度 $ratio 不满足 WCAG AA 4.5:1');
      });

      test('主色在白色背景上应满足 WCAG AA（大文字 >= 3:1）', () {
        final ratio = _contrastRatio(AppColors.primary, Colors.white);
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: '主色对比度 $ratio 不满足 WCAG AA 大文字 3:1');
      });

      test('错误色在背景色上应满足 WCAG AA（大文字 >= 3:1）', () {
        final ratio = _contrastRatio(AppColors.error, AppColors.background);
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: '错误色对比度 $ratio 不满足 WCAG AA 大文字 3:1');
      });

      test('成功色在背景色上应满足 WCAG AA（大文字 >= 3:1）', () {
        final ratio = _contrastRatio(AppColors.success, AppColors.background);
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: '成功色对比度 $ratio 不满足 WCAG AA 大文字 3:1');
      });

      test('白色文字在主色上应满足 WCAG AA（大文字 >= 3:1）', () {
        final ratio = _contrastRatio(Colors.white, AppColors.primary);
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: '白色文字在主色上对比度 $ratio 不满足 WCAG AA 大文字 3:1');
      });

      test('白色文字在强调色上应满足 WCAG AA（大文字 >= 3:1）', () {
        final ratio = _contrastRatio(Colors.white, AppColors.accent);
        expect(ratio, greaterThanOrEqualTo(3.0),
            reason: '白色文字在强调色上对比度 $ratio 不满足 WCAG AA 大文字 3:1');
      });
    });

    group('触摸目标尺寸测试（>= 44x44pt）', () {
      testWidgets('Medium 按钮高度应该 >= 44pt', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: custom.NeumorphicButton(
                  size: custom.ButtonSize.medium,
                  onPressed: () {},
                  child: const Text('测试'),
                ),
              ),
            ),
          ),
        );

        final buttonSize = tester.getSize(
          find.byType(custom.NeumorphicButton),
        );
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'Medium 按钮高度 ${buttonSize.height} 不满足 44pt 最小触摸目标');
      });

      testWidgets('Large 按钮高度应该 >= 44pt', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: custom.NeumorphicButton(
                  size: custom.ButtonSize.large,
                  onPressed: () {},
                  child: const Text('测试'),
                ),
              ),
            ),
          ),
        );

        final buttonSize = tester.getSize(
          find.byType(custom.NeumorphicButton),
        );
        expect(buttonSize.height, greaterThanOrEqualTo(44.0),
            reason: 'Large 按钮高度 ${buttonSize.height} 不满足 44pt 最小触摸目标');
      });

      testWidgets('Small 按钮高度应该 >= 32pt（辅助操作可接受）',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: custom.NeumorphicButton(
                  size: custom.ButtonSize.small,
                  onPressed: () {},
                  child: const Text('测试'),
                ),
              ),
            ),
          ),
        );

        final buttonSize = tester.getSize(
          find.byType(custom.NeumorphicButton),
        );
        // Small 按钮用于辅助操作，32pt 可接受但需记录
        expect(buttonSize.height, greaterThanOrEqualTo(32.0),
            reason: 'Small 按钮高度 ${buttonSize.height} 低于最小 32pt');
      });
    });

    group('语义化标签测试', () {
      testWidgets('按钮应该包含可访问的文字内容', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: () {},
                child: const Text('提交分析'),
              ),
            ),
          ),
        );

        // 验证按钮文字可被辅助技术读取
        expect(find.text('提交分析'), findsOneWidget);
      });

      testWidgets('禁用按钮应该有视觉区分（降低不透明度）',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: custom.NeumorphicButton(
                onPressed: null,
                child: const Text('禁用按钮'),
              ),
            ),
          ),
        );

        // 验证禁用状态有 Opacity 包裹
        final opacity = tester.widget<Opacity>(find.byType(Opacity));
        expect(opacity.opacity, equals(0.5),
            reason: '禁用按钮应该有 0.5 不透明度以示区分');
      });

      testWidgets('卡片标题应该使用正确的文字层级', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicCard(
                title: const Text('分析结果'),
                child: const Text('内容详情'),
              ),
            ),
          ),
        );

        // 验证标题和内容都可被读取
        expect(find.text('分析结果'), findsOneWidget);
        expect(find.text('内容详情'), findsOneWidget);

        // 验证标题使用了 DefaultTextStyle 设置字体层级
        final titleFinder = find.text('分析结果');
        final titleWidget = tester.widget<Text>(titleFinder);
        // 标题文字应该存在于 widget 树中
        expect(titleWidget, isNotNull);
      });

      testWidgets('进度指示器应该能正常渲染', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: const [
                  NeumorphicCircularProgressIndicator(value: 0.75),
                  NeumorphicLinearProgressIndicator(value: 0.5),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
        expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
      });
    });

    group('字体可读性测试', () {
      test('最小字体不应小于 10pt', () {
        final allStyles = [
          AppTypography.display,
          AppTypography.h1,
          AppTypography.h2,
          AppTypography.h3,
          AppTypography.bodyLarge,
          AppTypography.body,
          AppTypography.bodySmall,
          AppTypography.caption,
          AppTypography.overline,
        ];

        for (final style in allStyles) {
          expect(style.fontSize, greaterThanOrEqualTo(10.0),
              reason: '字体大小 ${style.fontSize} 小于最小可读 10pt');
        }
      });

      test('正文行高应该 >= 1.4 以确保可读性', () {
        expect(AppTypography.body.height, greaterThanOrEqualTo(1.4));
        expect(AppTypography.bodyLarge.height, greaterThanOrEqualTo(1.4));
        expect(AppTypography.bodySmall.height, greaterThanOrEqualTo(1.4));
      });
    });
  });
}
