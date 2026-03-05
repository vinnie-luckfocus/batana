---
name: mvp-core-analysis
status: backlog
created: 2026-03-05T15:13:21Z
progress: 0%
prd: .claude/prds/mvp-core-analysis.md
github: [Will be updated when synced to GitHub]
---

# Epic: mvp-core-analysis

## Overview

实现 MVP 核心分析链路：Flutter 项目骨架 → 摄像头录制 → MediaPipe Pose 姿态识别 → 挥棒阶段分割 → 核心指标计算（速度/角度/协调性）→ 规则评分引擎 → 结果展示 → SQLite 本地存储。目标是在 2-3 个月内交付可用的端到端分析能力，验证"用户拍摄挥棒视频即可获得量化反馈"的核心价值。

## Architecture Decisions

- **跨平台框架**：Flutter，一套代码覆盖 iOS/Android
- **姿态识别**：MediaPipe Pose（移动端本地推理，无需服务器）
- **评分引擎**：规则引擎（可解释、可快速迭代），后续可叠加 ML 模型
- **本地存储**：SQLite（sqflite 插件），MVP 阶段无云端依赖
- **模块划分**：capture / analysis / scoring / storage / ui 五层解耦

## Technical Approach

### 客户端模块
- **capture**：摄像头预览、录制引导覆盖层、视频保存、帧提取
- **analysis**：MediaPipe Pose 推理、关键点序列解析、挥棒阶段分割（基于腕部速度峰值）、核心指标计算
- **scoring**：规则评分（0-100）、问题诊断映射表、建议模板库
- **storage**：SQLite 本地数据库、最近 10 次记录管理
- **ui**：录制引导页、分析结果页、历史列表页

### 算法层
- 挥棒阶段分割：基于腕部关键点速度曲线检测准备/加速/击球/收尾四阶段
- 指标计算：腕部轨迹速度（像素/帧 × 标定系数）、挥棒平面角度、髋肩启动时序差
- 评分规则：加权计算综合评分，映射常见问题模式

## Implementation Strategy

### 开发阶段
- M1（2 周）：Flutter 项目初始化 + 摄像头录制
- M2（3 周）：MediaPipe Pose 集成 + 关键点提取
- M3（2 周）：挥棒阶段分割 + 核心指标计算
- M4（2 周）：评分引擎 + 结果展示 + 本地存储
- M5（2 周）：多机型测试 + 性能优化

### 风险缓解
- 先用固定拍摄角度（正侧面）降低识别难度
- 评分规则先硬编码，收集真实数据后迭代
- 提供清晰的拍摄引导与质量检测

## Task Breakdown Preview

- [ ] T1：Flutter 项目骨架 + 基础 UI 框架
- [ ] T2：摄像头录制模块 + 录制引导
- [ ] T3：MediaPipe Pose 集成 + 关键点提取
- [ ] T4：挥棒阶段分割算法
- [ ] T5：核心指标计算（速度/角度/协调性）
- [ ] T6：规则评分引擎 + 建议模板
- [ ] T7：分析结果页 UI
- [ ] T8：历史记录页 + SQLite 存储
- [ ] T9：多机型测试与性能优化
- [ ] T10：用户测试与反馈迭代

## Dependencies

- MediaPipe Pose Flutter 插件（或原生桥接）
- SQLite Flutter 插件（sqflite）
- 摄像头与存储权限
- 评分规则设计（产品与算法协作）

## Success Criteria (Technical)

- 端到端分析成功率 ≥ 95%（标准拍摄条件）
- 单次分析耗时 ≤ 15 秒
- 关键点识别帧稳定率 ≥ 85%
- 崩溃率 < 1%
- 单元测试覆盖率 ≥ 80%（核心算法）

## Estimated Effort

- 总时长：2-3 个月
- 团队规模：2-3 人（客户端 + 算法）
- 关键路径：MediaPipe 集成质量 → 评分可信度 → 用户留存
