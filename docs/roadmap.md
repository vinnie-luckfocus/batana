# Batana 生态路线图

> 版本：v0.1（2026-09-17）· 粒度：阶段（Phase）→ 里程碑（M）· 进度跟踪以 `repos.yaml` 与各仓 GitHub Projects 为准

## 总览

```
2026 Q4          2027 Q1          2027 Q2          2027 Q3          2027 Q4
─────────────────────────────────────────────────────────────────────────────
P0 生态重组
   P1 core 单目管线产品化
                     P2 cap 原型 + IMU 融合
                                        P3 pi 原型 + 双目 max
                                                           P4 web 平台 v1
                                                                              P5 数仓 + 教练模式
```

## P0 — 生态重组（2026-09，当前）

目标：完成多仓库拆分，确立契约与版本管理机制。

- [x] 司令塔文档：架构 / 能力分级 / 路线图 / 模块边界
- [x] 创建子仓库：batana-core / batana-gui / batana-pi / batana-cap / batana-web
- [x] 旧 Flutter MVP 方案彻底放弃（2026-09-17 决策），代码留存主仓 git 历史 tag `archive/flutter-mvp` 仅作参考
- [x] 司令塔仓库移除产品代码，保留 logo、文档、PM 体系
- [ ] 数据契约 v0.1：session-schema（core）、ble-protocol（cap）

## P1 — core 单目管线产品化（2026 Q4）

目标：在 batana-core 中从头实现 MediaPipe 单目分析管线（旧 Flutter MVP 已放弃，仅作算法参考），实现 **standard-vision** 档。

- M1.1 batana-core v0.1：Python 侧管线骨架 + session-schema v1 + 规则评分引擎
- M1.2 batana-runtime v0.1：C++ 推理运行时骨架，TFLite/CoreML 后端，C API 供 Qt6 直接链接
- M1.3 batana-gui v0.1：Qt6 应用骨架（Android/iOS/macOS），接入 runtime 走通"录制→分析→评分→展示"
- 出口标准：手机端"录制→分析→评分→展示"全链路走 runtime，分析完成率 ≥ 85%

## P2 — batana-cap 原型与 IMU 融合（2027 Q1）

目标：cap EVT 样机 + **standard-imu** 与 **pro-fusion** 档。

- M2.1 cap 硬件 EVT：nRF52840 + IMU + 1.28" 圆屏（GC9A01）+ 锂电池，结构 3D 打印
- M2.2 cap 固件 v0.1（Zephyr）：200Hz IMU 采样、BLE GATT v1、圆屏显示（棒速/计数/电量）
- M2.3 batana-core v0.2：IMU 管线（棒速估计、挥棒计数、节奏）+ 视觉-惯性时序对齐
- M2.4 batana-gui v0.3：BLE 连接管理、融合分析 UI、cap 圆屏联动
- 出口标准：手机+cap 融合分析 ≤ 8s，棒速估计误差 ≤ 10%

## P3 — batana-pi 原型与双目 max（2027 Q2）

目标：pi EVT 样机 + **pro-stereo** 与 **max** 档。

- M3.1 pi 硬件 EVT：RK3588/RPi5 边缘盒 + 双目全局快门相机 + 触控显示屏
- M3.2 pi 软件栈 v0.1：双目同步采集服务、标定工具、runtime 边缘部署（NPU 加速）
- M3.3 batana-core v0.3：双目 3D 管线（pose3d、bat_traj3d、kinematic_seq、impact_point、biomech_report）
- M3.4 嵌入式 batana-gui：Qt6 嵌入式 Linux 构建部署到 pi 显示屏
- 出口标准：pi+cap 全量分析 ≤ 8s，3D 棒轨迹重投影误差 ≤ 15mm@2m

## P4 — batana-web 平台 v1（2027 Q3）

目标：云端数据闭环。

- M4.1 web v0.1：Next.js + Postgres，sync-api v1，会话/指标云端存储
- M4.2 数据统计与趋势展示：个人仪表盘、训练历史趋势图
- M4.3 gui/pi 云同步：账号体系（单用户多设备）
- 出口标准：端到端同步成功率 ≥ 99%，仪表盘首屏 ≤ 2s

## P5 — 多租户数仓与教练模式（2027 Q4）

- M5.1 多身份/多用户：球员-教练-机构角色模型，数据权限隔离
- M5.2 数仓：指标明细层/汇总层分层，开放分析接口
- M5.3 教练模式：训练计划、周期报告、AI 动作指导（coach_advice 模型化）

## 风险与依赖

| 风险 | 影响 | 缓解 |
|---|---|---|
| cap/pi 硬件打样周期不可控 | P2/P3 延期 | 固件与采集软件先用开发板（nRF52840-DK / RK3588 开发板）并行开发 |
| 双目标定与 3D 重建精度不达标 | max 档缩水 | P1 起即采集双人挥棒数据集，提前验证算法 |
| runtime 跨平台打包复杂度高（iOS/Android/macOS/嵌入式） | P1 延期 | P1 先交付 macOS+Android，iOS/嵌入式随后；runtime 以 C API 稳定边界，允许 Qt 侧先用 MediaPipe 参考实现作为降级路径 |
