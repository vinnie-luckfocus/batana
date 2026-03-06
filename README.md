<!--
Hey, thanks for checking out batana.

If you have any questions or feedback, feel free to reach out!
-->

<a name="readme-top"></a>

<!--
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
-->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/vinnie-luckfocus/batana">
    <img src="assets/logo.png" alt="Logo" width="200" height="200">
  </a>

  <h3 align="center">Batana</h3>

  <p align="center">
    棒球挥棒动作分析系统
    <br />
    <a href="https://github.com/vinnie-luckfocus/batana/issues">报告问题</a>
    ·
    <a href="https://github.com/vinnie-luckfocus/batana/issues">请求功能</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>目录</summary>
  <ol>
    <li><a href="#关于项目">关于项目</a></li>
    <li><a href="#技术栈">技术栈</a></li>
    <li><a href="#入门指南">入门指南</a></li>
    <li><a href="#功能特点">功能特点</a></li>
    <li><a href="#路线图">路线图</a></li>
    <li><a href="#贡献指南">贡献指南</a></li>
    <li><a href="#许可证">许可证</a></li>
    <li><a href="#联系方式">联系方式</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## 关于项目

Batana 是一款棒球挥棒动作分析系统，采用计算机视觉技术自动分析用户的挥棒动作，提供量化评分和改进建议。

### 产品阶段

- **MVP (Phase 1)**: Flutter + MediaPipe 单目视觉分析，本地评分与历史记录
- **V2 (Phase 2)**: 可视化增强（骨骼叠加、关键帧）、分项评分、云同步
- **V3 (Phase 3)**: IMU 蓝牙传感器集成，视觉+惯性数据融合分析
- **V4 (Phase 4)**: 教练模式、训练计划、周期报告

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- TECH STACK -->

## 技术栈

- **客户端**: Flutter (iOS/Android 跨平台)
- **姿态识别**: MediaPipe Pose (本地推理)
- **评分引擎**: 规则引擎 (MVP) → ML 模型 (V2+)
- **存储**: SQLite (MVP) → 云同步 (V2+)
- **IMU 通信**: BLE (Bluetooth Low Energy, V3+)

### 主要依赖

- `flutter` - UI 框架
- `camera` - 摄像头采集
- `mediapipe_pose` - 姿态识别
- `sqflite` - 本地数据库
- `go_router` - 路由管理
- `path_provider` - 文件路径

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- GETTING STARTED -->

## 入门指南

### 前置条件

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Xcode (iOS 开发)
- Android Studio (Android 开发)

### 安装步骤

1. 克隆仓库
   ```sh
   git clone https://github.com/vinnie-luckfocus/batana.git
   ```

2. 进入项目目录
   ```sh
   cd batana
   ```

3. 安装依赖
   ```sh
   flutter pub get
   ```

4. 运行应用
   ```sh
   flutter run
   ```

### 构建

#### iOS
```sh
flutter build ios
```

#### Android
```sh
flutter build apk
```

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- FEATURES -->

## 功能特点

### MVP 阶段功能

- 📹 **视频录制**: 自动录制 12 秒挥棒动作
- 🎯 **姿态检测**: 实时 33 点身体关键点检测
- 📊 **阶段分割**: 自动识别准备、加速、击球、收尾四阶段
- ⭐ **评分系统**: 速度、角度、协调性多维度评分
- 💡 **改进建议**: 基于规则的个性化改进建议
- 📝 **历史记录**: 本地 SQLite 存储分析历史

### 核心指标

- **速度评分**: 10-30 m/s 范围评估
- **角度评分**: 20-70° 范围评估
- **协调性**: 髋肩时序 + 重心转移流畅度

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- ROADMAP -->

## 路线图

- [ ] **Phase 1 (MVP)**: 完成核心分析功能
  - [x] 视频录制与摄像头管理
  - [x] MediaPipe 姿态识别
  - [x] 挥棒阶段检测算法
  - [x] 核心指标计算
  - [x] 规则评分引擎
  - [x] 结果展示与历史记录

- [ ] **Phase 2 (V2)**: 可视化增强
  - [ ] 骨骼叠加实时显示
  - [ ] 关键帧提取与慢放
  - [ ] 分项评分细化
  - [ ] 云端数据同步

- [ ] **Phase 3 (V3)**: 传感器融合
  - [ ] IMU 蓝牙传感器集成
  - [ ] 视觉+惯性数据融合
  - [ ] 更精确的动作分析

- [ ] **Phase 4 (V4)**: 智能化训练
  - [ ] 教练模式
  - [ ] 训练计划制定
  - [ ] 周期报告生成
  - [ ] AI 动作指导

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- CONTRIBUTING -->

## 贡献指南

欢迎贡献代码！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing-feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- LICENSE -->

## 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 了解详情。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- CONTACT -->

## 联系方式

- 项目主页: https://github.com/vinnie-luckfocus/batana
- 问题反馈: https://github.com/vinnie-luckfocus/batana/issues

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## 鸣谢

- [MediaPipe](https://google.github.io/mediapipe/) - 姿态识别
- [Flutter](https://flutter.dev/) - 跨平台开发框架
- [Best-README-Template](https://github.com/othneildrew/Best-README-Template) - README 模板

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>
