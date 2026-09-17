# batana-gui — 嵌入式 GUI（batana-pi 显示屏）

> 仓库：`vinnie-luckfocus/batana-gui` · 状态：planning
>
> 2026-09-17 定位调整：原为"跨平台 GUI"，现**收窄为嵌入式 GUI**，只服务 batana-pi 显示屏；移动/桌面端由 batana-app（Flutter）承担。

## 定位

batana-pi 设备显示屏上的本地界面：采集编排、实时状态、分析结果可视化、设备设置。运行在 pi 本机（RK3588，嵌入式 Linux），与 batana-runtime 同进程直接链接。

## 技术选型：Qt6（C++/QML）

- 嵌入式 Linux（Yocto + OSS Qt6，动态链接满足 LGPL；eglfs 显示后端）
- 与 batana-runtime 同为 C++，直接链接其稳定 C API（runtime-api 契约）
- 嵌入式场景无 App Store 合规问题，Qt6 的主要风险（iOS LGPL、移动端高帧率采集）不适用于本仓

### 与 batana-app 的分工

| | batana-gui（本仓） | batana-app |
|---|---|---|
| 形态 | pi 显示屏本地界面 | 手机/平板/电脑 |
| 平台 | 嵌入式 Linux（RK3588） | iOS / Android / macOS / Windows |
| 技术栈 | Qt6 / QML / C++ | Flutter / Dart |
| runtime 接入 | C++ 直接链接 | dart:ffi 调 C API |

## 功能清单

- 采集编排：开始/停止采集、挥棒段触发显示
- 实时状态：相机/双目状态、cap 连接状态（经 pi 采集服务）、档位指示
- 结果可视化：评分、分项指标、骨骼叠加、3D 轨迹回放（max 档）
- 设备设置：配网、标定入口、OTA 状态
- 云同步触达：pi 联网时经 sync 模块上传（sync-api）

## 边界

- ✅ 做：pi 显示屏 UI/UX、采集编排界面、本地结果可视化、设备设置界面
- ❌ 不做：移动端/桌面端（归 batana-app）；评分/姿态算法（走 runtime）；BLE 协议实现（pi 采集服务）；服务端逻辑

## 技术栈与结构

- Qt 6.8+（C++20 / QML）· CMake · Yocto 集成（由 batana-pi 系统镜像打包）
```
batana-gui/
├── app/              # 嵌入式 Linux 平台装配（eglfs、输入、显示）
├── qml/              # QML 界面（嵌入式屏幕尺寸与触控）
├── src/
│   ├── session/      # 会话编排：采集→runtime→结果
│   ├── devices/      # 经 pi 服务读取 cap/相机状态
│   ├── runtime/      # batana-runtime C API 链接封装与能力注册表读取
│   └── sync/         # 云同步客户端（sync-api，pi 联网时）
├── docs/contracts/   # 消费契约的适配说明
└── tests/
```

## 对外契约

- 消费：session-schema、capabilities、runtime-api、sync-api、device-interfaces

## 里程碑映射

P3：随 batana-pi 软件栈 v0.1 落地（Yocto 集成 + 嵌入式构建）
