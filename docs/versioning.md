# 版本与兼容性管理

> 版本：v0.2（2026-09-17，评审整改版）

## 1. 版本号体系

| 对象 | 规则 | 示例 |
|---|---|---|
| 软件仓库 | SemVer 2.0，`vX.Y.Z` git tag | `batana-core v0.2.1` |
| 硬件 | 阶段（EVT/DVT/PVT）+ 结构/PCB 改版号 | `cap-evt2`、`pi-dvt1` |
| 模型工件 | `model@X.Y.Z`，独立于代码版本 | `pose2d@1.3.0` |
| 跨仓契约 | 语义化版本；**草案期 `1.0-draft`，固化后 `1.0`** | `session-schema 1.0` |
| 产品组合 | 司令塔命名的整机搭配快照 | `combo-2027A` |

契约引用规则：**引用 `*-draft` 上游契约的下游契约不得标记为稳定**。契约旧版本留存于各仓 `docs/contracts/archive/`，保留期至少一个 combo 周期。

## 2. 兼容性矩阵（repos.yaml）

司令塔根目录 `repos.yaml` 是唯一权威登记处，字段：

- 每个仓库：当前版本、状态（planning/active/locked）、进度、定义/消费的契约
- 每个契约：版本、owner、consumers
- 每个 combo：各仓版本 + 契约版本 + 模型工件版本的合法搭配（模型版本只引用 core 的 `models/registry.yaml`，不复制）

发布流程：子仓发版 → 更新司令塔 `repos.yaml` → 若契约变化，同步登记并通知所有消费方。

## 3. 兼容验证（combo 准入定义）

子模块指针前进到新 combo 前，必须完成：

1. 各消费方仓库的契约测试通过（契约文件 hash 与 repos.yaml 登记版本一致——由司令塔 CI 校验）
2. combo 冒烟清单跑通：跨仓链路的最小端到端场景（如 cap→gui 连接与会话产出）
3. 结论记录在 repos.yaml 的 combo 条目（日期 + 验证人/CI 链接）

## 4. 兼容规则

- 契约**主版本不变则向后兼容**；破坏式变更必须升主版本并保留旧版本至少一个 combo 周期。
- runtime 与模型工件：runtime 声明支持的 `model@major` 范围，加载时校验；`runtime-api` 的 C API 按 ABI 主版本管理。
- BLE 协议：连接后 Central 先读协议版本特征（0x0303），主版本不兼容则拒绝并提示升级；任一方升级不得破坏已发布 combo 的连接。

## 5. 素材与文档版本

- 设计稿、渲染图按 `docs/assets/YYYY-MM-DD-<主题>/` 归档，不覆盖旧版。
- 本目录下所有 `*.md` 顶部标注版本与日期；重大修订升版本号。
