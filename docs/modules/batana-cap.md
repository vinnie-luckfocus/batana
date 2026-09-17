# batana-cap — 棒尾传感器

> 仓库：`vinnie-luckfocus/batana-cap` · 状态：planning

## 定位

安装在**棒球棒尾端**的传感器设备：IMU（陀螺仪 + 加速度计）高频采样，BLE 传输，**圆形屏幕**显示基本信息。是 standard-imu、pro-fusion、max 档的传感来源。

## 功能清单

- 硬件：nRF52840（BLE 5 + Cortex-M4F）、IMU **LSM6DSO32X（±32g / ±4000dps）**、1.28" 圆屏 GC9A01、锂电池 + 充电管理、棒尾固定结构
- 固件（Zephyr RTOS）：常态 200Hz 6 轴采样，**挥棒事件触发 800Hz 爆发模式**（捕捉击球 1–2ms 瞬态）、片上预处理（事件检测唤醒、计数）、环形缓存 ≥ 2–4s（丢帧补发）
- BLE：GATT 服务（数据流、设备状态、控制命令、**时钟同步 0x05**、协议版本协商）；**LE Secure Connections + bonding**；**单连接 Peripheral**（同一时刻仅一个 Central，max 档时手机经 pi 间接取数）；固件 OTA（Nordic DFU）
- 圆屏 UI：片上粗估棒速、挥棒次数、电量、连接状态（LVGL）——仅显示片上预处理值，正式评分来自 runtime
- 标定：出厂标定 + 安装姿态自校准

> 选型说明（评审整改）：原候选 LSM6DSR/ICM-20948 量程不足——挥棒峰值角速度约 2200–2500dps，±2000dps 必然饱和；棒尾向心加速度峰值约 24g 超 ±16g；磁力计在金属球棒上无价值。故冻结 LSM6DSO32X，DVT 再评估是否加高 g 加速度计。

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
