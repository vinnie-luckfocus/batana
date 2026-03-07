# Batana 设计系统使用文档

## 设计原则

本设计系统基于 Neumorphic（新拟态）风格，遵循以下核心原则：

- **审美高级**：柔和的阴影与光影效果，营造精致、现代的视觉体验
- **布局合理**：基于 8px 网格系统，确保元素对齐与间距一致
- **交互友好**：流畅的动画反馈，清晰的状态变化，符合人机交互规范

---

## 色彩系统

遵循 **60-30-10** 原则分配色彩比例。

### 主色调（60%）— 专业感与可信赖

| Token | 色值 | 用途 |
|-------|------|------|
| `AppColors.primary` | `#1E88E5` | 主色，深邃蓝，传达专业与可信赖 |
| `AppColors.primaryLight` | `#64B5F6` | 悬停状态、辅助元素 |
| `AppColors.primaryDark` | `#1565C0` | 强调、按压状态 |

### 辅助色（30%）— 温暖舒适的背景

| Token | 色值 | 用途 |
|-------|------|------|
| `AppColors.surface` | `#ECEFF1` | 卡片、组件背景 |
| `AppColors.background` | `#F5F7FA` | 页面主背景 |
| `AppColors.divider` | `#CFD8DC` | 分割线 |

### 强调色（10%）— 活力与引导

| Token | 色值 | 用途 |
|-------|------|------|
| `AppColors.accent` | `#E65100` | CTA 按钮、重要操作 |
| `AppColors.success` | `#43A047` | 成功状态 |
| `AppColors.warning` | `#FFA726` | 警告状态 |
| `AppColors.error` | `#E53935` | 错误状态 |

### 文字色

| Token | 用途 |
|-------|------|
| `AppColors.textPrimary` (`#212121`) | 标题、重要内容（87% 不透明度） |
| `AppColors.textSecondary` (`#6D6D6D`) | 辅助说明 |
| `AppColors.textDisabled` (`#BDBDBD`) | 禁用状态（38% 不透明度） |

### 代码示例

```dart
import 'package:batana/design_system/colors.dart';

// 使用主色
Container(color: AppColors.primary);

// 根据背景色自动选择文字颜色
final textColor = AppColors.getTextColorForBackground(AppColors.primary);
```

---

## 字体系统

定义 9 个层级的文字样式，确保清晰的视觉层次。

### 标题层级

| Token | 字号 | 字重 | 行高 | 用途 |
|-------|------|------|------|------|
| `AppTypography.display` | 32pt | Bold | 1.2 | 启动页、空状态 |
| `AppTypography.h1` | 24pt | Bold | 1.3 | 页面主标题 |
| `AppTypography.h2` | 20pt | SemiBold | 1.4 | 区块标题 |
| `AppTypography.h3` | 18pt | Medium | 1.4 | 卡片标题 |

### 正文层级

| Token | 字号 | 字重 | 行高 | 用途 |
|-------|------|------|------|------|
| `AppTypography.bodyLarge` | 16pt | Regular | 1.5 | 重要说明 |
| `AppTypography.body` | 14pt | Regular | 1.5 | 主要内容 |
| `AppTypography.bodySmall` | 12pt | Regular | 1.5 | 次要内容 |

### 辅助层级

| Token | 字号 | 字重 | 行高 | 用途 |
|-------|------|------|------|------|
| `AppTypography.caption` | 12pt | Regular | 1.4 | 图片说明、时间戳 |
| `AppTypography.overline` | 10pt | Medium | 1.4 | 分类标签（全大写） |

### 按钮文字

| Token | 字号 | 字重 |
|-------|------|------|
| `AppTypography.buttonLarge` | 16pt | SemiBold |
| `AppTypography.buttonMedium` | 14pt | SemiBold |
| `AppTypography.buttonSmall` | 12pt | SemiBold |

### 代码示例

```dart
import 'package:batana/design_system/typography.dart';

Text('页面标题', style: AppTypography.h1);
Text('正文内容', style: AppTypography.body);

// 自定义颜色
Text('彩色文字', style: AppTypography.withColor(AppTypography.h2, Colors.blue));
```

