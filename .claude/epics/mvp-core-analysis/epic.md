---
name: mvp-core-analysis
status: in-progress
created: 2026-03-05T15:13:21Z
updated: 2026-03-06T08:29:33Z
progress: 100%
prd: .claude/prds/mvp-core-analysis.md
github: https://github.com/vinnie-luckfocus/batana/issues/10
---

# Epic: mvp-core-analysis

## Overview

MVP 核心分析链路：Flutter 项目骨架 → 摄像头录制 + 引导 → MediaPipe Pose 姿态识别 → 挥棒阶段分割 → 核心指标计算（速度/角度/协调性）→ 规则评分引擎 → 结果展示 → SQLite 本地存储。目标 2-3 个月交付端到端分析能力，验证核心价值。

## Architecture Decisions

- **跨平台框架**：Flutter (iOS/Android)
- **姿态识别**：MediaPipe Pose 本地推理
- **评分引擎**：规则引擎（可解释、可迭代）
- **本地存储**：SQLite (sqflite)
- **模块划分**：capture / analysis / scoring / storage / ui

## Technical Approach

### 客户端模块
- **capture**：摄像头预览、录制引导、质量门控（光照/人体/稳定性/角度检测）
- **analysis**：MediaPipe Pose 推理、关键点序列解析、挥棒阶段分割、核心指标计算
- **scoring**：规则评分（0-100）、问题诊断映射表、建议模板库
- **storage**：SQLite 本地数据库、最近 10 次记录管理
- **ui**：录制引导页、分析结果页、历史列表页

### 算法层
- 挥棒阶段分割：基于腕部关键点速度曲线检测准备/加速/击球/收尾四阶段
- 指标计算：速度（标定）、角度、协调性（髋肩时序差）
- 评分规则：加权综合评分 + 问题模式识别

## Implementation Strategy

| 阶段 | 内容 | 周期 |
|------|------|------|
| M1 | Flutter 项目初始化 + 摄像头录制 | 2 周 |
| M2 | MediaPipe Pose 集成 + 关键点提取 | 3 周 |
| M3 | 阶段分割 + 指标计算 | 2 周 |
| M4 | 评分引擎 + 结果/历史 UI + 存储 | 2 周 |
| M5 | 测试 + 性能优化 | 2 周 |

## Task Breakdown Preview

- [ ] T1：Flutter 项目骨架 + 基础 UI 框架 + 导航
- [ ] T2：摄像头录制模块 + 录制引导 + 质量门控
- [ ] T3：MediaPipe Pose 集成 + 关键点提取
- [ ] T4：挥棒阶段分割算法（4 阶段 → 3 阶段降级）
- [ ] T5：核心指标计算（速度/角度/协调性）
- [ ] T6：规则评分引擎 + 建议模板库
- [ ] T7：分析结果页 + 历史记录页 + SQLite 存储
- [ ] T8：集成测试 + 性能优化 + 多机型验证

## Dependencies

- MediaPipe Pose Flutter 插件
- sqflite 插件
- 摄像头/存储权限
- 评分规则设计

## Success Criteria (Technical)

- 端到端分析成功率 ≥ 95%
- 单次分析耗时 ≤ 15 秒
- 关键点识别成功率 ≥ 85%
- 崩溃率 < 1%
- 单元测试覆盖率 ≥ 80%

## Estimated Effort

- 总时长：2-3 个月
- 关键路径：MediaPipe 集成 → 评分可信度 → 用户留存

## Tasks Created

- [ ] #2 - Flutter 项目骨架 + 基础 UI + 导航 (parallel: false)
- [ ] #3 - 摄像头录制模块 + 录制引导 + 质量门控 (parallel: false)
- [ ] #4 - MediaPipe Pose 集成 + 关键点提取 (parallel: false)
- [ ] #5 - 挥棒阶段分割算法 (parallel: false)
- [ ] #6 - 核心指标计算（速度/角度/协调性） (parallel: false)
- [ ] #7 - 规则评分引擎 + 建议模板库 (parallel: false)
- [ ] #8 - 分析结果页 + 历史记录页 + SQLite 存储 (parallel: false)
- [ ] #9 - 集成测试 + 性能优化 + 多机型验证 (parallel: false)

Total tasks: 8
Parallel tasks: 0
Sequential tasks: 8
