# 版本与兼容性管理

> 版本：v0.1（2026-09-17）

## 1. 版本号体系

| 对象 | 规则 | 示例 |
|---|---|---|
| 软件仓库 | SemVer 2.0，`vX.Y.Z` git tag | `batana-core v0.2.1` |
| 硬件 | 阶段（EVT/DVT/PVT）+ 结构/PCB 改版号 | `cap-evt2`、`pi-dvt1` |
| 模型工件 | `model@X.Y.Z`，独立于代码版本 | `pose2d@1.3.0` |
| 跨仓契约 | 整数主版本 + 日期 | `ble-protocol v1`、`session-schema v2` |
| 产品组合 | 司令塔命名的整机搭配快照 | `combo-2027A` |

## 2. 兼容性矩阵（repos.yaml）

司令塔根目录 `repos.yaml` 是唯一权威登记处，字段：

- 每个仓库：当前版本、状态（planning/active/locked）、进度、契约版本
- 每个 combo：各仓版本 + 契约版本 + 模型工件版本的合法搭配

发布流程：子仓发版 → 更新司令塔 `repos.yaml` → 若契约变化，同步登记并 @ 所有消费方。

## 3. 兼容规则

- 契约**主版本不变则向后兼容**；破坏式变更必须升主版本并保留旧版本至少一个 combo 周期。
- runtime 与模型工件：runtime 声明支持的 `model@major` 范围，加载时校验。
- BLE 协议：cap 固件与 gui/pi 任一方升级不得破坏已发布 combo 的连接。

## 4. 素材与文档版本

- 设计稿、渲染图按 `docs/assets/YYYY-MM-DD-<主题>/` 归档，不覆盖旧版。
- 本目录下所有 `*.md` 顶部标注版本与日期；重大修订升版本号。
