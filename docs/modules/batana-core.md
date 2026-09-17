# batana-core — 模型系统核心

> 仓库：`vinnie-luckfocus/batana-core` · 状态：planning

## 定位

整个生态的模型与算法中枢：棒球打击动作的**捕捉、追踪、分析、评价**全部在此定义与实现。对下屏蔽模型框架差异（TFLite/CoreML/ONNX/NPU），对上以能力注册表与统一 schema 服务 gui/pi/web。

## 功能清单

- **管线（pipelines）**：按模态分级的分析管线（standard-vision / standard-imu / pro-fusion / pro-stereo / max），共享底层算子
- **算子库（operators）**：姿态检测、IMU 滤波（Mahony/Kalman）、时序对齐（基于 `clock_anchor`）、阶段分割、运动链分析、评分引擎（规则 → ML）
- **推理运行时（batana-runtime）**：C++17，跨平台（iOS/Android/macOS/Linux-arm64/RK3588）；**对外只暴露稳定 C API（runtime-api 契约）**，Qt6 gui 直接链接，另提供 Python pybind 绑定供训练侧复用
- **训练与研究（Python）**：数据集管理、训练、评估、模型导出、模型注册表 `models/registry.yaml`
- **数据契约**：session-schema（一次挥棒会话的完整结构化定义）+ capabilities 注册表

## 边界

- ✅ 做：模型、算法、schema、能力注册表、推理运行时、训练流水线
- ❌ 不做：任何 UI；任何硬件驱动（摄像头/IMU 数据源以接口注入）；云端存储与服务端逻辑
- 数据源抽象：`FrameSource`（mono/stereo 帧流）与 `ImuSource`（带时间戳的 6 轴流）由调用方实现

## 技术栈与结构

- Python 3.11+ / PyTorch（训练）· C++17 / CMake（runtime）
- **推理后端策略（评审整改）**：唯一跨平台后端 **TFLite + delegates**（Android GPU/NNAPI、iOS/macOS CoreML/Metal delegate）；**RKNN 推迟到 P3**（pi 落地时引入，仅服务双目管线特定模型）；不做独立 CoreML / ONNX Runtime 后端，ONNX 仅作训练侧中间格式
- **MediaPipe 的角色**：仅作 (a) 33 点关键点拓扑规范来源（session-schema 已锁定）与 (b) P1 期间 ground-truth 对照工具；生产管线只跑自训练/导出的 TFLite 模型。注意 MediaPipe Solutions 已进入维护期，不作为长期运行时依赖
- **导出与验证**：PyTorch → TFLite 转换链（ai-edge-torch 优先，ONNX→onnx2tf 兜底；时序模型选型须以目标后端算子覆盖为约束）；每个导出模型必须附数值一致性测试（PyTorch vs TFLite 输出误差阈值）与 INT8 量化校准集

```
batana-core/
├── runtime/            # C++ 推理运行时
│   ├── include/        #   公共头文件（batana_runtime.h = runtime-api 契约、capabilities.h、sources.h）
│   ├── backends/       #   tflite（唯一跨平台）；rknn 于 P3 加入
│   └── bindings/       #   python pybind（gui/pi 直接链接 C API，不走 FFI 绑定层）
├── pipelines/          # 分级管线（每个档位一个目录）
├── operators/          # 共享算子
├── training/           # Python 训练/评估/导出
├── models/registry.yaml# 模型工件注册表（模型版本的唯一登记源）
└── docs/contracts/     # session-schema.md、capabilities.md
```

## 对外契约

- 定义：session-schema、capabilities、**runtime-api**（`batana_runtime.h`，ABI 主版本管理）
- 消费：device-interfaces / calibration-data（batana-pi 定义）
- runtime-api 形态：`batana_runtime_create(config) → session_analyze(input) → SessionResult`

## 里程碑映射

P1：v0.1（standard-vision）→ P2：v0.2（IMU + 融合）→ P3：v0.3（双目 max）→ P5：coach_advice 模型化
