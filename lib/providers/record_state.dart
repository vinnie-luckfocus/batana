import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../capture/video_recorder.dart';

/// 录制状态枚举
enum RecordingStatus { idle, recording, paused, completed }

/// 录制状态管理类
///
/// 负责管理视频录制过程中的状态、计时器、相机控制和网格显示
class RecordState extends ChangeNotifier {
  // 内部状态
  RecordingStatus _status = RecordingStatus.idle;
  Duration _recordingDuration = Duration.zero;
  bool _showGrid = true;
  CameraController? _cameraController;
  Timer? _timer;

  // 相机相关
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitializing = false;

  // 视频录制器
  late final VideoRecorder _videoRecorder;

  // 最大录制时长（12秒）
  static const int maxDurationSeconds = 12;

  /// 构造函数
  RecordState() {
    _videoRecorder = VideoRecorder();
  }

  // ========== Getters ==========

  /// 当前录制状态
  RecordingStatus get status => _status;

  /// 是否正在录制
  bool get isRecording => _status == RecordingStatus.recording;

  /// 是否已暂停
  bool get isPaused => _status == RecordingStatus.paused;

  /// 是否空闲（未开始录制）
  bool get isIdle => _status == RecordingStatus.idle;

  /// 是否已完成
  bool get isCompleted => _status == RecordingStatus.completed;

  /// 录制时长
  Duration get recordingDuration => _recordingDuration;

  /// 格式化后的录制时长（如 "00:05"）
  String get formattedDuration {
    final minutes = _recordingDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _recordingDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 是否显示网格
  bool get showGrid => _showGrid;

  /// 相机控制器
  CameraController? get cameraController => _cameraController;

  /// 相机是否已初始化
  bool get isCameraInitialized => _cameraController?.value.isInitialized ?? false;

  /// 当前录制进度（0.0 - 1.0）
  double get recordingProgress {
    return _recordingDuration.inMilliseconds / (maxDurationSeconds * 1000);
  }

  /// 是否已达到最大录制时长
  bool get isMaxDurationReached => _recordingDuration.inSeconds >= maxDurationSeconds;

  // ========== 网格控制 ==========

  /// 切换网格显示/隐藏
  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  /// 设置网格显示状态
  void setShowGrid(bool value) {
    if (_showGrid != value) {
      _showGrid = value;
      notifyListeners();
    }
  }

  // ========== 相机控制 ==========

  /// 初始化相机
  ///
  /// 获取可用相机列表并初始化第一个相机
  Future<void> initializeCamera() async {
    if (_isInitializing || _cameraController != null) return;

    _isInitializing = true;

    try {
      // 获取可用相机列表
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('没有找到可用相机');
      }

      // 初始化第一个相机（通常是后置相机）
      await _initializeCameraController(_cameras[_currentCameraIndex]);
    } catch (e) {
      debugPrint('相机初始化失败: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// 初始化相机控制器
  Future<void> _initializeCameraController(CameraDescription camera) async {
    // 释放之前的控制器
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    // 创建新控制器：1080p, 30fps
    _cameraController = CameraController(
      camera,
      ResolutionPreset.ultraHigh, // 1080p
      fps: 30,
      enableAudio: true,
    );

    // 初始化
    await _cameraController!.initialize();

    // 初始化视频录制器
    await _videoRecorder.initialize(_cameraController!);

    notifyListeners();
  }

  /// 切换前后摄像头
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    // 切换相机索引
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    // 重新初始化相机
    await _initializeCameraController(_cameras[_currentCameraIndex]);
  }

  // ========== 录制控制 ==========

  /// 开始录制
  ///
  /// 从 idle 状态开始录制
  Future<void> startRecording() async {
    if (!isIdle) {
      throw Exception('当前状态无法开始录制: $_status');
    }

    if (!isCameraInitialized) {
      throw Exception('相机未初始化');
    }

    try {
      // 重置时长
      _recordingDuration = Duration.zero;

      // 开始视频录制
      await _videoRecorder.startRecording();

      // 更新状态
      _status = RecordingStatus.recording;

      // 启动计时器
      _startTimer();

      notifyListeners();
    } catch (e) {
      debugPrint('开始录制失败: $e');
      rethrow;
    }
  }

  /// 暂停录制
  ///
  /// 从 recording 状态暂停
  Future<void> pauseRecording() async {
    if (!isRecording) {
      throw Exception('当前状态无法暂停: $_status');
    }

    try {
      // 暂停视频录制
      await _cameraController?.pauseVideoRecording();

      // 暂停计时器
      _pauseTimer();

      // 更新状态
      _status = RecordingStatus.paused;

      notifyListeners();
    } catch (e) {
      debugPrint('暂停录制失败: $e');
      rethrow;
    }
  }

  /// 恢复录制
  ///
  /// 从 paused 状态恢复
  Future<void> resumeRecording() async {
    if (!isPaused) {
      throw Exception('当前状态无法恢复: $_status');
    }

    try {
      // 恢复视频录制
      await _cameraController?.resumeVideoRecording();

      // 恢复计时器
      _startTimer();

      // 更新状态
      _status = RecordingStatus.recording;

      notifyListeners();
    } catch (e) {
      debugPrint('恢复录制失败: $e');
      rethrow;
    }
  }

  /// 停止录制
  ///
  /// 从 recording 或 paused 状态停止，进入 completed 状态
  Future<RecordingResult?> stopRecording() async {
    if (!isRecording && !isPaused) {
      throw Exception('当前状态无法停止: $_status');
    }

    try {
      // 停止计时器
      _stopTimer();

      // 停止视频录制
      final result = await _videoRecorder.stopRecording();

      // 更新状态
      _status = RecordingStatus.completed;

      notifyListeners();

      return result;
    } catch (e) {
      debugPrint('停止录制失败: $e');
      rethrow;
    }
  }

  /// 重置录制状态
  ///
  /// 从 completed 状态回到 idle，用于重录
  void reset() {
    if (!isCompleted && !isIdle) {
      // 如果正在录制，先取消
      if (isRecording || isPaused) {
        _videoRecorder.cancelRecording();
      }
    }

    // 停止计时器
    _stopTimer();

    // 重置状态
    _status = RecordingStatus.idle;
    _recordingDuration = Duration.zero;

    notifyListeners();
  }

  // ========== 计时器管理 ==========

  /// 启动计时器
  void _startTimer() {
    _stopTimer(); // 确保之前的计时器已停止

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration += const Duration(seconds: 1);

      // 检查是否达到最大时长
      if (isMaxDurationReached) {
        _onMaxDurationReached();
      }

      notifyListeners();
    });
  }

  /// 暂停计时器
  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 达到最大时长时的处理
  void _onMaxDurationReached() {
    _stopTimer();

    // 自动停止录制
    stopRecording().catchError((e) {
      debugPrint('自动停止录制失败: $e');
    });
  }

  // ========== 生命周期 ==========

  @override
  void dispose() {
    _stopTimer();
    _videoRecorder.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}