---

## 间距系统

基于 **8px 网格系统**，所有间距值均为 4 的倍数。

### 间距层级

| Token | 值 | 用途 |
|-------|-----|------|
| `AppSpacing.xxs` | 4pt | 图标与文字之间 |
| `AppSpacing.xs` | 8pt | 组件内部元素 |
| `AppSpacing.s` | 12pt | 相关元素之间 |
| `AppSpacing.m` | 16pt | 标准间距（默认） |
| `AppSpacing.l` | 24pt | 组件之间 |
| `AppSpacing.xl` | 32pt | 区块之间 |
| `AppSpacing.xxl` | 48pt | 大区块分隔 |

### 快捷方式

```dart
import 'package:batana/design_system/spacing.dart';

// SizedBox 间距
Column(children: [
  Text('标题'),
  AppSpacing.verticalSpaceM,  // 16pt 垂直间距
  Text('内容'),
]);

// EdgeInsets 内边距
Padding(
  padding: AppSpacing.allM,        // 全方向 16pt
  child: content,
);
Padding(
  padding: AppSpacing.pagePadding, // 页面标准内边距（水平16, 垂直24）
  child: pageContent,
);
```

---

## 圆角规范

定义 4 个层级的圆角，所有值均为 4 的倍数。

| Token | 值 | 用途 |
|-------|-----|------|
| `AppRadius.small` | 8pt | 按钮、标签 |
| `AppRadius.medium` | 12pt | 卡片、输入框 |
| `AppRadius.large` | 16pt | 大卡片、弹窗 |
| `AppRadius.xLarge` | 24pt | 特殊容器 |

### 快捷 BorderRadius

```dart
import 'package:batana/design_system/radius.dart';

// 全方向圆角
Container(
  decoration: BoxDecoration(borderRadius: AppRadius.allMedium),
);

// 顶部圆角（用于底部弹窗）
Container(
  decoration: BoxDecoration(borderRadius: AppRadius.topLarge),
);

// 完全圆形（头像、图标按钮）
Container(
  decoration: BoxDecoration(borderRadius: AppRadius.circle),
);
```

---

## 动画规范

### 动画时长

| Token | 时长 | 用途 |
|-------|------|------|
| `AppAnimations.fast` | 150ms | 按钮按压、开关切换 |
| `AppAnimations.normal` | 250ms | 页面切换、卡片展开 |
| `AppAnimations.slow` | 400ms | 复杂变化、引导动画 |

### 缓动曲线

| Token | 效果 | 用途 |
|-------|------|------|
| `AppAnimations.easeOut` | 快启慢停 | 元素进入场景 |
| `AppAnimations.easeIn` | 慢启快停 | 元素退出场景 |
| `AppAnimations.easeInOut` | 两端缓慢 | 状态切换 |
| `AppAnimations.spring` | 弹性效果 | 活泼交互 |
| `AppAnimations.bounce` | 弹跳效果 | 强调、吸引注意力 |

### 预设动画配置

| Token | 时长 + 曲线 | 用途 |
|-------|-------------|------|
| `AppAnimations.buttonPress` | 150ms + easeOut | 按钮按压 |
| `AppAnimations.pageTransition` | 250ms + easeInOut | 页面切换 |
| `AppAnimations.cardExpand` | 250ms + easeOut | 卡片展开 |
| `AppAnimations.dialogAppear` | 250ms + spring | 弹窗出现 |
| `AppAnimations.loading` | 400ms + easeInOut | 加载动画 |

### 代码示例

```dart
import 'package:batana/design_system/animations.dart';

// 使用预设配置创建动画控制器
final controller = AppAnimations.buttonPress.createController(this);

// 创建补间动画
final animation = AppAnimations.buttonPress.createTween(
  controller,
  Tween<double>(begin: 0.0, end: 1.0),
);
```

---

## 组件使用指南

### NeumorphicButton 按钮

支持 3 种尺寸（small/medium/large）、2 种样式（filled/outlined）、4 种状态（normal/pressed/disabled/loading）。

