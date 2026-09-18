# Batana 生态路线图

> 版本：v0.4（2026-09-18）· 粒度：阶段（Phase）→ 里程碑（M）· 进度跟踪以 `repos.yaml` 与各仓 GitHub Projects 为准
>
> v0.4 变更：batana-pi 新增外观与外壳（ID/MD）工作线——EVT 原型定为开发板+相机模组+脚架/围栏挂钩（无正式外壳），外观 ID 与外壳工程在 DVT 冻结。
>
> v0.3 变更：M0 双目验证项对齐相机双轨决策（USB3 整模组并行首选 + VEYE MIPI plan B），新增 `docs/m0-setup.md` 物料与搭建入口。
>
> v0.2 变更：依据四方评审（架构/契约/硬件/选型）整改——新增 M0 技术验证 spike、P2 串行化拆分、SoC 冻结、出口标准补测量方法、人力预算显性化。

## 总览

```
2026 Q4          2027 Q1          2027 Q2          2027 Q3          2027 Q4
─────────────────────────────────────────────────────────────────────────────
P0 生态重组
   M0 技术验证 spike（RK3588 基准 / Qt6 嵌入式 / 240fps 采集）
   P1 core 单目管线产品化
                     P2a cap 固件 + BLE 协议（开发板）
                          P2b IMU 融合（core + gui）
                                        P3 pi 原型 + 双目 max
                                                           P4 web 平台 v1（单用户）
                                                                              P5+ 数仓/教练模式（stretch）
```

> 串行化原则：本生态当前为个人/极小团队维护，**同一季度最多一条硬件线 + 一条软件线**。cap 与 pi 硬件不相邻连发。

## P0 — 生态重组（2026-09，当前）

目标：完成多仓库拆分，确立契约与版本管理机制。

- [x] 司令塔文档：架构 / 能力分级 / 路线图 / 模块边界
- [x] 创建子仓库：batana-core / batana-app / batana-gui / batana-pi / batana-cap / batana-web
- [x] 界面层拆分（2026-09-17）：batana-app（Flutter 移动/桌面）+ batana-gui（Qt6 嵌入式，仅 pi 显示屏）
- [x] 旧 Flutter MVP 方案彻底放弃（2026-09-17 决策），代码留存主仓 git 历史 tag `archive/flutter-mvp` 仅作参考
- [x] 司令塔仓库移除产品代码，保留 logo、文档、PM 体系
- [x] 四路方案评审与高优先级整改（时钟同步、IMU 量程、契约对齐、BLE 角色、SoC 冻结）
- [x] 契约 v1 定稿评审：session-schema / ble-protocol / sync-api / capabilities 已于 2026-09-17 冻结为 **1.0 稳定版**（终检修复 9 项阻塞问题：sync-api 补 duration_ms/calibration/clock_anchor、统一 cap_id/session_id/metrics 必填性、schema 补 video.sha256 与 64 位时钟声明、capabilities 补变更记录）

## M0 — 技术验证 spike（2026-10，P1 前置门槛）

目标：用实测数据拍板剩余的技术风险。**物料清单与平台搭建步骤见 `docs/m0-setup.md`。** 2026-09-17 架构调整后（batana-app 回 Flutter、batana-gui 收窄嵌入式），原 Qt6 移动端三项风险（iOS 合规、240fps、Qt BLE）已消除，M0 大幅瘦身：

| 验证项 | 方法 | 通过标准 | 降级预案 |
|---|---|---|---|
| RK3588 NPU 基准 | Radxa ROCK 5B+ 16GB（EVT 选定开发板）跑 BlazePose 级 TFLite→RKNN 模型 | 单帧 ≤ 20ms（INT8） | max 档延迟目标放宽或管线裁剪 |
| Qt6 嵌入式构建链 | Yocto/meta-qt6 在 RK3588 开发板构建 batana-gui HelloWorld 并点亮屏幕 | 可复现构建 + eglfs 显示正常 | pi 显示改用 LVGL 轻量界面（功能裁剪） |
| Flutter 高帧率采集 | batana-app 原型在 iOS/Android 真机 240fps 采集 | 稳定采集 10 分钟 | 降帧 120fps 并评估精度影响 |
| 双目 120fps 采集（双轨并行） | 路线 A：USB3 双目整模组（OV9281，免驱，基线可调 60–120mm）；路线 B：双 VEYE SC132M MIPI（BSP 树内驱动，FSIN 经 40-pin 飞线） | 双摄 120fps 稳定采集 30 分钟、帧配对误差 < 100µs；挥棒场景 3D 重建精度 ≤ 15mm@2.5m（两路线定案依据） | 降帧 60fps；单路线定案；两路线均失败退回 OAK-D-S2 |

## P1 — core 单目管线产品化（2026 Q4，约 12 人周）

目标：在 batana-core 中从头实现单目分析管线（旧 Flutter MVP 仅作算法参考），实现 **standard-vision** 档。

- M1.1 batana-core v0.1：Python 侧管线骨架 + session-schema v1 + 规则评分引擎；**MediaPipe 仅作关键点拓扑规范来源与对照工具，生产管线跑自训练/导出的 TFLite 模型**
- M1.2 batana-runtime v0.1：C++ 推理运行时，**唯一跨平台后端 TFLite（+delegates）**，稳定 C API（runtime-api 契约 v1）；导出链数值一致性测试（PyTorch vs TFLite）
- M1.3 batana-app v0.1：Flutter 应用骨架，dart:ffi 接入 runtime 走通"录制→分析→评分→展示"；**出口平台 macOS + Android**
- M1.4 iOS/Windows 端打通 + 四平台 runtime 打包 CI
- M1.5 数据集里程碑 v1：≥ 200 段标注挥棒视频（含借用雷达枪/高速摄影采集棒速真值子集 ≥ 50 段）
- 出口标准（macOS+Android 双端）：全链路走 runtime；分析完成率 ≥ 85%（以 M1.5 数据集回放为分母，"完成"=出分且无崩溃）；单次分析 ≤ 15s（计时起点=录制结束，终点=评分页渲染完成，不含上传）

