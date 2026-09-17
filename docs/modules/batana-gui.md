# batana-gui — 跨平台 GUI

> 仓库：`vinnie-luckfocus/batana-gui` · 状态：planning（全新重写，旧 Flutter MVP 方案已放弃）

## 定位

全生态的统一交互界面，覆盖**嵌入式（batana-pi 显示屏）、Android、iOS、macOS**。负责采集编排、外设连接管理、结果可视化与云端同步触达，不含任何分析算法。

## 技术选型：Qt6（C++/QML）

- 一套代码覆盖全部目标平台：Qt6 原生支持 Android / iOS / macOS / 嵌入式 Linux（Qt for Device Creation）
- 与 batana-runtime 同为 C++，**直接链接调用**，无 FFI 边界，性能与调试链路最短
- 嵌入式端（batana-pi 显示屏）与移动端同一套 QML 界面体系，UI 复用度最高
- 旧 Flutter MVP 代码已彻底放弃（2026-09-17 决策），不再迁移、不再维护

## 功能清单

- 录制与采集编排：相机采集、录制控制、实时预览
- 外设管理：BLE 连接 batana-cap（配对、状态、OTA 触发）；局域网发现 batana-pi
- 分析调用：直接链接 batana-runtime，按能力注册表动态渲染可用功能
- 结果可视化：评分、分项指标、骨骼叠加、3D 轨迹回放（高档位）、历史记录
- 云同步：登录、会话上传、与 batana-web 对齐
- 多平台构建：Android / iOS / macOS / 嵌入式 Linux（P3 部署到 batana-pi）

## 边界

- ✅ 做：UI/UX、采集编排、BLE/网络客户端、本地缓存（SQLite）、runtime 编排
- ❌ 不做：评分/姿态算法（一律走 runtime）；服务端逻辑；cap/pi 的设备端代码

## 技术栈与结构

- Qt 6.8+（C++20 / QML）· CMake · Qt Bluetooth（BLE）· Qt Multimedia（相机）· Qt SQL（SQLite）
```
batana-gui/
├── app/              # 应用入口与平台装配（android/ios/macos/embedded）
├── qml/              # QML 界面（页面、组件、主题）
├── src/
│   ├── session/      # 会话编排：采集→runtime→结果
│   ├── devices/      # BLE(cap) 与局域网(pi) 连接管理
│   ├── runtime/      # batana-runtime 链接封装与能力注册表读取
│   └── sync/         # 云同步客户端（sync-api）
├── docs/contracts/   # 消费契约的适配说明
└── tests/
```

## 对外契约

- 消费：session-schema、capabilities、ble-protocol、sync-api
- 平台差异：相机与 BLE 能力差异收敛在 `app/` 平台装配层

## 里程碑映射

P1：v0.1 骨架 + 接入 runtime（standard-vision）→ P2：v0.2 BLE + 融合分析 → P3：嵌入式构建部署到 pi → P4：云同步
