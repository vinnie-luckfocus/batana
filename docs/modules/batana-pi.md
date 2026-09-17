# batana-pi — 双目边缘计算设备

> 仓库：`vinnie-luckfocus/batana-pi` · 状态：planning

## 定位

包含**双目摄像头 + 边缘计算盒子 + 显示屏**的手持/桌面一体化设备。独立完成采集-推理-显示的本地闭环，是 pro-stereo 与 max 档的载体。

## 功能清单

- 硬件：SoC 选型矩阵（调研详见 batana-pi `docs/research/2026-09-17-soc-camera-display.md`）——**RK3588 为 max/pro 档首选**（双 ISP 491 MPix/s×2、6 TOPS NPU、64-bit 内存）；RK3576（6 TOPS 同代 NPU、ISP 16M）为 OV9281 档降本版；RK3566（0.8 TOPS、ISP 触顶）仅承担 standard 档/联调开发板
- 相机（EVT 双轨并行，挥棒场景 3D 重建精度实测 15mm@2.5m 定案）：
  - 路线 A（USB 整模组，零驱动，并行首选）：OV9281 双目 USB3 无压缩整模组、基线可调 60–120mm（Goobuy/淘宝同款，¥300–800 档，买 2–3 家样品）；接任一 USB3 口或 Type-C 全功能口直插；采购前书面确认无压缩 MONO8、真 USB3、基线范围（调研见 batana-pi `docs/research/2026-09-17-usb-stereo-module.md`）
  - 路线 B（MIPI 双模组，plan B）：VEYE RAW-MIPI-SC132M × 2（SC132GS mono，BSP 树内驱动免移植，RAW10 无损上限更高，≈¥1550–1650；清单见 `docs/research/2026-09-17-stereo-camera-bom.md`）
- 软件降级预案（plan B）：若 RK3588 侧 OV9281 驱动移植或 RKNN 模型转换受阻，EVT 切换 **RPi5 8GB** + 2× Arducam B0224（直插双 CSI、FSIN 飞线）+ HDMI 触控屏 + Hailo-8L AI HAT+（13 TOPS）；代价：双摄后无 DSI、Hailo 与 NVMe 抢唯一 PCIe、存储退守 RAM 环形缓冲，总价 ~¥2800–3500（调研见 batana-pi `docs/research/2026-09-17-rpi5-eval.md`）
- 显示：5–7" MIPI DSI 触控屏（与双摄 CSI 独立 PHY，并发无冲突，三平台均成立）
- 采集服务：双目硬同步采集、ISP 调优、**标定数据生产与失效检测**（本仓是 calibration-data 契约 owner）
- 边缘推理：部署 batana-runtime（**RKNN/NPU 后端，P3 引入**），运行 pro-stereo / max 管线；IMU 触发裁剪只分析挥棒段
- 本地 UI：嵌入式 batana-gui（**Qt6/QML，嵌入式 Linux 构建**）
- 设备服务：BLE **Central**（连接 cap）、Wi-Fi 云同步、系统镜像 OTA、功耗与散热管理

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

- 定义：**device-interfaces（含 calibration-data）**——采集服务接口与标定数据格式
- 消费：runtime-api（core）、ble-protocol（作为 Central 连接 cap）、sync-api（web）
- 产出：标定数据（core 引用进 session-schema 的 `calibration` 字段）

## 里程碑映射

P3：软件栈 v0.1 + EVT（开发板+模组先行，形态由热实测决定）；P5+：DVT 小批量
