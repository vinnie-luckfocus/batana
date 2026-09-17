# batana-core — 模型系统核心

> 仓库：`vinnie-luckfocus/batana-core` · 状态：planning

## 定位

整个生态的模型与算法中枢：棒球打击动作的**捕捉、追踪、分析、评价**全部在此定义与实现。对下屏蔽模型框架差异（TFLite/CoreML/ONNX/NPU），对上以能力注册表与统一 schema 服务 gui/pi/web。

## 功能清单

- **管线（pipelines）**：按模态分级的分析管线（standard-vision / standard-imu / pro-fusion / pro-stereo / max），共享底层算子
- **算子库（operators）**：姿态检测、IMU 滤波（Mahony/Kalman）、时序对齐、阶段分割、运动链分析、评分引擎（规则 → ML）
- **推理运行时（batana-runtime）**：C++17，跨平台（iOS/Android/macOS/Linux-arm64），FFI 暴露给 Flutter；模型后端可插拔
- **训练与研究（Python）**：数据集管理、训练、评估、模型导出（`.onnx`/`.tflite`）、模型注册表 `models/registry.yaml`
- **数据契约**：session-schema（一次挥棒会话的完整结构化定义）+ capabilities 注册表

## 边界

- ✅ 做：模型、算法、schema、能力注册表、推理运行时、训练流水线
- ❌ 不做：任何 UI；任何硬件驱动（摄像头/IMU 数据源以接口注入）；云端存储与服务端逻辑
- 数据源抽象：`FrameSource`（mono/stereo 帧流）与 `ImuSource`（带时间戳的 6 轴流）由调用方实现

## 技术栈与结构

- Python 3.11+ / PyTorch（训练）· C++17 / CMake（runtime）· TFLite、CoreML、ONNX Runtime（后端）
```
batana-core/
├── runtime/            # C++ 推理运行时 + FFI 绑定
│   ├── include/        #   公共头文件（capabilities.h、sources.h）
│   ├── backends/       #   tflite / coreml / onnx / rknn
│   └── bindings/       #   flutter FFI、python pybind
├── pipelines/          # 分级管线（每个档位一个目录）
├── operators/          # 共享算子
├── training/           # Python 训练/评估/导出
├── models/registry.yaml# 模型工件注册表
└── docs/contracts/     # session-schema.md、capabilities.md
```

## 对外契约

- `session-schema`（本仓定义，web/gui/pi 消费）
- `capabilities`（本仓定义，gui/web 消费）
- FFI API：`batana_runtime_create(config) → session_analyze(input) → SessionResult`

## 里程碑映射

P1：v0.1（standard-vision）→ P2：v0.2（IMU + 融合）→ P3：v0.3（双目 max）→ P5：coach_advice 模型化
