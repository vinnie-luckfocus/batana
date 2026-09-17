# batana-cap — 棒尾传感器

> 仓库：`vinnie-luckfocus/batana-cap` · 状态：planning

## 定位

安装在**棒球棒尾端**的传感器设备：IMU（陀螺仪 + 加速度计）高频采样，BLE 传输，**圆形屏幕**显示基本信息。是 standard-imu、pro-fusion、max 档的传感来源。

## 功能清单

- 硬件：nRF52840（BLE 5 + Cortex-M4F）、IMU（LSM6DSR 或 ICM-20948）、1.28" 圆屏 GC9A01、锂电池 + 充电管理、棒尾固定结构
- 固件（Zephyr RTOS）：≥ 200Hz 6 轴采样、片上预处理（挥棒事件检测唤醒、计数）、环形缓存
- BLE：GATT 服务（数据流、设备状态、控制命令）、固件 OTA
- 圆屏 UI：棒速、挥棒次数、电量、连接状态（LVGL）
- 标定：出厂标定 + 安装姿态自校准

## 边界

- ✅ 做：传感采样、片上轻量预处理、BLE 协议实现、圆屏基础显示、低功耗管理
- ❌ 不做：正式评分与分析（在 batana-core）；复杂图形界面；云连接（经 gui/pi 中转）

## 技术栈与结构

- Zephyr RTOS / C · LVGL（圆屏）· nRF Connect SDK · EasyEDA（硬件）
```
batana-cap/
├── hardware/        # 原理图/PCB/结构（EVT→DVT→PVT）
├── firmware/        # Zephyr 应用
│   ├── src/sensing/ #   IMU 采样与滤波
│   ├── src/ble/     #   GATT 服务
│   └── src/display/ #   圆屏 LVGL 界面
├── tools/           # 标定、产测、烧录工具
└── docs/contracts/  # ble-protocol.md（本仓定义）
```

## 对外契约

- 定义：**ble-protocol**（GATT 服务 UUID、数据帧格式、控制命令、OTA）
- 消费：session-schema 中的 IMU 序列字段（core 定义）

## 里程碑映射

P2：EVT 样机 + 固件 v0.1 + ble-protocol v1；P3：配合 max 档联调；P5：DVT
