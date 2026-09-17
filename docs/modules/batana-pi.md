# batana-pi — 双目边缘计算设备

> 仓库：`vinnie-luckfocus/batana-pi` · 状态：planning

## 定位

包含**双目摄像头 + 边缘计算盒子 + 显示屏**的手持/桌面一体化设备。独立完成采集-推理-显示的本地闭环，是 pro-stereo 与 max 档的载体。

## 功能清单

- 硬件：RK3588（或 RPi5 起步）核心板、双目全局快门相机模组、5–7" 触控显示屏、电池（手持形态）、结构件
- 采集服务：双目硬同步采集、ISP 调优、标定参数管理
- 边缘推理：部署 batana-runtime（RKNN/NPU 后端），运行 pro-stereo / max 管线
- 本地 UI：嵌入式 batana-gui（flutter-elinux）
- 设备服务：BLE 服务端（接 cap）、Wi-Fi 云同步、OTA、功耗与散热管理

## 边界

- ✅ 做：硬件设计（原理图/PCB/结构）、驱动与采集、系统镜像（Yocto/Ubuntu）、部署形态、标定工具
- ❌ 不做：分析算法（全部来自 batana-core）；GUI 应用本体（来自 batana-gui 的嵌入式构建）；云端逻辑

## 技术栈与结构

- 硬件：KiCad/EasyEDA 工程 · 系统：Buildroot/Yocto 或 Ubuntu arm64 · 服务：C++/Python（采集、标定、守护进程）
```
batana-pi/
├── hardware/        # 原理图/PCB/结构（EVT→DVT→PVT 分目录）
├── firmware/        # U-Boot/内核/设备树/镜像构建
├── services/        # capture-service（双目同步）、calibration、ota、power
├── deploy/          # runtime 打包与系统集成
└── docs/contracts/  # 与 core/gui 的接口适配说明
```

## 对外契约

- 消费：runtime（core）、ble-protocol（cap 侧服务端实现）、sync-api（web）
- 产出：标定数据格式（登记进 session-schema）

## 里程碑映射

P3：EVT 样机 + 软件栈 v0.1；P5：DVT 小批量
