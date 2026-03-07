import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/typography.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/design_system/radius.dart';
import 'package:batana/design_system/animations.dart';
import 'package:batana/design_system/widgets/buttons.dart' as custom;
import 'package:batana/design_system/widgets/cards.dart';
import 'package:batana/design_system/widgets/progress_indicators.dart';

void main() {
  group('设计系统整合测试', () {
    group('模块导入测试', () {
      test('所有设计 Token 模块应该能正常导入', () {
        // 色彩系统
        expect(AppColors.primary, isNotNull);
        expect(AppColors.background, isNotNull);
        expect(AppColors.textPrimary, isNotNull);

        // 字体系统
        expect(AppTypography.display, isNotNull);
        expect(AppTypography.body, isNotNull);
        expect(AppTypography.caption, isNotNull);

        // 间距系统
        expect(AppSpacing.m, isA<double>());
        expect(AppSpacing.allM, isA<EdgeInsets>());

        // 圆角系统
        expect(AppRadius.medium, isA<double>());
        expect(AppRadius.allMedium, isA<BorderRadius>());

        // 动画系统
        expect(AppAnimations.fast, isA<Duration>());
        expect(AppAnimations.buttonPress, isA<AnimationConfig>());
      });
    });

    group('设计 Token 一致性测试', () {
      test('间距值应该基于 4 的倍数', () {
        expect(AppSpacing.xxs % 4, equals(0));
        expect(AppSpacing.xs % 4, equals(0));
        expect(AppSpacing.m % 4, equals(0));
        expect(AppSpacing.l % 4, equals(0));
        expect(AppSpacing.xl % 4, equals(0));
        expect(AppSpacing.xxl % 4, equals(0));
      });

      test('间距值应该递增排列', () {
        expect(AppSpacing.xxs, lessThan(AppSpacing.xs));
        expect(AppSpacing.xs, lessThan(AppSpacing.s));
        expect(AppSpacing.s, lessThan(AppSpacing.m));
        expect(AppSpacing.m, lessThan(AppSpacing.l));
        expect(AppSpacing.l, lessThan(AppSpacing.xl));
        expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
      });

      test('圆角值应该递增排列', () {
        expect(AppRadius.small, lessThan(AppRadius.medium));
        expect(AppRadius.medium, lessThan(AppRadius.large));
        expect(AppRadius.large, lessThan(AppRadius.xLarge));
      });

      test('动画时长应该递增排列', () {
        expect(
          AppAnimations.fast.inMilliseconds,
          lessThan(AppAnimations.normal.inMilliseconds),
        );
        expect(
          AppAnimations.normal.inMilliseconds,
          lessThan(AppAnimations.slow.inMilliseconds),
        );
      });

      test('字体大小应该按层级递减', () {
        expect(AppTypography.display.fontSize,
            greaterThan(AppTypography.h1.fontSize!));
        expect(
            AppTypography.h1.fontSize, greaterThan(AppTypography.h2.fontSize!));
        expect(
            AppTypography.h2.fontSize, greaterThan(AppTypography.h3.fontSize!));
        expect(AppTypography.h3.fontSize,
            greaterThan(AppTypography.bodyLarge.fontSize!));
        expect(AppTypography.bodyLarge.fontSize,
            greaterThan(AppTypography.body.fontSize!));
        expect(AppTypography.body.fontSize,
            greaterThan(AppTypography.bodySmall.fontSize!));
      });

      test('文字色应该有正确的层次', () {
        // textPrimary 应该比 textSecondary 更深（亮度更低）
        final primaryLuminance = AppColors.textPrimary.computeLuminance();
        final secondaryLuminance = AppColors.textSecondary.computeLuminance();
        final disabledLuminance = AppColors.textDisabled.computeLuminance();

        expect(primaryLuminance, lessThan(secondaryLuminance));
        expect(secondaryLuminance, lessThan(disabledLuminance));
      });
    });

    group('组件协同工作测试', () {
      testWidgets('按钮应该能在卡片内正常渲染', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicCard(
                title: const Text('测试卡片'),
                actions: [
                  custom.NeumorphicButton(
                    size: custom.ButtonSize.small,
                    onPressed: () {},
                    child: const Text('操作'),
                  ),
                ],
                child: const Text('卡片内容'),
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicCard), findsOneWidget);
        expect(find.byType(custom.NeumorphicButton), findsOneWidget);
        expect(find.text('测试卡片'), findsOneWidget);
        expect(find.text('操作'), findsOneWidget);
      });

      testWidgets('进度指示器应该能在卡片内正常渲染', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NeumorphicCard(
                title: const Text('进度'),
                child: Column(
                  children: [
                    const NeumorphicCircularProgressIndicator(
                      value: 0.75,
                      size: ProgressSize.small,
                    ),
                    AppSpacing.verticalSpaceM,
                    const NeumorphicLinearProgressIndicator(
                      value: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicCard), findsOneWidget);
        expect(find.byType(NeumorphicCircularProgressIndicator), findsOneWidget);
        expect(find.byType(NeumorphicLinearProgressIndicator), findsOneWidget);
      });

      testWidgets('多个组件应该能在列表中协同工作', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                padding: AppSpacing.pagePadding,
                children: [
                  NeumorphicCard(
                    padding: CardPadding.standard,
                    child: const Text('卡片 1'),
                  ),
                  AppSpacing.verticalSpaceM,
                  custom.NeumorphicButton(
                    onPressed: () {},
                    child: const Text('按钮'),
                  ),
                  AppSpacing.verticalSpaceM,
                  NeumorphicCard(
                    padding: CardPadding.relaxed,
                    child: const Text('卡片 2'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(NeumorphicCard), findsNWidgets(2));
        expect(find.byType(custom.NeumorphicButton), findsOneWidget);
      });
    });

    group('主题配置测试', () {
      test('背景色应该适合 Neumorphic 效果（浅色系）', () {
        final luminance = AppColors.background.computeLuminance();
        // Neumorphic 效果需要浅色背景（亮度 > 0.8）
        expect(luminance, greaterThan(0.8));
      });

      test('表面色应该比背景色略深', () {
        final bgLuminance = AppColors.background.computeLuminance();
        final surfaceLuminance = AppColors.surface.computeLuminance();
        expect(surfaceLuminance, lessThan(bgLuminance));
      });

      test('主色在背景色上应该有足够对比度', () {
        final bgLuminance = AppColors.background.computeLuminance();
        final primaryLuminance = AppColors.primary.computeLuminance();
        // 计算对比度比值（简化版）
        final contrastRatio = (bgLuminance + 0.05) / (primaryLuminance + 0.05);
        // WCAG AA 标准要求对比度 >= 3:1（大文字）
        expect(contrastRatio, greaterThan(3.0));
      });

      test('getTextColorForBackground 应该返回正确的文字颜色', () {
        // 浅色背景应该返回深色文字
        final lightBgText = AppColors.getTextColorForBackground(
          AppColors.background,
        );
        expect(lightBgText, equals(AppColors.textPrimary));

        // 深色背景应该返回白色文字
        final darkBgText = AppColors.getTextColorForBackground(
          AppColors.primaryDark,
        );
        expect(darkBgText, equals(Colors.white));
      });
    });
  });
}
