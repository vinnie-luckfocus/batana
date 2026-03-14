---
issue: 27
title: 设计系统基础建设
analyzed: 2026-03-06T15:16:28Z
estimated_hours: 18-22
parallelization_factor: 1.6
---

# Parallel Work Analysis: Issue #27

## Overview

建立独立的设计系统模块，包含完整的视觉规范（色彩、字体、间距、圆角、动画）和 5 个基础 Neumorphic 组件（Button、Card、ProgressIndicator、TextField、Switch）。这是整个 UI 重新设计的基础任务，需要高质量的设计和实现。

## Parallel Streams

### Stream A: 基础建设与设计规范
**Scope**: 创建目录结构、集成依赖包、定义所有设计 Token
**Files**:
- `lib/design_system/colors.dart`
- `lib/design_system/typography.dart`
- `lib/design_system/spacing.dart`
- `lib/design_system/radius.dart`
- `lib/design_system/animations.dart`
- `lib/design_system/neumorphic_theme.dart`
- `pubspec.yaml` (添加 flutter_neumorphic 依赖)
**Agent Type**: frontend-specialist
**Can Start**: immediately
**Estimated Hours**: 4-5
**Dependencies**: none

**详细任务**:
- 创建 `lib/design_system/` 目录结构
- 在 `pubspec.yaml` 中添加 `flutter_neumorphic: ^3.2.0`
- 定义色彩系统（主色、辅助色、强调色、语义色、文字色）
- 定义字体系统（9 个层级，包含字重和行高）
- 定义间距系统（7 个级别，基于 8px 网格）
- 定义圆角规范（4 个级别）
- 定义动画规范（3 种时长 + 4 种缓动曲线）
- 配置 Neumorphic 主题（阴影、深度、曲率）

### Stream B: 基础展示组件
**Scope**: 开发 Button 和 Card 组件
**Files**:
- `lib/design_system/widgets/buttons.dart`
- `lib/design_system/widgets/cards.dart`
**Agent Type**: frontend-specialist
**Can Start**: after Stream A completes
**Estimated Hours**: 5-6
**Dependencies**: Stream A (需要设计 Token)

**详细任务**:
- **NeumorphicButton**:
  - 3 种尺寸（Small/Medium/Large）
  - 4 种状态（Normal/Hover/Pressed/Disabled）
  - 2 种样式（Filled/Outlined）
  - 按压动画（缩放 + 阴影变化）
  - 触觉反馈集成
- **NeumorphicCard**:
  - 可配置内边距（标准/宽松）
  - 可配置阴影深度
  - 支持头部图片（16:9）
  - 标题 + 内容 + 操作区布局

### Stream C: 交互输入组件
**Scope**: 开发 TextField 和 Switch 组件
**Files**:
- `lib/design_system/widgets/text_fields.dart`
- `lib/design_system/widgets/switches.dart`
**Agent Type**: frontend-specialist
**Can Start**: after Stream A completes
**Estimated Hours**: 5-6
**Dependencies**: Stream A (需要设计 Token)

**详细任务**:
- **NeumorphicTextField**:
  - 4 种状态（Normal/Focused/Error/Disabled）
  - 错误状态抖动动画
  - 边框高亮动画
  - 触摸目标 ≥ 44x44pt
- **NeumorphicSwitch**:
  - 滑块移动动画（250ms EaseInOut）
  - 背景色渐变动画
  - 触觉反馈（开启时震动）
  - 触摸区域 ≥ 44x44pt

### Stream D: 进度指示组件
**Scope**: 开发 ProgressIndicator 组件
**Files**:
- `lib/design_system/widgets/progress_indicators.dart`
**Agent Type**: frontend-specialist
**Can Start**: after Stream A completes
**Estimated Hours**: 3-4
**Dependencies**: Stream A (需要设计 Token)

**详细任务**:
- **圆形进度条**:
  - 3 种尺寸（48pt/64pt/80pt）
  - 3 种线宽（4pt/6pt/8pt）
  - 旋转动画（1.5s 周期）