```dart
import 'package:batana/design_system/widgets/buttons.dart';

// 基本用法
NeumorphicButton(
  onPressed: () => print('点击'),
  child: Text('主要按钮'),
);

// 小尺寸 + outlined 样式
NeumorphicButton(
  size: ButtonSize.small,
  style: NeumorphicButtonStyle.outlined,
  onPressed: () {},
  child: Text('次要按钮'),
);

// 大尺寸 + 自定义颜色
NeumorphicButton(
  size: ButtonSize.large,
  color: AppColors.accent,
  onPressed: () {},
  child: Text('强调按钮'),
);

// 禁用状态（onPressed 传 null）
NeumorphicButton(
  onPressed: null,
  child: Text('禁用按钮'),
);
```

**尺寸规格：**
| 尺寸 | 高度 | 水平内边距 |
|------|------|-----------|
| small | 32pt | 12pt |
| medium | 44pt | 16pt |
| large | 56pt | 24pt |

### NeumorphicCard 卡片

支持标题、头部图片、操作区、可配置内边距和阴影深度。

```dart
import 'package:batana/design_system/widgets/cards.dart';

// 基本卡片
NeumorphicCard(
  child: Text('卡片内容'),
);

// 带标题和操作区
NeumorphicCard(
  title: Text('分析结果'),
  actions: [
    NeumorphicButton(
      size: ButtonSize.small,
      onPressed: () {},
      child: Text('查看详情'),
    ),
  ],
  child: Text('挥棒评分：85 分'),
);

// 宽松内边距 + 自定义深度
NeumorphicCard(
  padding: CardPadding.relaxed,
  depth: 4.0,
  child: Text('宽松卡片'),
);

// 带头部图片
NeumorphicCard(
  headerImage: Image.asset('assets/images/swing.png', fit: BoxFit.cover),
  title: Text('训练记录'),
  child: Text('2026-03-07 下午训练'),
);
```

### NeumorphicProgressIndicator 进度指示器

#### 圆形进度指示器

```dart
import 'package:batana/design_system/widgets/progress_indicators.dart';

// 确定进度（0.0 ~ 1.0）
NeumorphicCircularProgressIndicator(
  value: 0.75,
  size: ProgressSize.medium,
  color: AppColors.primary,
);

// 不确定进度（自动旋转动画）
NeumorphicCircularProgressIndicator(
  size: ProgressSize.large,
);
```

#### 线性进度条

```dart
// 确定进度
NeumorphicLinearProgressIndicator(
  value: 0.5,
  height: ProgressHeight.standard,
);

// 不确定进度
NeumorphicLinearProgressIndicator(
  height: ProgressHeight.thick,
  color: AppColors.success,
);
```

**圆形尺寸规格：**
| 尺寸 | 直径 | 线宽 |
|------|------|------|
| small | 48pt | 4pt |
| medium | 64pt | 6pt |
| large | 80pt | 8pt |

---

## 组件展示页面

项目包含一个完整的组件展示页面（类似 Storybook），可用于预览所有组件：

```dart
import 'package:batana/design_system/examples/design_system_gallery.dart';

// 在路由中注册
GoRoute(
  path: '/design-system',
  builder: (context, state) => const DesignSystemGallery(),
);
```

---

## 性能测试指南

### 动画性能要求

所有动画必须达到 **60fps**（每帧 ≤ 16.67ms）。

### 测试方法

1. 使用 Flutter DevTools 的 Performance 面板监控帧率
2. 在 Profile 模式下运行应用：`flutter run --profile`
3. 关注以下指标：
   - 帧构建时间（Build）≤ 8ms
   - 帧光栅化时间（Raster）≤ 8ms
   - 无掉帧（Jank）

### 性能优化建议

- 使用 `const` 构造函数减少重建
- 避免在 `build()` 中创建动画控制器
- 使用 `RepaintBoundary` 隔离频繁重绘区域
- 进度指示器的不确定动画使用 `AnimationController.repeat()` 而非递归调用
