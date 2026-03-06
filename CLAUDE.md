# CLAUDE.md

> Think carefully and implement the most concise solution that changes as little code as possible.

## 本项目所有对话、文档、代码注释均使用中文!

## Project Overview

batana 是一个棒球挥棒动作分析系统，采用分阶段交付策略：

### 产品路线图
- **MVP (Phase 1)**: Flutter + MediaPipe 单目视觉分析，本地评分与历史记录
- **V2 (Phase 2)**: 可视化增强（骨骼叠加、关键帧）、分项评分、云同步
- **V3 (Phase 3)**: IMU 蓝牙传感器集成，视觉+惯性数据融合分析
- **V4 (Phase 4)**: 教练模式、训练计划、周期报告

### 技术架构
- **客户端**: Flutter (iOS/Android 跨平台)
- **姿态识别**: MediaPipe Pose (本地推理)
- **评分引擎**: 规则引擎 (MVP) → ML 模型 (V2+)
- **存储**: SQLite (MVP) → 云同步 (V2+)
- **IMU 通信**: BLE (Bluetooth Low Energy, V3+)

### 模块划分
```
capture/     # 视频采集与预处理
analysis/    # 姿态识别与指标计算
scoring/     # 评分与建议生成
storage/     # 数据持久化
ble/         # 蓝牙通信 (V3+)
ui/          # 用户界面
```

## Project Management Workflow

本项目使用 CCPM (Claude Code Project Management) 系统管理开发流程。

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

### 开发流程
1. **需求阶段**: `/pm:prd-new` → 创建 PRD
2. **规划阶段**: `/pm:prd-parse` → 转换为 Epic
3. **拆解阶段**: `/pm:epic-decompose` → 拆解为任务
4. **同步阶段**: `/pm:epic-sync` → 同步到 GitHub
5. **开发阶段**: `/pm:issue-start` → 开始开发
6. **完成阶段**: `/pm:issue-close` → 关闭任务

## Development Guidelines

### 语言要求
- 所有对话、文档、代码注释均使用中文
- 变量名、函数名使用英文（遵循各语言规范）

### 代码规范
- 遵循现有代码模式
- 模块化设计，高内聚低耦合
- 单个文件不超过 800 行
- 函数不超过 50 行

### 测试要求
- 单元测试覆盖率 ≥ 80%
- 提交前运行测试：`flutter test` 或对应测试命令
- 关键算法必须有测试覆盖

### 性能目标
- MVP: 单次分析 ≤ 15 秒
- V2: 单次分析 ≤ 10 秒
- V3: 融合分析 ≤ 8 秒

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

当前重点：**MVP 阶段开发**
- 核心目标：验证"录制→分析→评分→展示"端到端价值
- 关键交付：视频录制、MediaPipe 集成、评分引擎、结果展示
- 成功指标：分析完成率 ≥ 85%，D7 留存率 ≥ 25%

## 审核整改要求
- 使用codex进行多维度审核
- 审核结果记录到对应文件
- 整改后到结果更新到对应文件

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