- **线性进度条**:
  - 2 种高度（4pt/6pt）
  - 填充动画（缓动曲线）
  - 支持不确定状态（loading）

### Stream E: 文档、测试与质量保证
**Scope**: 创建示例页面、编写文档、测试、无障碍检查
**Files**:
- `lib/design_system/examples/storybook.dart` (或类似)
- `docs/design_system.md`
- `test/design_system/**/*_test.dart`
**Agent Type**: fullstack-specialist
**Can Start**: after Streams B, C, D complete
**Estimated Hours**: 5-6
**Dependencies**: Streams B, C, D (需要所有组件完成)

**详细任务**:
- 创建组件示例页面（展示所有状态和变体）
- 编写设计系统使用文档（设计原则 + 最佳实践）
- 编写单元测试（覆盖率 ≥ 80%）
- 无障碍测试（对比度检查、语义化标签）
- 真机性能测试（动画流畅度 ≥ 60fps）

## Coordination Points

### Shared Files
- `pubspec.yaml` - Stream A 添加依赖（其他流不修改）
- 设计 Token 文件 - Stream A 独占，其他流只读

### Sequential Requirements
1. **必须先完成 Stream A** - 所有组件依赖设计 Token
2. **Streams B, C, D 可并行** - 它们操作不同的文件
3. **Stream E 最后执行** - 需要所有组件完成后才能测试和文档化

### Import Dependencies
所有组件文件都需要导入 Stream A 创建的设计 Token：
```dart
import '../colors.dart';
import '../typography.dart';
import '../spacing.dart';
import '../radius.dart';
import '../animations.dart';
import '../neumorphic_theme.dart';
```

## Conflict Risk Assessment

**Low Risk** - 工作流设计良好，冲突风险低：
- Stream A 独立完成基础建设
- Streams B, C, D 操作完全不同的文件
- Stream E 在所有组件完成后执行
- 唯一共享文件 `pubspec.yaml` 由 Stream A 独占修改

**潜在风险点**:
- 如果 Stream A 的设计 Token 需要调整，可能影响其他流
- 建议 Stream A 完成后进行快速 Review，确认设计规范无误

## Parallelization Strategy

**推荐方案**: Hybrid（混合并行）

**执行顺序**:
1. **Phase 1**: Stream A（串行，4-5h）
   - 完成基础建设和所有设计 Token
   - Review 设计规范，确保无误

2. **Phase 2**: Streams B, C, D（并行，5-6h）
   - 三个流同时开发不同组件
   - 最大化并行效率

3. **Phase 3**: Stream E（串行，5-6h）
   - 整合所有组件
   - 完成文档、测试、质量保证

## Expected Timeline

**并行执行**:
- Phase 1: 4-5 小时（Stream A）
- Phase 2: 5-6 小时（max(B, C, D)）
- Phase 3: 5-6 小时（Stream E）
- **总墙上时间**: 14-17 小时

**串行执行**:
- Stream A: 4-5 小时
- Stream B: 5-6 小时
- Stream C: 5-6 小时
- Stream D: 3-4 小时
- Stream E: 5-6 小时
- **总墙上时间**: 22-27 小时

**效率提升**: ~1.6x 加速（节省 8-10 小时）

## Notes

### 设计质量要求
- 这是整个 UI 重新设计的基础，质量要求极高
- 建议 Stream A 完成后进行设计师审核
- 所有组件需要在真机测试动画流畅度

### 技术考虑
- Flutter Neumorphic 库可能有学习曲线，预留探索时间
- 动画性能需要特别关注（目标 ≥ 60fps）
- 无障碍支持需要从一开始就考虑

### 依赖关系
- 所有其他 UI 重构任务依赖此任务完成
- 建议优先级最高，尽快完成

### 建议
- Phase 1 完成后暂停，进行设计规范 Review
- Phase 2 可以分配给 3 个不同的开发者并行
- Phase 3 需要有测试经验的开发者负责
