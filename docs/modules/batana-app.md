# batana-app — 跨平台移动/桌面应用

> 仓库：`vinnie-luckfocus/batana-app` · 状态：planning
>
> 2026-09-17 新增：承接原 batana-gui 的移动/桌面职责（iOS / Android / macOS / Windows）。注意：旧 Flutter MVP 代码已放弃，本仓全新实现，不复用旧代码。

## 定位

用户随身入口：手机/平板/电脑上的录制、外设连接、分析结果与历史、云同步。是 standard / pro-fusion 档的主要载体。

## 技术选型：Flutter

- 四个目标平台全覆盖（iOS / Android / macOS / Windows），一套 Dart 代码
- 相机高帧率采集与 BLE（flutter_blue_plus）生态成熟，旧 MVP 已验证可行性
- 经 **dart:ffi** 调 batana-runtime 稳定 C API（runtime-api 契约）
- 无 Qt6 的 iOS LGPL 合规负担

## 功能清单

- 录制与采集编排：相机采集（高帧率平台通道）、录制控制、实时预览
- 外设管理：BLE 连接 batana-cap（配对、时钟同步、OTA 触发）；局域网发现 batana-pi
- 分析调用：dart:ffi 调 batana-runtime，按能力注册表动态渲染可用功能
- 结果可视化：评分、分项指标、骨骼叠加、历史记录
- 云同步：OIDC PKCE 登录、会话上传（含视频带外上传）、模型工件更新

## 边界

- ✅ 做：UI/UX、采集编排、BLE/网络客户端、本地缓存（SQLite）、runtime 编排
- ❌ 不做：评分/姿态算法（一律走 runtime）；嵌入式界面（归 batana-gui）；服务端逻辑；cap/pi 设备端代码

## 技术栈与结构

- Flutter 3.x / Dart 3.x · dart:ffi · SQLite（sqflite / drift）
```
batana-app/
├── lib/
│   ├── capture/      # 相机采集与编排（240fps 平台通道）
│   ├── session/      # 会话编排：采集→runtime→结果
│   ├── devices/      # BLE(cap) 与局域网(pi) 连接管理
│   ├── runtime/      # dart:ffi 封装 runtime C API、能力注册表读取
│   ├── sync/         # 云同步客户端（sync-api）
│   └── ui/           # 页面与组件
├── platform/         # 平台差异适配（高帧率通道、BLE 差异）
├── docs/contracts/   # 消费契约的适配说明
└── test/
```

## 对外契约

- 消费：session-schema、capabilities、runtime-api、ble-protocol、sync-api

## 里程碑映射

P1：v0.1 骨架 + 接入 runtime（standard-vision，macOS+Android 先行）→ P2b：v0.2 BLE + 融合分析 → P4：云同步
