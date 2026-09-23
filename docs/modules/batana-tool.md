# batana-tool — batana-core 素材采集与标注工具

> 仓库：`vinnie-luckfocus/batana-tool` · 状态：active

## 定位

为 batana-core 模型训练高效生产标注素材的 macOS 桌面工具：MacBook + Type-C USB3 双目模组架设于打击区旁，人站上打击区自动识别就位，中文语音引导挥棒，挥棒自动检测分段保存；配套骨架叠加审核、手动修正、修剪与契约格式导出。是 M1.5 数据集里程碑（≥200 段标注挥棒视频）的生产力载体。

## 功能清单

- 双目采集：UVC 免驱接入、左右目切分、无损存储（FFV1）、逐帧时间戳
- 自动编排：打击区 ROI 配置、就位检测、中文语音引导（macOS `say`）、挥棒运动能量检测 + 预录环缓冲自动分段、状态机（IDLE→READY→ARMED→SWING→SAVING 循环）
- 采集会话管理：自动编号、重拍/丢弃、暂停继续、崩溃恢复
- 骨架标注：MediaPipe 33 关键点逐帧推理（对齐 core pose2d 拓扑）、置信度
- 审核修正：骨架叠加回放、关键点拖动修正（manual 标记）、重跑单帧/整段、片段修剪
- 导出：合格/不合格/待复核标记，导出对齐 session-schema 的素材目录（session.json + 双目视频 + 时间戳 + pose2d + capture_meta），导出前契约校验

## 边界

- ✅ 做：素材采集、自动分段、骨架标注与人工修正、素材审核与导出
- ❌ 不做：模型训练与评分（batana-core）、云同步（batana-web）、IMU/cap 融合（P2b 后扩展）、非 macOS 平台验收

## 技术栈与结构

> 2026-09-23 起基于 **Tauri 2（Rust + WebView）** 重构（应用名 BatanaTool）；PySide6 旧实现留存于 tag `archive/pyside6`。UI 遵循 `docs/uiux-guidelines.md`。

- Tauri 2 + Rust（采集/检测/落盘/导出）+ 原生 TypeScript 前端（无框架）· 采集与编码经 ffmpeg 子进程 · 语音 macOS `say` · NSVisualEffectView 毛玻璃
```
batana-tool/
├── src/             # 前端：三页（采集/素材复核/设置）+ 设计令牌
├── src-tauri/src/
│   ├── capture/     # ffmpeg avfoundation 帧源、设备枚举、SBS 切分、环缓冲、FFV1 落盘
│   ├── detect/      # ROI 就位检测（就位冻结背景）、挥棒运动占比检测
│   ├── state.rs     # 状态机 IDLE→READY→ARMED→SWING→SAVING
│   ├── session/     # session-schema 导出、素材库索引、设置持久化
│   └── voice.rs     # macOS say 语音引导
└── docs/            # PRD 与评审记录
```
- 测试：`src-tauri` 64 项 Rust 测试（含 batana-core 契约校验集成测试）

## 对外契约

- 消费：**session-schema**（导出格式对齐，owner: batana-core）、**capabilities**（pose2d 拓扑与关键点顺序约定）
- 集成：复用 batana-core `tools/calibration` 标定结果（calibration JSON 导入，3D 质量预览）
- **硬同步义务（2026-09-20 决策）**：batana-core 的契约/模型工件有任何升级，本仓必须同批升级，保证"tool 产出的素材 core 完美使用"（验收 = 导出过 core `validate_session.py` 全量校验 + core 管线回放通过；combo 绑定，见司令塔 versioning.md §4）

## 里程碑映射

- v0.1（MVP，2026-10）：采集自动化 + 基础导出——支撑 M1.5 视频素材批量采集（M0 G1 后启动）
- v0.2：骨架标注 + 手动修正 + 修剪——支撑标注素材生产
- v0.3：批量导出与真值子集工具（雷达枪读数录入）、3D 质量预览
