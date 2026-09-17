# batana-web — Web 管理平台

> 仓库：`vinnie-luckfocus/batana-web` · 状态：planning

## 定位

云端集成式管理平台：**数据统计、趋势展示、会话管理**；后期演进为支持**多身份、多用户**（球员/教练/机构）的数据仓库。

## 功能清单

- v1（P4）：账号体系（单用户多设备）、会话/指标云存储、个人仪表盘、训练趋势图（按周/月/季）、设备管理
- v2（P5）：多身份角色模型（球员/教练/机构）、数据权限隔离、数仓分层（明细层/汇总层）、开放分析接口、周期报告

## 边界

- ✅ 做：数据存储与统计、可视化、账号与权限（OIDC PKCE + JWT）、sync-api 定义、报表、**模型工件与固件工件的托管分发**（manifest + 对象存储）、视频对象存储
- ❌ 不做：实时推理（如需云端重分析，调用 batana-core Python 侧，作为异步任务）；客户端 UI；硬件管理细节（只存设备元数据）

## 技术栈与结构

- Next.js（App Router）+ TypeScript · Postgres（Neon）· **Cloudflare R2（视频与模型/固件工件，预签名 URL 直传）** · 部署 Vercel · 图表：Recharts/ECharts
- 认证：sync-api 契约定义与实现无关的 OIDC Authorization Code + PKCE + JWT（Qt 原生客户端经系统浏览器回调）；服务端实现 Auth.js 自建或 Clerk 皆可替换，不写入契约
```
batana-web/
├── app/              # Next.js 路由（dashboard / sessions / trends / devices）
├── lib/db/           # schema 与迁移（对齐 session-schema）
├── lib/sync/         # sync-api 服务端实现
├── components/       # 图表与仪表盘组件
└── docs/contracts/   # sync-api.md（本仓定义）
```

## 对外契约

- 定义：**sync-api**（gui/pi → web 的会话上传、视频带外上传、设备注册、配置下发、模型/固件工件分发）
- 消费：session-schema（存储模型与其对齐，schema 升版时迁移）

## 里程碑映射

P4：v0.1（单用户：统计 + 趋势 + 同步 + 工件分发）；P5+：v0.2（多租户数仓 + 教练模式，stretch）
