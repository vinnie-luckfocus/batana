# Batana 生态系统总体架构

> 版本：v0.1（2026-09-17）· 状态：已生效 · 维护：batana 司令塔仓库

## 1. 系统定位

Batana 是一套**棒球打击动作捕捉、追踪、分析、评价**的模型系统，由硬件外设、边缘计算、模型核心、跨平台 GUI 与云端平台组成。本仓库（`batana`）是整个生态的**司令塔**：统一管理产品功能定义、软硬件版本、项目进度与素材资料，不含产品代码。

## 2. 仓库拓扑

```
                        ┌─────────────────────────────┐
                        │   batana（司令塔 / meta）     │
                        │ 产品定义·版本·进度·素材·契约索引 │
                        └──────────────┬──────────────┘
                                       │ repos.yaml + git submodules
        ┌──────────────┬───────────────┼───────────────┬──────────────┐
        ▼              ▼               ▼               ▼              ▼
  ┌──────────┐  ┌───────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐
  │batana-pi │  │batana-cap │  │batana-core │  │batana-gui  │  │batana-web │
  │双目边缘盒 │  │棒尾传感器  │  │模型系统核心 │  │跨平台 GUI  │  │Web 管理平台│
  └──────────┘  └───────────┘  └────────────┘  └────────────┘  └───────────┘
```

| 仓库 | 类型 | 主要技术栈 | 职责一句话 |
|---|---|---|---|
| batana-pi | 硬件+边缘软件 | Linux / C++ / Python / 嵌入式 Flutter | 双目采集 + 边缘推理 + 本地显示的手持/桌面设备 |
| batana-cap | 硬件+固件 | Zephyr RTOS / C (nRF52840) | 棒尾 IMU 传感器，BLE 传输，圆屏显示基本信息 |
| batana-core | 模型与算法 | Python（训练）+ C++17 推理运行时 | 捕捉/追踪/分析/评价的模型核心，能力分级实现 |
| batana-gui | 客户端软件 | Qt6（C++/QML，Android/iOS/macOS/嵌入式 Linux） | 跨平台交互界面，连接外设与云端 |
| batana-web | 云端平台 | Next.js / Postgres（Vercel + Neon） | 数据统计、趋势展示、会话管理，后期多租户数仓 |

## 3. 运行时数据流

```
 batana-cap                batana-pi                        batana-web
 ┌──────────┐   BLE    ┌────────────────┐    HTTPS/WebSocket   ┌──────────┐
 │ IMU 采样  │ ───────► │ 双目采集服务     │ ───────────────────► │ 数据平台  │
 │ 片上预处理 │          │ batana-runtime │                      │ 统计/趋势 │
 │ 圆屏显示  │ ◄─────── │ (max 档推理)    │ ◄─────────────────── │ 多用户数仓 │
 └──────────┘  控制/OTA └───────┬────────┘    配置下发           └──────────┘
                                │ 本机显示
                                ▼
 ┌──────────┐   BLE      ┌────────────┐
 │  智能手机 │ ◄────────► │ batana-gui │── 直接链接 ──► batana-runtime（pro/standard 档）
 └──────────┘            └────────────┘
```

- **cap → gui/pi**：BLE GATT 传输 IMU 数据流与设备状态；gui/pi 下发采样率、校准、OTA 命令。协议规范见 `batana-cap/docs/contracts/ble-protocol.md`。
- **pi 本地闭环**：双目采集 → `batana-runtime` 推理 → 嵌入式 `batana-gui` 显示，离线可用；联网后向 web 同步。
- **gui ↔ runtime**：batana-gui（Qt6/C++）直接链接 `batana-runtime`（C++ 推理库），无 FFI 边界；运行时依据已连接外设自动选择能力档位（见 [model-tiers.md](model-tiers.md)）。
- **gui/pi → web**：HTTPS 同步会话记录与指标（schema 由 batana-core 定义，见下文契约）。

## 4. 跨仓库契约（Contracts）

跨仓库接口只允许通过**显式版本化的契约**耦合，契约归口如下：

| 契约 | 归属仓库 | 路径 | 说明 |
|---|---|---|---|
| 会话/指标数据 Schema | batana-core | `docs/contracts/session-schema.md` | 一次挥棒会话的全部结构化数据（姿态序列、IMU 序列、评分、指标） |
| BLE 通信协议 | batana-cap | `docs/contracts/ble-protocol.md` | GATT 服务/特征、数据帧、控制命令、OTA |
| 云端同步 API | batana-web | `docs/contracts/sync-api.md` | gui/pi 与 web 之间的 REST/WS 接口 |
| 模型能力注册表 | batana-core | `runtime/capabilities.h` + `docs/contracts/capabilities.md` | 各档位能力 id 清单，gui/web 据此动态渲染功能 |

契约变更规则：变更必须升契约版本号、在司令塔 `repos.yaml` 登记、并同步通知所有消费方仓库。

## 5. 职责边界（裁剪线）

- **batana-core 只做模型与数据定义**：不做 UI、不直接操作硬件驱动、不做云端存储。硬件抽象由调用方注入（camera source / IMU source 接口）。
- **batana-gui 只做交互与编排**：不内置评分算法，一律调 runtime；不做服务端逻辑。
- **batana-pi 只做采集与边缘执行**：设备驱动、双目同步、散热/功耗管理、本地部署形态；算法全部来自 batana-core。
- **batana-cap 只做传感与传输**：采样、缓存、BLE、圆屏基础显示；复杂评价不进入固件。
- **batana-web 只做云端数据与协作**：不做实时推理（后期如需云端重分析，调用 batana-core 的 Python 侧）。

## 6. 软硬件版本管理

- 所有仓库独立 [Semantic Versioning](https://semver.org/lang/zh-CN/)。
- 硬件（pi/cap）另按 EVT → DVT → PVT 阶段管理结构/PCB/固件组合版本。
- 司令塔 `repos.yaml` 是唯一权威的**版本兼容矩阵**：记录每一代产品组合（如 `combo-2027A`）下各仓版本、契约版本、模型工件版本的搭配关系。
- 模型工件（`.onnx`/`.tflite`）按 `model@x.y.z` 独立编号，与代码版本解耦，登记于 batana-core 的 `models/registry.yaml`。

## 7. 素材与品牌

- 项目 Logo 统一使用司令塔仓库 `assets/logo.png`（原始资产保留于此，各子仓库 README 通过 raw URL 引用，不做副本）。
- 设计素材、渲染图、宣传图存放于司令塔 `docs/assets/`，按日期归档。
