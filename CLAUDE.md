# CLAUDE.md

> Think carefully and implement the most concise solution that changes as little code as possible.

## 本项目所有对话、文档、代码注释均使用中文!

## Project Overview

batana（本仓库）是 **Batana 生态的司令塔（meta 仓库）**，不含产品代码。职责：

- 产品功能定义与总体架构（`docs/architecture.md`）
- 模型能力分级 max / pro / standard（`docs/model-tiers.md`）
- 路线图与项目进度（`docs/roadmap.md`、`.claude/` CCPM 体系）
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

各模块功能与边界：`docs/modules/<repo>.md`。**跨仓库改动必须先查契约归属表**（见 architecture.md 第 4 节）。

### 历史决策

- 2026-09-17：旧 Flutter MVP 方案彻底放弃，代码留存 tag `archive/flutter-mvp` 仅作参考。
- 2026-09-17：界面层拆分——batana-app（Flutter，iOS/Android/macOS/Windows）+ batana-gui（Qt6 嵌入式，仅 batana-pi 显示屏）。注意：app 虽用 Flutter 但全新实现，不复用旧 MVP 代码。

## Project Management Workflow

本项目使用 CCPM (Claude Code Project Management) 系统管理开发流程。跨仓库 Epic 在司令塔立项，任务落到对应子仓库的 GitHub Issues。

### 核心命令
```bash
# PRD 管理
/pm:prd-new <feature>        # 创建产品需求文档
/pm:prd-parse <feature>      # 将 PRD 转换为技术 Epic

# Epic 管理
/pm:epic-decompose <epic>    # 将 Epic 拆解为具体任务
/pm:epic-sync <epic>         # 同步 Epic 到 GitHub
/pm:epic-start <epic>        # 开始 Epic 开发（创建分支）

# Issue 管理
/pm:issue-start <number>     # 开始任务开发
/pm:issue-sync <number>      # 同步任务进度到 GitHub
/pm:issue-close <number>     # 完成任务

# 状态查看
/pm:status                   # 查看项目整体状态
/pm:next                     # 查看下一个待处理任务
```

### 目录结构
```
.claude/
├── prds/              # 产品需求文档
├── epics/             # 技术实施 Epic
├── rules/             # 项目规则与标准
├── agents/            # 专用 Agent 定义
├── commands/          # PM 命令实现
└── context/           # 项目上下文
```

## Development Guidelines

### 语言要求
- 所有对话、文档、代码注释均使用中文
- 变量名、函数名使用英文（遵循各语言规范）

### 司令塔仓库规则
- 不在本仓库写产品代码；产品代码一律进入对应子仓库
- 子仓库发版 / 契约变更后必须更新 `repos.yaml`
- 文档修订需更新文件头部的版本与日期
- 子模块指针只在 combo 兼容验证后前进

### 文档规范
- 单个文件不超过 800 行
- 模块文档固定结构：定位 / 功能清单 / 边界（做与不做）/ 技术栈与结构 / 对外契约 / 里程碑映射

## Key Rules

项目规则汇总于 [`.claude/CLAUDE.md`](.claude/CLAUDE.md)，包含以下核心规范：

- `datetime.md`: 时间戳格式规范
- `frontmatter-operations.md`: 文档元数据操作
- `github-operations.md`: GitHub 集成规范
- `standard-patterns.md`: 通用开发模式
- `agent-coordination.md`: 多 Agent 协作规则
- `path-standards.md`: 路径规范（隐私保护）
- `strip-frontmatter.md`: 去除 Frontmatter
- `test-execution.md`: 测试执行规范
- `branch-operations.md`: 分支操作
- `worktree-operations.md`: Worktree 操作
- `use-ast-grep.md`: AST-Grep 集成协议

## Current Focus

当前重点：**P0 已完成（契约 1.0 定稿）→ M0 技术验证 spike → P1 core 单目管线产品化**
- M0（P1 前置门槛）：RK3588 NPU 基准、Qt6 嵌入式构建链、Flutter 240fps 真机采集、双目 120fps 双轨——任一不通过则启动降级预案（见 roadmap）；**物料清单与搭建步骤：`docs/m0-setup.md`**
- P1 目标：batana-runtime v0.1（TFLite 唯一后端 + 稳定 C API）+ batana-app(Flutter) 骨架，macOS+Android 走通 standard-vision 全链路

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
