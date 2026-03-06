import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../../capture/camera_preview.dart';
import '../../capture/video_recorder.dart';
import '../../capture/quality_gate.dart';
import '../../storage/storage.dart';
import '../widgets/recording_guide_overlay.dart';

/// 录制页面 - 应用首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // 摄像头管理
  final CameraManager _cameraManager = CameraManager();

  // 视频录制器
  final VideoRecorder _videoRecorder = VideoRecorder();

  // 质量门控
  final QualityGate _qualityGate = QualityGate();

  // 数据库管理器
  final DatabaseManager _dbManager = DatabaseManager();

  // 引导控制器
  final RecordingGuideController _guideController = RecordingGuideController();

  // 状态
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _errorMessage;

  // 定时器
  Timer? _recordingTimer;
  Timer? _qualityCheckTimer;

  // 录制进度
  double _recordingProgress = 0.0;
  int _recordingDurationMs = 12000; // 12 秒

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _qualityCheckTimer?.cancel();
    _cameraManager.dispose();
    _videoRecorder.dispose();
    _qualityGate.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      // 应用进入后台，停止录制
      if (_isRecording) {
        _stopRecording();
      }
    }
  }

  /// 初始化摄像头
  Future<void> _initializeCamera() async {
    try {
      await _cameraManager.initialize();

      if (_cameraManager.controller != null) {
        await _videoRecorder.initialize(_cameraManager.controller!);

        // 设置质量门控的摄像头参数
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _qualityGate.setCamera(cameras.first);
        }

        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });

        // 开始质量检测
        _startQualityCheck();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '摄像头初始化失败: $e';
      });
    }
  }

  /// 获取可用摄像头列表
  List<CameraDescription> get _cameras => [];

  /// 开始质量检测
  void _startQualityCheck() {
    _qualityCheckTimer?.cancel();
    _qualityCheckTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _checkQuality(),
    );
  }

  /// 质量检测
  Future<void> _checkQuality() async {
    if (!_isInitialized || _cameraManager.controller == null) return;

    try {
      final controller = _cameraManager.controller!;
      if (!controller.value.isInitialized) return;

      // 注意：实际项目中这里会获取图像并运行 MediaPipe Pose 检测
      // 简化版本中，我们模拟一些状态
      // 实际实现需要：
      // 1. 获取 cameraImage
      // 2. 运行 Pose 检测
      // 3. 调用 qualityGate.checkFrame()

      // 模拟状态更新（实际项目中由真实检测结果替换）
      // await _qualityGate.checkFrame(cameraImage, poses: detectedPoses);
    } catch (e) {
      // 忽略质量检测错误
    }
  }

  /// 切换摄像头
  Future<void> _switchCamera() async {
    if (!_cameraManager.hasMultipleCameras) return;

    try {
      await _cameraManager.switchCamera();
      if (_cameraManager.controller != null) {
        await _videoRecorder.initialize(_cameraManager.controller!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换摄像头失败: $e')),
      );
    }
  }

  /// 切换录制状态
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  /// 开始录制
  Future<void> _startRecording() async {
    if (!_isInitialized || _videoRecorder.state != RecordingState.idle) {
      return;
    }

    try {
      await _videoRecorder.startRecording();

      setState(() {
        _isRecording = true;
        _recordingProgress = 0.0;
      });

      // 隐藏引导层
      _guideController.hide();

      // 启动录制定时器
      _recordingTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _updateRecordingProgress(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('开始录制失败: $e')),
      );
    }
  }

  /// 更新录制进度
  void _updateRecordingProgress() {
    if (!_isRecording) return;

    final duration = _videoRecorder.recordingDurationMs;
    final progress = duration / _recordingDurationMs;

    setState(() {
      _recordingProgress = progress;
    });

    // 自动停止
    if (_videoRecorder.shouldStopRecording()) {
      _stopRecording();
    }
  }

  /// 停止录制
  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _qualityCheckTimer?.cancel();

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      final result = await _videoRecorder.stopRecording();

      if (result != null) {
        // 录制完成，进入分析
        _showAnalysisDialog(result.videoPath);
      } else {
        setState(() {
          _isProcessing = false;
        });
        _guideController.show();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _guideController.show();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('录制失败: $e')),
      );
    }
  }

  /// 显示分析对话框
  void _showAnalysisDialog(String videoPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('分析中...'),
          ],
        ),
      ),
    );

    // 模拟分析完成
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      // 创建分析记录
      final record = AnalysisRecord(
        createdAt: DateTime.now(),
        score: 85,
        velocity: 18.5,
        angle: 45.0,
        coordination: 82.0,
        suggestions: ['保持挥杆速度一致性', '注意转体发力'],
      );

      // 保存到数据库
      try {
        await _dbManager.initDatabase();
        await _dbManager.saveRecord(record);
      } catch (e) {
        // 保存失败不影响结果展示
        debugPrint('保存记录失败: $e');
      }

      if (!mounted) return;

      Navigator.of(context).pop(); // 关闭对话框
      context.pushReplacement('/result', extra: {
        'score': 85,
        'velocity': 18.5,
        'angle': 45.0,
        'coordination': 82.0,
        'suggestions': ['保持挥杆速度一致性', '注意转体发力'],
        'feedback': '挥棒动作流畅，击球力度适中。建议保持挥杆速度一致性。',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Batana'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
            tooltip: '历史记录',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // 错误状态
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    // 初始化中
    if (!_isInitialized) {
      return _buildLoadingView();
    }

    // 处理中
    if (_isProcessing) {
      return _buildProcessingView();
    }

    // 正常预览
    return _buildPreviewView();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? '发生错误',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            '正在初始化摄像头...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            '处理中...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 摄像头预览
        Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CameraPreview(
              controller: _cameraManager.controller,
              onSwitchCamera: _switchCamera,
              showSwitchButton: !_isRecording && _cameraManager.hasMultipleCameras,
            ),
          ),
        ),

        // 录制引导覆盖层（未录制时显示）
        if (!_isRecording)
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _guideController,
              builder: (context, _) => RecordingGuideOverlay(
                visible: _guideController.visible,
                lightingOk: _guideController.lightingOk,
                humanDetected: _guideController.humanDetected,
                isStable: _guideController.isStable,
                angleOk: _guideController.angleOk,
              ),
            ),
          ),

        // 录制状态指示
        if (_isRecording)
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: _buildRecordingIndicator(),
          ),

        // 控制按钮
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: _buildControls(),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return Column(
      children: [
        // 录制红点
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '录制中',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: LinearProgressIndicator(
            value: _recordingProgress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // 录制按钮
        RecordingButton(
          isRecording: _isRecording,
          progress: _recordingProgress,
          onTap: _toggleRecording,
        ),
        const SizedBox(height: 16),
        // 提示文字
        Text(
          _isRecording
              ? '点击停止录制'
              : _guideController.isAllGood
                  ? '点击开始录制'
                  : '请先调整站位',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
