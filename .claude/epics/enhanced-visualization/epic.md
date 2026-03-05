---
name: enhanced-visualization
status: backlog
created: 2026-03-05T15:13:21Z
progress: 0%
prd: .claude/prds/enhanced-visualization.md
github: [Will be updated when synced to GitHub]
---

# Epic: enhanced-visualization

## Overview

在 MVP 基础上增强可视化与数据分析能力：骨骼叠加渲染、关键帧慢放回放、5 个分项评分、30 次历史趋势图、账号体系与云端同步。目标是提升用户体验可解释性与留存率，优化分析性能至 10 秒以内，为专业用户与长期训练场景提供更深度价值。

## Architecture Decisions

- **骨骼渲染**：视频帧 + 关键点序列叠加，使用硬件加速（Canvas/OpenGL）
- **云端架构**：Firebase（快速启动）或自建后端，提供账号认证与数据同步 API
- **分项评分**：扩展评分引擎，输出 5 个维度评分（姿态/速度/力量/时机/流畅度）
- **趋势分析**：云端存储 30 次记录，客户端图表库渲染趋势图
- **离线优先**：本地缓存，联网后自动同步

## Technical Approach

### 客户端模块
- **visualization**：骨骼叠加渲染、关键帧检测、慢放回放控制
- **scoring_v2**：扩展评分引擎，输出分项评分
- **analytics**：趋势图渲染、统计分析
- **auth**：账号注册/登录、JWT 管理
- **sync**：云端数据同步、离线缓存、冲突解决

### 后端服务（最小化）
- 账号认证 API（JWT）
- 训练记录 CRUD API
- 数据同步接口

## Implementation Strategy

### 开发阶段
- M1（3 周）：骨骼叠加渲染 + 关键帧慢放
- M2（2 周）：分项评分体系 + 结果页改版
- M3（2 周）：趋势图 UI + 统计分析
- M4（3 周）：账号体系 + 云端 API + 数据同步
- M5（2 周）：性能优化 + 云同步稳定性测试

### 风险缓解
- 骨骼渲染使用硬件加速避免性能问题
- 云端仅同步元数据，视频按需下载控制成本
- 灰度发布收集反馈

## Task Breakdown Preview

- [ ] T1：骨骼叠加渲染引擎
- [ ] T2：关键帧检测 + 慢放回放
- [ ] T3：分项评分算法扩展
- [ ] T4：结果页 UI 改版
- [ ] T5：趋势图组件 + 统计分析
- [ ] T6：账号注册/登录 UI + 逻辑
- [ ] T7：后端 API 开发（账号 + 存储）
- [ ] T8：数据同步模块 + 离线缓存
- [ ] T9：性能优化（渲染 + 网络）
- [ ] T10：用户测试与反馈迭代

## Dependencies

- 视频编解码库（骨骼叠加）
- 图表库（趋势图）
- 云服务基础设施（Firebase 或自建）
- MVP 核心分析能力已上线

## Success Criteria (Technical)

- 分析耗时 ≤ 10 秒
- 骨骼渲染流畅度 ≥ 30 FPS
- 云同步成功率 ≥ 99%
- 崩溃率 < 0.5%

## Estimated Effort

- 总时长：2-3 个月
- 团队规模：3-4 人（客户端 + 后端 + 算法）
- 关键路径：骨骼渲染性能 → 云同步稳定性 → 用户留存提升
