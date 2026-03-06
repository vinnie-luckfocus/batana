---
issue: 20
title: 主界面重构
analyzed: 2026-03-06T14:32:48Z
estimated_hours: 14
parallelization_factor: 2.5
---

# Parallel Work Analysis: Issue #20

## Overview

重新设计主界面（HomeScreen），采用 Neumorphic 设计风格实现卡片式布局。包含三大功能入口（录制、相册、历史）、最近分析列表和底部导航栏。依赖 Task 001 的设计系统基础。

## Parallel Streams

### Stream A: Neumorphic 组件库
**Scope**: 实现可复用的 Neumorphic 设计组件
**Files**:
- `lib/ui/components/neumorphic_container.dart`
- `lib/ui/components/neumorphic_button.dart`
- `lib/ui/components/pressable_card.dart`
**Agent Type**: frontend-specialist
**Can Start**: immediately
**Estimated Hours**: 4
**Dependencies**: none

### Stream B: 主界面布局与组件
**Scope**: 实现主界面结构和各功能卡片
**Files**:
- `lib/screens/home/new_home_screen.dart`
- `lib/screens/home/widgets/home_header.dart`
- `lib/screens/home/widgets/record_video_card.dart`
- `lib/screens/home/widgets/gallery_card.dart`
- `lib/screens/home/widgets/history_card.dart`
- `lib/screens/home/widgets/custom_bottom_nav_bar.dart`
**Agent Type**: frontend-specialist
**Can Start**: after Stream A completes
**Estimated Hours**: 6
**Dependencies**: Stream A (需要 Neumorphic 组件)

### Stream C: 最近分析列表
**Scope**: 实现最近分析记录展示和交互
**Files**:
- `lib/screens/home/widgets/recent_analysis_section.dart`
- `lib/screens/home/widgets/analysis_record_card.dart`
**Agent Type**: frontend-specialist
**Can Start**: after Stream A completes
**Estimated Hours**: 3
**Dependencies**: Stream A (需要 Neumorphic 组件)

### Stream D: 状态管理与集成
**Scope**: 实现状态管理、路由集成和数据加载
**Files**:
- `lib/providers/home_state.dart`
- `lib/app.dart` (路由配置更新)
**Agent Type**: fullstack-specialist
**Can Start**: after Streams B & C complete
**Estimated Hours**: 2
**Dependencies**: Streams B & C

### Stream E: 测试与优化
**Scope**: Widget 测试、响应式适配测试、性能优化
**Files**:
- `test/screens/home/new_home_screen_test.dart`
- `test/screens/home/widgets/*_test.dart`
**Agent Type**: frontend-specialist
**Can Start**: after Stream D completes
**Estimated Hours**: 3
**Dependencies**: Stream D

## Coordination Points

### Shared Files
- `lib/app.dart` - Stream D 更新路由配置
- `pubspec.yaml` - Stream A 可能添加依赖（如果需要）

### Sequential Requirements
1. **Stream A 必须先完成** - 提供 Neumorphic 组件给其他流使用
2. **Streams B & C 可并行** - 它们操作不同的文件
3. **Stream D 依赖 B & C** - 需要组件完成后集成
4. **Stream E 最后执行** - 需要完整功能后测试

## Conflict Risk Assessment

**Low Risk**: 各流操作不同文件，冲突风险低
- Stream A: 独立组件库
- Streams B & C: 不同的 widget 文件
- Stream D: 状态管理和路由
- Stream E: 测试文件

**注意事项**:
- Stream A 完成后需要通知 B & C 可以开始
- Streams B & C 完成后需要通知 D 可以开始

## Parallelization Strategy

**Recommended Approach**: hybrid

**执行计划**:
1. **Phase 1**: Stream A (4h) - 单独执行
2. **Phase 2**: Streams B & C (6h) - 并行执行（取最长时间）
3. **Phase 3**: Stream D (2h) - 单独执行
4. **Phase 4**: Stream E (3h) - 单独执行

## Expected Timeline

**With parallel execution**:
- Wall time: 4h + 6h + 2h + 3h = 15h
- Total work: 18h
- Efficiency gain: 17%

**Without parallel execution**:
- Wall time: 18h

**实际考虑**:
- Phase 2 的并行执行节省了 3 小时
- 协调开销约 1 小时
- 净节省时间约 2 小时

## Blockers

⚠️ **依赖 Task 001**: 设计系统基础建设必须完成
- 需要确认 Task 001 状态
- 如果 Task 001 未完成，可以先实现 Stream A 作为临时方案

## Notes

1. **设计文档已完成**: `design/ui-design-v2.md` 提供了详细的实现指南
2. **组件优先**: Stream A 的 Neumorphic 组件是关键依赖
3. **测试覆盖**: Stream E 需要确保 80%+ 测试覆盖率
4. **性能目标**: 页面响应时间 < 100ms
5. **响应式适配**: 支持 iPhone SE (375px) 到 iPad 的屏幕尺寸
