---
name: imu-integration
status: backlog
created: 2026-03-05T15:13:21Z
progress: 0%
prd: .claude/prds/imu-integration.md
github: [Will be updated when synced to GitHub]
---

# Epic: imu-integration

## Overview

集成棒尾 IMU 传感器，实现视觉+惯性数据融合分析：BLE 蓝牙连接 → 实时数据采集（100Hz 角速度/加速度）→ 时序同步 → 卡尔曼滤波融合 → 3D 轨迹重建 → 专业指标计算（高精度速度/加速度峰值/力量曲线）→ 专业报告生成。目标是突破单目视觉精度瓶颈，为专业球员提供高精度分析能力。

## Architecture Decisions

- **BLE 通信**：flutter_blue_plus 插件，支持扫描/配对/连接/断线重连
- **数据融合**：卡尔曼滤波融合视觉轨迹与 IMU 轨迹，时间戳插值对齐
- **3D 重建**：结合视觉 2D 关键点 + IMU 深度信息重建 3D 轨迹
- **模块化**：ble / fusion / professional_metrics 三层解耦，便于扩展传感器类型
- **设备兼容**：支持多款 IMU 设备（可扩展协议）

## Technical Approach

### 客户端模块
- **ble**：BLE 扫描/配对/连接管理、IMU 数据流接收、断线重连、设备状态监控
- **fusion**：时间戳对齐、卡尔曼滤波、3D 轨迹重建、数据质量评估
- **professional_metrics**：高精度速度/加速度/力量曲线/角速度曲线计算
- **report**：专业报告生成（PDF/图片）、可视化图表

### 算法层
- 时序同步：视频帧时间戳与 IMU 数据时间戳对齐，插值处理
- 卡尔曼滤波：融合视觉轨迹与 IMU 轨迹，平滑噪声
- 3D 重建：视觉 2D + IMU 深度信息 → 3D 空间轨迹

## Implementation Strategy

### 开发阶段
- M1（4 周）：BLE 连接 + IMU 数据采集 + 实时预览
- M2（4 周）：时序同步 + 卡尔曼滤波融合 + 3D 重建
- M3（3 周）：专业指标计算 + 报告生成 + 可视化
- M4（2 周）：设备校准 + 性能优化 + 稳定性测试
- M5（2 周）：专业用户试点 + 反馈迭代

### 风险缓解
- 建立 BLE 重连机制与离线缓存
- 多次校准与手动对齐辅助提升同步精度
- 小规模试点验证融合算法效果

## Task Breakdown Preview

- [ ] T1：BLE 扫描/配对/连接模块
- [ ] T2：IMU 数据流接收 + 实时预览 UI
- [ ] T3：时间戳对齐算法
- [ ] T4：卡尔曼滤波融合算法
- [ ] T5：3D 轨迹重建算法
- [ ] T6：专业指标计算（速度/加速度/力量）
- [ ] T7：专业报告生成 + 可视化图表
- [ ] T8：设备校准流程
- [ ] T9：性能优化 + 稳定性测试
- [ ] T10：专业用户试点与反馈迭代

## Dependencies

- IMU 硬件供应商（固件、BLE 协议文档）
- flutter_blue_plus 插件
- 数学库（矩阵运算、滤波算法）
- V2 可视化能力已上线

## Success Criteria (Technical)

- 融合分析耗时 ≤ 8 秒
- BLE 配对成功率 ≥ 95%
- 时序同步误差 ≤ 10 ms
- 3D 轨迹重建精度误差 < 5%（与标准设备对比）

## Estimated Effort

- 总时长：3-4 个月
- 团队规模：3-4 人（客户端 + 算法 + 硬件协作）
- 关键路径：BLE 稳定性 → 融合算法精度 → 专业用户认可
