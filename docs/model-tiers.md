# 模型能力分级：max / pro / standard

> 版本：v0.1（2026-09-17）· 归属：batana-core 实现，本文件为产品侧定义

## 1. 设计原则

外设不同，模型能力不同。batana-core 以**模态输入声明**抽象每条分析管线：管线声明所需输入模态（`stereo` / `mono` / `imu`）与产出的能力 id。运行时探测当前已连接的外设，自动选择可用的最高档位；外设热插拔时降级/升级无缝切换。GUI 与 Web 通过**能力注册表**查询当前档位，动态显示/隐藏功能。

## 2. 档位矩阵

| 档位 | 输入组合 | 典型设备组合 | 延迟目标 |
|---|---|---|---|
| **standard-vision** | 仅单目视频 | 仅手机 | 单次分析 ≤ 15s（沿用 MVP 指标，逐步优化到 ≤ 10s） |
| **standard-imu** | 仅 IMU | 仅 batana-cap | 棒速/计数近实时（≤ 1s） |
| **pro-fusion** | 单目视频 + IMU | 手机 + batana-cap | 融合分析 ≤ 8s |
| **pro-stereo** | 仅双目视频 | 仅 batana-pi | 3D 分析 ≤ 8s（边缘端） |
| **max** | 双目视频 + IMU | batana-pi + batana-cap | 全量分析 ≤ 8s（边缘端） |

## 3. 能力清单（capability registry v1）

| 能力 id | 说明 | standard-vision | standard-imu | pro-fusion | pro-stereo | max |
|---|---|:-:|:-:|:-:|:-:|:-:|
| `pose2d` | 2D 身体关键点（33 点） | ✅ | — | ✅ | ✅ | ✅ |
| `phase_split` | 挥棒阶段分割（准备/加速/击球/收尾） | ✅ | 粗分割 | ✅ | ✅ | ✅ |
| `score_basic` | 速度/角度/协调性基础评分 | ✅ | 部分 | ✅ | ✅ | ✅ |
| `bat_speed` | 棒速估计 | 粗略 | ✅ | ✅（融合校正） | ✅（3D） | ✅（精确） |
| `swing_count` | 挥棒计数与节奏 | — | ✅ | ✅ | ✅ | ✅ |
| `tempo_sync` | 视觉-惯性时间戳对齐 | — | — | ✅ | — | ✅ |
| `bat_traj3d` | 3D 棒轨迹重建 | — | — | 粗略（单目+IMU 约束） | ✅ | ✅ |
| `kinematic_seq` | 髋-肩-棒运动链时序 | — | — | 部分 | 部分 | ✅ |
| `impact_point` | 击球点/击球甜区估计 | — | — | — | 部分 | ✅ |
| `pose3d` | 全身 3D 运动学 | — | — | — | ✅ | ✅ |
| `biomech_report` | 完整生物力学报告 | — | — | — | — | ✅ |
| `coach_advice` | AI 改进建议 | 规则引擎 | 规则引擎 | 规则+数据 | 规则+数据 | 模型生成 |

## 4. 实现约束

- **batana-core 必须为每个档位提供独立可测的管线**；档位之间共享底层算子（关键点检测、滤波、时序对齐），不允许复制实现。
- standard-imu 的片上部分（cap 固件内的中断唤醒、计数）只属于设备端预处理；正式评分仍在 runtime。
- 档位选择对用户透明：UI 只呈现"当前可用能力"，不出现"请购买/连接 XX 以解锁"之外的档位概念术语。

## 5. 演进方向

- v2：引入视频-IMU 联合标定自动化，pro-fusion 的 `bat_traj3d` 从粗略升级为可用。
- v3：`coach_advice` 由规则引擎切换为生成式模型（云端 batana-core Python 侧）。
