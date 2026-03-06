---
name: claude-rules
status: active
created: 2026-03-06T00:49:57Z
updated: 2026-03-06T00:49:57Z
---

# Claude Code Rules

本文档汇总了 batana 项目所有 Claude Code 开发规则。

## 目录

1. [DateTime Rule](./rules/datetime.md) - 时间戳格式规范
2. [Frontmatter Operations](./rules/frontmatter-operations.md) - 文档元数据操作
3. [GitHub Operations](./rules/github-operations.md) - GitHub 集成规范
4. [Standard Patterns](./rules/standard-patterns.md) - 通用开发模式
5. [Agent Coordination](./rules/agent-coordination.md) - 多 Agent 协作规则
6. [Path Standards](./rules/path-standards.md) - 路径规范
7. [Strip Frontmatter](./rules/strip-frontmatter.md) - 去除 Frontmatter
8. [Test Execution](./rules/test-execution.md) - 测试执行规范
9. [Branch Operations](./rules/branch-operations.md) - 分支操作
10. [Worktree Operations](./rules/worktree-operations.md) - Worktree 操作
11. [AST-Grep Integration](./rules/use-ast-grep.md) - AST-Grep 集成协议

## 快速索引

### 必读规则
- **datetime.md**: 所有时间戳必须使用 ISO 8601 格式 (UTC)
- **github-operations.md**: 所有 GitHub 操作前必须检查远程仓库是否为 CCPM 模板
- **standard-patterns.md**: 命令实现的通用模式

### 开发流程
- **branch-operations.md**: Git 分支操作规范
- **worktree-operations.md**: Git worktree 操作规范
- **agent-coordination.md**: 多 Agent 并行开发协作规则

### 代码质量
- **use-ast-grep.md**: 结构化代码搜索与重构
- **test-execution.md**: 测试执行标准

### 文档管理
- **frontmatter-operations.md**: YAML frontmatter 读写规范
- **strip-frontmatter.md**: 同步到 GitHub 前去除 frontmatter
- **path-standards.md**: 路径格式标准（保护隐私）

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
