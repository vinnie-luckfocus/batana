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
| batana-pi | 硬件+边缘软件 | Linux (RK3588) / C++ / Python / Qt6 嵌入式 | 双目采集 + 边缘推理 + 本地显示的桌面/三脚架设备（手持形态待 EVT 散热实测） |
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

- **cap → gui 或 pi**：BLE GATT 传输 IMU 数据流与设备状态；gui/pi 下发采样率、校准、OTA 命令。**cap 为单连接 Peripheral：同一时刻只允许一个 Central 连接**；max 档（pi+cap）时手机不直连 cap，经 pi 的局域网/WebSocket 间接取数。协议规范见 `batana-cap/docs/contracts/ble-protocol.md`。
- **pi 本地闭环**：双目采集 → `batana-runtime` 推理 → 嵌入式 `batana-gui` 显示，离线可用；联网后向 web 同步。
- **gui/pi ↔ runtime**：Qt6/C++ 直接链接 `batana-runtime`；runtime 对外只暴露**稳定 C API**（`runtime-api` 契约，见下表），这是 gui 与 core 之间唯一允许的耦合面。运行时依据已连接外设自动选择能力档位（见 [model-tiers.md](model-tiers.md)）。
- **gui/pi → web**：HTTPS 同步会话记录与指标（schema 由 batana-core 定义，见下文契约）；视频与模型工件经预签名 URL 直传对象存储（R2），不进 REST body。

## 4. 跨仓库契约（Contracts）

跨仓库接口只允许通过**显式版本化的契约**耦合，契约归口如下：

| 契约 | 归属仓库 | 路径 | 说明 |
|---|---|---|---|
| 会话/指标数据 Schema | batana-core | `docs/contracts/session-schema.md` | 一次挥棒会话的全部结构化数据（姿态序列、IMU 序列、时钟锚点、标定引用、评分、指标） |
| BLE 通信协议 | batana-cap | `docs/contracts/ble-protocol.md` | GATT 服务/特征、数据帧、控制命令、**时钟同步（0x05）**、协议版本协商、OTA |
| 云端同步 API | batana-web | `docs/contracts/sync-api.md` | gui/pi 与 web 之间的 REST 接口；含**视频带外上传**与**模型工件分发**（`/models/manifest`） |
| 模型能力注册表 | batana-core | `runtime/capabilities.h` + `docs/contracts/capabilities.md` | 各档位能力 id 清单，gui/web 据此动态渲染功能 |
| runtime-api | batana-core | `runtime/include/batana_runtime.h`（规划） | runtime 稳定 C API；gui/pi 与 core 的唯一耦合面，ABI 级版本化 |
| device-interfaces（含 calibration-data） | batana-pi | `docs/contracts/device-interfaces.md` | pi 采集服务接口、双目标定数据格式（core 消费并引用进 session-schema 的 `calibration` 字段） |

契约变更规则：变更必须升契约版本号、在司令塔 `repos.yaml` 登记、并同步通知所有消费方仓库。草案期版本写作 `1.0-draft`，固化后为 `1.0`；**引用 `*-draft` 上游契约的下游契约不得标记为稳定**。契约旧版本留存于各仓 `docs/contracts/archive/`。

## 5. 职责边界（裁剪线）

- **batana-core 只做模型与数据定义**：不做 UI、不直接操作硬件驱动、不做云端存储。硬件抽象由调用方注入（FrameSource / ImuSource 接口）；对外只暴露 runtime-api（稳定 C API）。
- **batana-gui 只做交互与编排**：不内置评分算法，一律调 runtime；不做服务端逻辑。
- **batana-pi 只做采集与边缘执行**：设备驱动、双目同步、散热/功耗管理、本地部署形态；算法全部来自 batana-core。pi 是标定数据（calibration-data）的生产者与契约 owner，负责标定失效检测与现场再标定流程。
- **batana-cap 只做传感与传输**：采样、缓存、BLE、圆屏基础显示；复杂评价不进入固件。圆屏仅显示片上预处理粗估值，正式评分一律来自 runtime。
- **batana-web 只做云端数据与协作**：不做实时推理（后期如需云端重分析，调用 batana-core 的 Python 侧）；承担**模型工件分发**与**固件工件托管**（版本清单）。

### OTA 三段归口

| 段 | 职责 | 归属 |
|---|---|---|
| 工件托管与版本清单 | 固件/模型工件的存储与可下载清单 | batana-web（sync-api `/models/manifest`，固件清单同机制） |
| 更新决策 | 版本比较、提示用户、触发更新 | batana-gui / batana-pi |
| 传输执行 | BLE DFU（cap）/ 系统镜像 OTA（pi） | batana-cap ble-protocol / batana-pi ota 服务 |

## 6. 软硬件版本管理

- 所有仓库独立 [Semantic Versioning](https://semver.org/lang/zh-CN/)。
- 硬件（pi/cap）另按 EVT → DVT → PVT 阶段管理结构/PCB/固件组合版本。
- 司令塔 `repos.yaml` 是唯一权威的**版本兼容矩阵**：记录每一代产品组合（如 `combo-2027A`）下各仓版本、契约版本、模型工件版本的搭配关系。
- 模型工件（`.onnx`/`.tflite`）按 `model@x.y.z` 独立编号，与代码版本解耦；batana-core 的 `models/registry.yaml` 是模型版本的唯一登记源，combo 只引用不复制。

## 7. 素材与品牌

- 项目 Logo 统一使用司令塔仓库 `assets/logo.png`（原始资产保留于此，各子仓库 README 通过 raw URL 引用，不做副本）。
- 设计素材、渲染图、宣传图存放于司令塔 `docs/assets/`，按日期归档。