## P2a — batana-cap 固件与 BLE 协议（2027 Q1，约 8 人周）

目标：开发板先行，协议跑通。**不做自研 PCB。**

- M2a.1 cap 固件 v0.1（Zephyr，nRF52840-DK + LSM6DSO32X  breakout）：200Hz 采样、800Hz 爆发模式、BLE GATT v1（含时钟同步 0x05、协议版本协商、丢帧补发）、LE Secure Connections
- M2a.2 时钟同步实测：与手机/pi 主机时钟对齐误差 ≤ 2ms（10 分钟会话漂移实测）
- 出口标准：DK 板上 200Hz 连续 30 分钟丢帧率 < 0.1%；时钟对齐达标

## P2b — IMU 融合与 cap EVT 硬件（2027 Q2，约 10 人周）

目标：**standard-imu** 与 **pro-fusion** 档 + cap EVT 样机。

- M2b.1 batana-core v0.2：IMU 管线（棒速估计、挥棒计数、节奏）+ 视觉-惯性时序对齐（基于 clock_anchor）
- M2b.2 batana-app v0.2：BLE 连接管理、融合分析 UI、cap 圆屏联动
- M2b.3 cap 硬件 EVT：LSM6DSO32X + GC9A01 圆屏 + 锂电，3D 打印结构；单连接拓扑确认
- 出口标准：手机+cap 融合分析 ≤ 8s（口径同 P1）；棒速估计误差 ≤ 10%（真值=M1.5 雷达枪基准子集，逐段比对峰值棒速）

## P3 — batana-pi 原型与双目 max（2027 Q3，约 12 人周）

目标：pi 原型 + **pro-stereo** 与 **max** 档。**SoC 已冻结 RK3588**（RPi5 无 NPU，仅可作联调开发板，不承担性能指标）。

- M3.1 pi 软件栈 v0.1（RK3588 开发板 + USB3 全局快门双目模组先行）：双目同步采集服务、标定工具、runtime RKNN 后端、IMU 触发裁剪（只分析挥棒段 0.3–0.5s）
- M3.2 batana-core v0.3：双目 3D 管线（pose3d、bat_traj3d、kinematic_seq、impact_point、biomech_report）
- M3.3 嵌入式 batana-gui：Qt6/QML 嵌入式构建（Yocto 集成）部署到 pi 显示屏
- M3.4 pi EVT 形态决策：满载 NPU 30 分钟温升/降频曲线实测 → 桌面/三脚架 vs 手持（RK3588 满载 6–10W，手持存疑）；**EVT 结构原型 = 开发板 + 相机模组 + 脚架/围栏挂钩支架（无正式外壳）**
- 出口标准：pi+cap 全量分析 ≤ 8s（口径同 P1，含 IMU 触发裁剪）；3D 棒轨迹空间误差 ≤ 15mm@2m（真值=标定板网格回放比对，规程见 device-interfaces 契约）

## P4 — batana-web 平台 v1（2027 Q4，约 8 人周）

目标：云端数据闭环（**单用户范围，多租户明确移出**）。

- M4.1 web v0.1：Next.js + Postgres + R2，sync-api v1，会话/指标云端存储、视频带外上传、模型工件分发
- M4.2 数据统计与趋势展示：个人仪表盘、训练历史趋势图
- M4.3 app/pi 云同步：OIDC PKCE 账号体系（单用户多设备）
- 出口标准：端到端同步成功率 ≥ 99%（含离线队列重放）；仪表盘首屏 ≤ 2s（P95，4G 网络节流）

## P5+ — 后续（2028 起，stretch）

- 多身份/多用户数仓（球员/教练/机构）、教练模式、AI 动作指导模型化
- cap/pi DVT 小批量（pi 含外观 ID 与外壳工程冻结、DFM 评估）
- pro-fusion 的 bat_traj3d 由粗略升级为可用（视频-IMU 联合标定自动化）

## 风险与依赖

| 风险 | 影响 | 缓解 |
|---|---|---|
| Flutter 高帧率采集不达 240fps | standard 档精度受限 | M0 真机验证；降级 120fps 并评估精度影响 |
| RK3588 NPU 性能不足 8s 预算 | P3 出口失败 | M0 基准实测 + IMU 触发裁剪 + tracker ROI；仍不足则放宽目标或降分辨率 |
| IMU 量程饱和 | IMU 档全部失效 | 已整改：选型 LSM6DSO32X（±32g/±4000dps）；DVT 评估是否加高 g 加速度计 |
| 时钟漂移破坏融合 | pro/max 精度失效 | 已整改：ble-protocol 时钟同步命令 0x05 + clock_anchor 契约字段，M2a.2 实测验收 |
| 数据集不足 | P3 3D 管线无法训练 | M1.5 数据集里程碑正式立项，含真值采集 |
| cap/pi 硬件打样周期不可控 | P2b/P3 延期 | 开发板先行（P2a 用 DK，P3 EVT=开发板+模组），自研 PCB 推迟 |
| runtime 跨平台打包复杂度 | P1 延期 | M1.4 四平台打包 CI 提前建立；降级路径：app 侧调用 runtime 内置的参考管线（仍在 runtime 边界内，不违反裁剪线） |
