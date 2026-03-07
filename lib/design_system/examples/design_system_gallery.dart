import 'package:flutter/material.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/typography.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/design_system/widgets/buttons.dart';
import 'package:batana/design_system/widgets/cards.dart';
import 'package:batana/design_system/widgets/progress_indicators.dart';

/// 设计系统组件展示页面
///
/// 展示所有 Neumorphic 组件的状态和变体，
/// 类似 Storybook 的组件文档页面。
class DesignSystemGallery extends StatefulWidget {
  const DesignSystemGallery({super.key});

  @override
  State<DesignSystemGallery> createState() => _DesignSystemGalleryState();
}

class _DesignSystemGalleryState extends State<DesignSystemGallery> {
  // Switch 演示状态
  bool _switchValue = false;

  // 进度条演示值
  double _progressValue = 0.65;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设计系统组件库'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildSectionTitle('NeumorphicButton 按钮'),
          AppSpacing.verticalSpaceM,
          _buildButtonSizeShowcase(),
          AppSpacing.verticalSpaceL,
          _buildButtonStateShowcase(),
          AppSpacing.verticalSpaceL,
          _buildButtonStyleShowcase(),
          AppSpacing.verticalSpaceXL,

          _buildSectionTitle('NeumorphicCard 卡片'),
          AppSpacing.verticalSpaceM,
          _buildCardPaddingShowcase(),
          AppSpacing.verticalSpaceL,
          _buildCardDepthShowcase(),
          AppSpacing.verticalSpaceL,
          _buildCardWithHeaderShowcase(),
          AppSpacing.verticalSpaceXL,

          _buildSectionTitle('NeumorphicProgressIndicator 进度指示器'),
          AppSpacing.verticalSpaceM,
          _buildCircularProgressShowcase(),
          AppSpacing.verticalSpaceL,
          _buildLinearProgressShowcase(),
          AppSpacing.verticalSpaceL,
          _buildIndeterminateProgressShowcase(),
          AppSpacing.verticalSpaceXL,

          _buildSectionTitle('色彩系统'),
          AppSpacing.verticalSpaceM,
          _buildColorPalette(),
          AppSpacing.verticalSpaceXL,

          _buildSectionTitle('字体系统'),
          AppSpacing.verticalSpaceM,
          _buildTypographyShowcase(),
          AppSpacing.verticalSpaceXL,

