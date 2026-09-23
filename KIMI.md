# KIMI.md

> 本文件是 Kimi Code 在本仓库的工作约定。本项目所有对话、文档、代码注释均使用中文！

## 项目概述

batana（本仓库）是 **Batana 生态的司令塔（meta 仓库）**，不含产品代码。职责：

- 产品功能定义与总体架构（`docs/architecture.md`）
- 模型能力分级 max / pro / standard（`docs/model-tiers.md`）
- 路线图与项目进度（`docs/roadmap.md`、`repos.yaml`）
- **生态 UI/UX 统一规范（`docs/uiux-guidelines.md`，所有界面仓必须遵循）**
- 软硬件版本与兼容矩阵（`repos.yaml`、`docs/versioning.md`）
- 素材资料与品牌资产（`assets/logo.png`、`docs/assets/`）
- 子仓库以 git submodule 挂载于 `projects/`，锁定到兼容验证过的版本

### 子仓库

| 仓库 | 职责 | 技术栈 |
|---|---|---|
| batana-core | 模型系统核心（管线/算子/推理运行时/训练） | Python + C++17 |
| batana-app | 跨平台移动/桌面应用（iOS/Android/macOS/Windows） | Flutter |
| batana-gui | 嵌入式 GUI（batana-pi 显示屏） | Qt6（C++/QML） |
| batana-pi | 双目边缘计算设备 | Linux (RK3588) / C++ / Python |
| batana-cap | 棒尾 IMU 传感器 | Zephyr RTOS / C |
| batana-web | Web 管理平台（统计/趋势/数仓） | Next.js / Postgres |
| batana-tool | batana-core 素材采集与标注工具（macOS，BatanaTool） | Tauri 2 / Rust / TypeScript |

各模块功能与边界：`docs/modules/<repo>.md`。**跨仓库改动必须先查契约归属表**（见 architecture.md 第 4 节）。

### 历史决策

- 2026-09-17：旧 Flutter MVP 方案彻底放弃，代码留存 tag `archive/flutter-mvp` 仅作参考。
- 2026-09-17：界面层拆分——batana-app（Flutter，iOS/Android/macOS/Windows）+ batana-gui（Qt6 嵌入式，仅 batana-pi 显示屏）。注意：app 虽用 Flutter 但全新实现，不复用旧 MVP 代码。
- 2026-09-21：弃用 CCPM（Claude Code PM）体系，移除 `.claude/`；项目管理以 roadmap + repos.yaml + 各仓 GitHub Issues 为准。
- 2026-09-23：batana-tool 基于 Tauri 2 重构（PySide6 实现归档 tag `archive/pyside6`）；生态 UI/UX 统一规范 v1.0 生效（`docs/uiux-guidelines.md`，所有界面仓必须遵循）。

## 开发规范

### 语言要求
- 所有对话、文档、代码注释、commit message 均使用中文
- 变量名、函数名使用英文（遵循各语言规范）

### 司令塔仓库规则
- 不在本仓库写产品代码；产品代码一律进入对应子仓库
- 子仓库发版 / 契约变更后必须更新 `repos.yaml`
- 文档修订需更新文件头部的版本与日期
- 子模块指针只在 combo 兼容验证后前进
- **core↔tool 硬同步（2026-09-20 决策）**：batana-core 的 session-schema / capabilities / 模型工件（`models/registry.yaml`）有任何升级改动，batana-tool 必须同步升级并验证"tool 产出的素材 core 完美可用"（tool 导出须通过 core `tools/validate_session.py` 全量校验 + core 管线回放通过）；两者在 combo 中绑定验证，不得单独前进

### Git 协作约定
- commit 使用中文 conventional commit（如 `feat:` / `fix:` / `docs:` / `chore:`）
- 本机代理 127.0.0.1:7897 常失效，git 网络操作统一绕过：
  `git -c http.proxy= -c https.proxy= push`（clone/pull/submodule 同理）
- 子仓改动后的司令塔同步流程：子仓 commit+push → `git -C projects/<名> pull --ff-only`（带代理绕过参数）→ add 子模块指针 + 同步 repos.yaml/相关文档 → 司令塔 commit+push

### 文档规范
- 单个文件不超过 800 行
- 模块文档固定结构：定位 / 功能清单 / 边界（做与不做）/ 技术栈与结构 / 对外契约 / 里程碑映射

## 当前状态（2026-09-21）

**P0 已完成（契约 1.0 定稿）→ M0 技术验证 spike 进行中（阶段门 G0 → G1 → G2，见 roadmap v0.6）**

各仓实况：

| 仓库 | 状态 | 说明 |
|---|---|---|
| batana-tool | active，**v0.1.0 已发布**（87e8025，tag v0.1.0 + GitHub Release） | **2026-09-23 Tauri 2 重构**：Rust 核心（ffmpeg 采集/检测/落盘/session 导出，64 项测试含 core 契约校验全绿）+ 原生 TS 三页 UI（macOS 原生风，遵循生态 UI/UX 规范）+ logo 图标 + 毛玻璃窗口；PySide6 旧实现归档 tag archive/pyside6 |
| batana-core | active（b68044a） | 契约 session-schema / capabilities 1.0 定稿；标定与 3D 工具链 + 管线骨架 + 合成数据端到端验证，35 项测试全绿 |
| batana-pi | active（eb02621） | M0 G0 验证工具链就绪：UVC 冒烟探针 / RKNN 基准 / Yocto 层骨架；EVT 选型 ROCK 5B+ 16GB；**相机（HBVCAM-W2237-2）已到货，MacBook 首测通过（免驱/USB3 5Gbps/档位属实/真双目），AVFoundation 75fps 上限记录在案** |
| batana-app | planning（2811fa5） | Flutter 骨架 + M0-V3 高帧率采集探针（平台通道直连 AVFoundation/Camera2） |
| batana-gui | planning（dc51885） | Qt6/QML 嵌入式 HelloWorld 骨架（eglfs 验证用） |
| batana-cap | planning（bd23cda） | ble-protocol 1.0 定稿，无代码 |
| batana-web | planning（772ac21） | sync-api 1.0 定稿，无代码 |

已验证的跨仓配合：

- **core↔tool 硬同步实测通过（2026-09-21）**：tool 全管线产出的 session 经 core `tools/validate_session.py` 全量校验通过
- 契约矩阵见 `repos.yaml`：session-schema / capabilities / ble-protocol / sync-api 均 1.0 稳定；device-interfaces 1.0-draft；runtime-api 待 P1

待办与阻塞：

- M0 G0 剩余项：V0a FOV/binning 实测量角、V0c 标定初测（待标定板）、V1 NPU 基准与 120fps 满速复测（待 ROCK 5B+ 到货）——工具链均已就绪
- R2/R3：RKNN 转换与 Yocto 构建需 Linux 环境（OrbStack / UTM / 云主机），**用户尚未选定**
- V3：用户手机是否支持 1080p240 未确认

## 核心原则

1. **Fail Fast** - 检查关键前提条件，然后执行
2. **Trust the System** - 不要过度验证很少失败的内容
3. **Clear Errors** - 失败时说明具体问题和解决方法
4. **Minimal Output** - 显示重要内容，跳过装饰

## 状态指示符

- ✅ 成功（谨慎使用）
- ❌ 错误（始终包含解决方案）
- ⚠️ 警告（仅在需要操作时使用）
- 正常输出不使用 emoji
