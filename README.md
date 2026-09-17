<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/vinnie-luckfocus/batana">
    <img src="assets/logo.png" alt="Logo" width="200" height="200">
  </a>

  <h3 align="center">Batana</h3>

  <p align="center">
    棒球打击动作捕捉 · 追踪 · 分析 · 评价模型系统
    <br />
    <b>本仓库是整个 Batana 生态的司令塔</b>
    <br />
    <a href="https://github.com/vinnie-luckfocus/batana/issues">报告问题</a>
    ·
    <a href="https://github.com/vinnie-luckfocus/batana/issues">请求功能</a>
  </p>
</div>

## 关于本仓库

本仓库是 Batana 生态的**司令塔（meta 仓库）**，统一管理：

- 产品功能定义与总体架构：[docs/architecture.md](docs/architecture.md)
- 模型能力分级（max / pro / standard）：[docs/model-tiers.md](docs/model-tiers.md)
- 生态路线图：[docs/roadmap.md](docs/roadmap.md)
- 软硬件版本与兼容矩阵：[repos.yaml](repos.yaml) · [docs/versioning.md](docs/versioning.md)
- 项目进度与素材资料：`.claude/`（CCPM 体系）· `docs/assets/`
- 各子仓库以 git submodule 挂载于 `projects/`，锁定到经兼容验证的版本

本仓库**不含产品代码**。旧 Flutter MVP 方案已于 2026-09-17 放弃，代码留存于 tag `archive/flutter-mvp` 仅作参考。

## 生态仓库

| 仓库 | 职责 | 技术栈 | 状态 |
|---|---|---|---|
| [batana-core](https://github.com/vinnie-luckfocus/batana-core) | 模型系统核心：管线 / 算子 / 推理运行时 / 训练 | Python + C++17 | planning |
| [batana-app](https://github.com/vinnie-luckfocus/batana-app) | 跨平台移动/桌面应用：iOS / Android / macOS / Windows | Flutter | planning |
| [batana-gui](https://github.com/vinnie-luckfocus/batana-gui) | 嵌入式 GUI：batana-pi 显示屏本地界面 | Qt6（C++/QML） | planning |
| [batana-pi](https://github.com/vinnie-luckfocus/batana-pi) | 双目边缘计算设备（双目相机 + 边缘盒 + 显示屏） | Linux (RK3588) / C++ / Python | planning |
| [batana-cap](https://github.com/vinnie-luckfocus/batana-cap) | 棒尾 IMU 传感器（陀螺仪/加速度计 + 圆屏） | Zephyr RTOS / C | planning |
| [batana-web](https://github.com/vinnie-luckfocus/batana-web) | Web 管理平台：数据统计 / 趋势 / 多用户数仓 | Next.js / Postgres | planning |

各模块功能与边界详见 [docs/modules/](docs/modules/)。

## 模型能力分级

外设组合决定模型能力档位，运行时自动选择最高可用档位：

| 档位 | 输入 | 设备组合 |
|---|---|---|
| **max** | 双目视频 + IMU | batana-pi + batana-cap |
| **pro** | 单目 + IMU，或仅双目 | 手机 + batana-cap，或仅 batana-pi |
| **standard** | 仅单目，或仅 IMU | 仅手机，或仅 batana-cap |

完整能力矩阵见 [docs/model-tiers.md](docs/model-tiers.md)。

## 快速开始

```sh
# 克隆司令塔及全部子仓库
git clone --recurse-submodules https://github.com/vinnie-luckfocus/batana.git

# 已克隆则初始化子模块
git submodule update --init --recursive

# 更新全部子模块到各自 main 最新
git submodule update --remote --merge
```

## 路线图

- **P0 生态重组**（2026-09）：仓库拆分、契约 v1-draft、司令塔转型 —— 进行中
- **P1 core 单目管线**（2026 Q4）：standard-vision，batana-runtime v0.1 + batana-app(Flutter) 骨架
- **P2 cap 原型与 IMU 融合**（2027 Q1）：standard-imu / pro-fusion
- **P3 pi 原型与双目 max**（2027 Q2）：pro-stereo / max
- **P4 web 平台 v1**（2027 Q3）：数据统计与趋势、云同步
- **P5 多租户数仓与教练模式**（2027 Q4）

详见 [docs/roadmap.md](docs/roadmap.md)。

## 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 了解详情。