          _buildSectionTitle('间距系统'),
          AppSpacing.verticalSpaceM,
          _buildSpacingShowcase(),
          AppSpacing.verticalSpaceXXL,
        ],
      ),
    );
  }

  // ===========================================================================
  // 区块标题
  // ===========================================================================

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.h1);
  }

  Widget _buildSubsectionTitle(String title) {
    return Text(title, style: AppTypography.h3);
  }

  // ===========================================================================
  // 按钮展示
  // ===========================================================================

  /// 3 种尺寸展示：Small / Medium / Large
  Widget _buildButtonSizeShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('尺寸变体'),
        AppSpacing.verticalSpaceS,
        Wrap(
          spacing: AppSpacing.m,
          runSpacing: AppSpacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NeumorphicButton(
              size: ButtonSize.small,
              onPressed: () {},
              child: const Text('Small'),
            ),
            NeumorphicButton(
              size: ButtonSize.medium,
              onPressed: () {},
              child: const Text('Medium'),
            ),
            NeumorphicButton(
              size: ButtonSize.large,
              onPressed: () {},
              child: const Text('Large'),
            ),
          ],
        ),
      ],
    );
  }

  /// 4 种状态展示：Normal / Hover / Pressed / Disabled
  Widget _buildButtonStateShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('状态变体'),
        AppSpacing.verticalSpaceS,
        Wrap(
          spacing: AppSpacing.m,
          runSpacing: AppSpacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NeumorphicButton(
              onPressed: () {},
              child: const Text('Normal'),
            ),
            NeumorphicButton(
              onPressed: () {},
              child: const Text('Hover（长按查看）'),
            ),
            NeumorphicButton(
              onPressed: () {},
              child: const Text('Pressed（点击查看）'),
            ),
            const NeumorphicButton(
              onPressed: null,
              child: Text('Disabled'),
            ),
          ],
        ),
      ],
    );
  }

  /// 2 种样式展示：Filled / Outlined
  Widget _buildButtonStyleShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('样式变体'),
        AppSpacing.verticalSpaceS,
        Wrap(
          spacing: AppSpacing.m,
          runSpacing: AppSpacing.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NeumorphicButton(
              style: NeumorphicButtonStyle.filled,
              onPressed: () {},
              child: const Text('Filled'),
            ),
            NeumorphicButton(
              style: NeumorphicButtonStyle.outlined,
              onPressed: () {},
              child: const Text('Outlined'),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 卡片展示
  // ===========================================================================

  /// 内边距变体：Standard / Relaxed
  Widget _buildCardPaddingShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('内边距变体'),
        AppSpacing.verticalSpaceS,
        Row(
          children: [
            Expanded(
              child: NeumorphicCard(
                padding: CardPadding.standard,
                title: const Text('Standard'),
                child: const Text('标准内边距 (16pt)'),
              ),
            ),
            AppSpacing.horizontalSpaceM,
            Expanded(
              child: NeumorphicCard(
                padding: CardPadding.relaxed,
                title: const Text('Relaxed'),
                child: const Text('宽松内边距 (24pt)'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 阴影深度变体：Depth 1.0 / 2.0 / 3.0
  Widget _buildCardDepthShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('阴影深度变体'),
        AppSpacing.verticalSpaceS,
        Row(
          children: [
            Expanded(
              child: NeumorphicCard(
                depth: 1.0,
                title: const Text('Depth 1.0'),
                child: const Text('浅阴影'),
              ),
            ),
            AppSpacing.horizontalSpaceM,
            Expanded(
              child: NeumorphicCard(
                depth: 2.0,
                title: const Text('Depth 2.0'),
                child: const Text('标准阴影'),
              ),
            ),
            AppSpacing.horizontalSpaceM,
            Expanded(
              child: NeumorphicCard(
                depth: 3.0,
                title: const Text('Depth 3.0'),
                child: const Text('深阴影'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 带头部图片的卡片
  Widget _buildCardWithHeaderShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('带头部图片的卡片'),
        AppSpacing.verticalSpaceS,
        NeumorphicCard(
          headerImage: Container(
            color: AppColors.primary,
            child: const Center(
              child: Icon(
                Icons.image,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          title: const Text('卡片标题'),
          child: const Text('这是一个带头部图片的卡片示例，图片比例为 16:9。'),
          actions: [
            NeumorphicButton(
              size: ButtonSize.small,
              style: NeumorphicButtonStyle.outlined,
              onPressed: () {},
              child: const Text('操作'),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 进度指示器展示
  // ===========================================================================

  /// 圆形进度指示器：3 种尺寸
  Widget _buildCircularProgressShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('圆形进度指示器（确定进度）'),
        AppSpacing.verticalSpaceS,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                NeumorphicCircularProgressIndicator(
                  size: ProgressSize.small,
                  value: _progressValue,
                ),
                AppSpacing.verticalSpaceS,
                const Text('Small', style: AppTypography.caption),
              ],
            ),
            Column(
              children: [
                NeumorphicCircularProgressIndicator(
                  size: ProgressSize.medium,
                  value: _progressValue,
                ),
                AppSpacing.verticalSpaceS,
                const Text('Medium', style: AppTypography.caption),
              ],
            ),
            Column(
              children: [
                NeumorphicCircularProgressIndicator(
                  size: ProgressSize.large,
                  value: _progressValue,
                ),
                AppSpacing.verticalSpaceS,
                const Text('Large', style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 线性进度指示器：2 种高度
  Widget _buildLinearProgressShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('线性进度指示器（确定进度）'),
        AppSpacing.verticalSpaceS,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Standard Height', style: AppTypography.caption),
            AppSpacing.verticalSpaceXS,
            NeumorphicLinearProgressIndicator(
              height: ProgressHeight.standard,
              value: _progressValue,
            ),
            AppSpacing.verticalSpaceM,
            const Text('Thick Height', style: AppTypography.caption),
            AppSpacing.verticalSpaceXS,
            NeumorphicLinearProgressIndicator(
              height: ProgressHeight.thick,
              value: _progressValue,
            ),
          ],
        ),
      ],
    );
  }

  /// 不确定状态进度指示器
  Widget _buildIndeterminateProgressShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('不确定状态进度指示器'),
        AppSpacing.verticalSpaceS,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const NeumorphicCircularProgressIndicator(
                  size: ProgressSize.medium,
                  value: null, // 不确定状态
                ),
                AppSpacing.verticalSpaceS,
                const Text('圆形', style: AppTypography.caption),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NeumorphicLinearProgressIndicator(
                    value: null, // 不确定状态
                  ),
                  AppSpacing.verticalSpaceS,
                  const Text('线性', style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 色彩系统展示
  // ===========================================================================

  Widget _buildColorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle('主色调（60%）'),
        AppSpacing.verticalSpaceS,
        Row(
          children: [
            _buildColorSwatch('Primary', AppColors.primary),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Primary Light', AppColors.primaryLight),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Primary Dark', AppColors.primaryDark),
          ],
        ),
        AppSpacing.verticalSpaceL,
        _buildSubsectionTitle('辅助色（30%）'),
        AppSpacing.verticalSpaceS,
        Row(
          children: [
            _buildColorSwatch('Surface', AppColors.surface),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Background', AppColors.background),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Divider', AppColors.divider),
          ],
        ),
        AppSpacing.verticalSpaceL,
        _buildSubsectionTitle('强调色（10%）'),
        AppSpacing.verticalSpaceS,
        Row(
          children: [
            _buildColorSwatch('Accent', AppColors.accent),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Success', AppColors.success),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Warning', AppColors.warning),
            AppSpacing.horizontalSpaceM,
            _buildColorSwatch('Error', AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(name, style: AppTypography.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ===========================================================================
  // 字体系统展示
  // ===========================================================================

  Widget _buildTypographyShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypographyItem('Display', AppTypography.display, '超大标题'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('H1', AppTypography.h1, '一级标题'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('H2', AppTypography.h2, '二级标题'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('H3', AppTypography.h3, '三级标题'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('Body Large', AppTypography.bodyLarge, '大号正文'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('Body', AppTypography.body, '标准正文'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('Body Small', AppTypography.bodySmall, '小号正文'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('Caption', AppTypography.caption, '说明文字'),
        AppSpacing.verticalSpaceM,
        _buildTypographyItem('Overline', AppTypography.overline, '上标文字'),
      ],
    );
  }

  Widget _buildTypographyItem(String name, TextStyle style, String sample) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 120,
          child: Text(name, style: AppTypography.caption),
        ),
        Expanded(
          child: Text(sample, style: style),
        ),
      ],
    );
  }

  // ===========================================================================
  // 间距系统展示
  // ===========================================================================

  Widget _buildSpacingShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpacingItem('XXS', AppSpacing.xxs),
        AppSpacing.verticalSpaceS,
        _buildSpacingItem('XS', AppSpacing.xs),
        AppSpacing.verticalSpaceS,
        _buildSpacingItem('S', AppSpacing.s),
        AppSpacing.verticalSpaceS,
        _buildSpacingItem('M', AppSpacing.m),
        AppSpacing.verticalSpaceS,
        _buildSpacingItem('L', AppSpacing.l),
        AppSpacing.verticalSpaceS,
        _buildSpacingItem('XL', AppSpacing.xl),
        AppSpacing.verticalSpaceS,
        _buildSpacingItem('XXL', AppSpacing.xxl),
      ],
    );
  }

  Widget _buildSpacingItem(String name, double value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(name, style: AppTypography.caption),
        ),
        Container(
          width: value,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        AppSpacing.horizontalSpaceS,
        Text('${value.toInt()}pt', style: AppTypography.caption),
      ],
    );
  }
}

