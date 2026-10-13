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
| batana-tool | batana-core 素材采集与标注工具（macOS，BatanaTool） | Python / PySide6 |

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

## 当前状态（2026-10-14）

**P0 已完成（契约 1.0 定稿）→ M0 技术验证 spike 进行中（阶段门 G0 → G1 → G2，见 roadmap v0.6）；M1.5 素材生产线已闭环，进入量产阶段；tool v0.5.1 标定与 3D 重建实机故障修复，真实素材 3D 重建全量通过（精度 B/C）**

各仓实况：

| 仓库 | 状态 | 说明 |
|---|---|---|
| batana-tool | active，**v0.5.1**（be6f83b，Python/PySide6） | 标定（设置页：抽帧 → 调 core ChArUco 标定 → 存档；名义标定兜底仅供冒烟）+ 3D 重建（审核页：双骨架 → core 批量三角化 → pose3d.json + 合理性报告「链路判定 + 精度 A/B/C」两维口径）；导出 session 自动附标定。**2026-10-14 实机修复**：双目跑骨架右目初始偏移（根因：两目共用同一 MediaPipe 估计器实例，VIDEO 模式跟踪状态跨目续跑；改为估计器工厂每目独立实例）；直接 MediaPipe 骨架 3D 重建判异常无法通过（根因：逐帧 2D 抖动 + 双目对应不一致被裸三角化放大；修复：三角化前时序中值平滑 + visibility 掩蔽 + 极线校正，报告改鲁棒统计分层）。既有：采集（120fps 双目 + 视觉引导）→ 审核 → 骨架标注 → 传播修正 → 导出（过 core 全量校验）。177 项测试全绿 |
| batana-core | active（4d90f40） | 契约 session-schema / capabilities 1.0 定稿；标定与 3D 工具链 + 管线骨架 + 合成数据端到端验证；models/registry.yaml 首个模型工件登记；triangulate 批量模式 + **三角化前处理（时序中值平滑 / visibility 掩蔽 / 极线校正）**，51 项测试全绿 |
| batana-pi | active（44e3c62） | M0 G0 验证工具链就绪：UVC 冒烟探针 / RKNN 基准 / Yocto 层骨架；EVT 选型 ROCK 5B+ 16GB；相机（HBVCAM-W2237-2）MacBook 首测通过，10 分钟长测无掉帧；**tool 侧实测 1280x400@120 可满速（120.2fps，2026-10-08 素材时间戳实证），AVFoundation 75fps 上限系旧 OpenCV 路径结论，ffmpeg 后端已突破** |
| batana-app | planning（2811fa5） | Flutter 骨架 + M0-V3 高帧率采集探针（平台通道直连 AVFoundation/Camera2） |
| batana-gui | planning（dc51885） | Qt6/QML 嵌入式 HelloWorld 骨架（eglfs 验证用） |
| batana-cap | planning（bd23cda） | ble-protocol 1.0 定稿，无代码 |
| batana-web | planning（772ac21） | sync-api 1.0 定稿，无代码 |

已验证的跨仓配合：

- **core↔tool 硬同步实测通过（2026-09-21）**：tool 全管线产出的 session 经 core `tools/validate_session.py` 全量校验通过
- **core 模型工件 → tool 引用链路打通（2026-10-12）**：tool 自动探测 core 仓 models/files/ 的 pose 模型，真实素材骨架叠加验证通过
- **core 3D 管线经 tool 集成路径端到端验证（2026-10-13）**：tool 抽帧 → core ChArUco 标定（合成装置渲染帧：基线恢复 100.05mm/真值 100mm，立体 RMS 0.094px）；tool 双骨架 → core 批量三角化 → pose3d（真参标定下重建误差中位 <0.001mm，骨长/深度合理性报告判「链路合理」）。**真实素材冒烟（4 段双骨架旧片段，640×400/眼 + 名义标定）**：深度中位 2.1–2.45m 与实际架设吻合、Z>0 ≈99%、骨长中位数合理（上臂 0.37m/肩宽 0.31m），链路可用；暴露的下一步问题——原始逐帧三角化对双目 2D 抖动敏感（骨长帧间 CV 超标，野值帧为 MediaPipe 双目对应不一致所致），core 管线需时序滤波与低置信对应点剔除，且真实标定 + 1280×720 档位可显著降噪声。**已闭环（2026-10-14，tool v0.5.1 + core 4d90f40）**：三角化前平滑/掩蔽/极线校正 + 报告两维分层后，4 段真实片段全部判「链路合理」（精度 B×1 / C×3，C 为 640×400 旧档位的数据噪声下限，附升级建议）。真实素材精度结论仍待标定板到货走 V0c
- 契约矩阵见 `repos.yaml`：session-schema / capabilities / ble-protocol / sync-api 均 1.0 稳定；device-interfaces 1.0-draft；runtime-api 待 P1

### 进度节奏复盘（2026-10-12）

**节奏判断：软件线超前，硬件线停滞在物料等待——整体健康，M1.5 是当前主战场。**

- M0 G0 计划 D1–D7，实际已 ~3 周：V0b 通过（且 tool 实证 120fps 满速），V0a 量角/V0c 标定待标定板，V1/V4 待 ROCK 5B+，R2/R3 待 Linux 环境选定。**阻塞全部是物料/环境，非技术不确定性**——符合阶段门设计意图（先花小钱排大雷），等待期没有空转：tool 从能录进化到能标注。
- M1.5（≥200 段标注素材，真值子集 ≥50 段）原定 G1 启动，实际 G0 期已提前采集 26 段，今日标注链路闭环后**具备量产条件**。当前缺口：已标注 0 段；真值子集所需雷达枪/高速摄影**尚未安排采购或借用**，是 M1.5 下一阻塞点。
- M1.1 core 管线目前只跑过合成数据；素材量产后应立即转入**真实素材联调**（姿态→相位→评分链路），让数据问题在早期暴露。

下一步优先级（按解锁价值排序）：

1. **素材量产**：按节奏采集+标注（建议每周 ≥50 段，4 周达成 200 段）；标注即跑骨架+人工修正+标记合格
2. **core 真实素材联调**：用已标注素材跑 core 管线，替代纯合成数据验证
3. 真值采集安排：雷达枪/高速摄影（借用优先），解锁 ≥50 段真值子集
4. 标定板到货 → V0c 标定初测（解锁双目 3D）；ROCK 5B+ 到货 → V1/V4
5. Linux 环境选定（OrbStack / UTM / 云主机）→ 解锁 RKNN 转换与 Yocto 构建

### 待办与阻塞

- M0 G0 剩余项：V0a FOV/binning 实测量角（MacBook 可做，只需量角参照物）、V0c 标定初测（待标定板）、V1 NPU 基准与 V4 120fps 复测（待 ROCK 5B+ 到货）
- R2/R3：RKNN 转换与 Yocto 构建需 Linux 环境（OrbStack / UTM / 云主机），**用户尚未选定**
- V3：用户手机是否支持 1080p240 未确认
- M1.5 真值子集：雷达枪/高速摄影未安排

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
