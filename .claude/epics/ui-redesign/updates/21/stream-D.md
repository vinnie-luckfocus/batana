---
stream: D
issue: "21"
title: "录制主界面"
status: completed
started: 2026-03-14T09:15:14Z
completed: 2026-03-14T09:15:14Z
---

## 完成内容

### 创建文件

1. **lib/screens/record/record_screen.dart**
   - `RecordScreen` - 主界面组件，使用 ChangeNotifierProvider 管理状态
   - `_RecordScreenContent` - 内容组件，监听状态变化
   - `_NeumorphicIconButton` - Neumorphic 风格图标按钮

### 界面结构

```
Stack(
  children: [
    CameraPreviewWidget,      // 全屏相机预览
    _buildTopBar,             // 顶部状态栏
    RecordingControls,        // 底部录制控制
    _buildHint,               // 底部提示文字
  ],
)
```

### 顶部栏组件

- **返回按钮**（左侧）：Neumorphic 风格圆形按钮，返回上一页
- **录制时长**（中间）："00:05" 格式，带红色录制指示器
- **网格开关**（右侧）：切换网格显示/隐藏

### 底部提示

- 文字："保持设备稳定，录制 5-10 秒"
- 白色文字，半透明黑色背景
- 圆角矩形（radius: 24）

### 集成

- 更新 `lib/app.dart`：添加 `/record` 路由
- 录制完成后自动跳转到 `/analysis`

### 技术特性

- 全屏相机预览，无黑边
- 支持横竖屏切换
- Neumorphic 风格按钮（阴影效果）
- 触觉反馈（HapticFeedback）
- 状态自动监听与跳转
