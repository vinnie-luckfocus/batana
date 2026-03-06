import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

/// 视频录制状态
enum RecordingState {
  idle,
  initializing,
  recording,
  processing,
  completed,
  error,
}

/// 视频录制结果
class RecordingResult {
  /// 视频文件路径
  final String videoPath;

  /// 录制时长（毫秒）
  final int durationMs;

  /// 文件大小（字节）
  final int fileSize;

  RecordingResult({
    required this.videoPath,
    required this.durationMs,
    required this.fileSize,
  });
}

/// 视频录制器
///
/// 负责视频录制功能，支持 10-15 秒自动停止
class VideoRecorder {
  CameraController? _controller;
  String? _currentVideoPath;
  DateTime? _recordingStartTime;
  RecordingState _state = RecordingState.idle;
  int _maxDurationMs = 12000; // 默认 12 秒

  /// 当前录制状态
  RecordingState get state => _state;

  /// 设置最大录制时长（毫秒）
  void setMaxDuration(int durationMs) {
    _maxDurationMs = durationMs.clamp(5000, 30000);
  }

  /// 初始化录制器
  Future<void> initialize(CameraController controller) async {
    _controller = controller;
    _state = RecordingState.idle;
  }

  /// 开始录制
  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _state = RecordingState.error;
      throw Exception('摄像头未初始化');
    }

    if (_controller!.value.isRecordingVideo) {
      throw Exception('正在录制中');
    }

    try {
      _state = RecordingState.initializing;

      // 获取临时目录
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentVideoPath = '${directory.path}/batana_$timestamp.mp4';

      // 开始录制
      await _controller!.startVideoRecording();
      _recordingStartTime = DateTime.now();
      _state = RecordingState.recording;
    } catch (e) {
      _state = RecordingState.error;
      rethrow;
    }
  }

  /// 停止录制
  Future<RecordingResult?> stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      _state = RecordingState.error;
      return null;
    }

    try {
      _state = RecordingState.processing;

      // 停止录制
      final XFile videoFile = await _controller!.stopVideoRecording();
      final durationMs = DateTime.now().difference(_recordingStartTime!).inMilliseconds;

      // 获取文件信息
      final file = File(videoFile.path);
      final fileSize = await file.length();

      // 如果路径不同，复制到目标位置
      if (_currentVideoPath != null && videoFile.path != _currentVideoPath) {
        await file.copy(_currentVideoPath!);
        await file.delete();
      }

      _state = RecordingState.completed;

      return RecordingResult(
        videoPath: _currentVideoPath ?? videoFile.path,
        durationMs: durationMs,
        fileSize: fileSize,
      );
    } catch (e) {
      _state = RecordingState.error;
      rethrow;
    }
  }

  /// 检查是否达到最大录制时长
  bool shouldStopRecording() {
    if (_recordingStartTime == null) return false;
    final elapsed = DateTime.now().difference(_recordingStartTime!).inMilliseconds;
    return elapsed >= _maxDurationMs;
  }

  /// 获取当前录制时长（毫秒）
  int get recordingDurationMs {
    if (_recordingStartTime == null) return 0;
    return DateTime.now().difference(_recordingStartTime!).inMilliseconds;
  }

  /// 取消录制
  Future<void> cancelRecording() async {
    if (_controller != null && _controller!.value.isRecordingVideo) {
      await _controller!.stopVideoRecording();
    }

    // 删除未完成的视频文件
    if (_currentVideoPath != null) {
      final file = File(_currentVideoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _state = RecordingState.idle;
    _currentVideoPath = null;
    _recordingStartTime = null;
  }

  /// 释放资源
  void dispose() {
    _controller = null;
    _state = RecordingState.idle;
  }
}

/// 录制按钮组件
class RecordingButton extends StatelessWidget {
  /// 是否正在录制
  final bool isRecording;

  /// 录制进度（0.0 - 1.0）
  final double progress;

  /// 按钮点击回调
  final VoidCallback? onTap;

  /// 按钮大小
  final double size;

  const RecordingButton({
    super.key,
    required this.isRecording,
    this.progress = 0.0,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + 16,
        height: size + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 进度圈
            if (isRecording)
              SizedBox(
                width: size + 12,
                height: size + 12,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),

            // 按钮主体
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : Theme.of(context).colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.fiber_manual_record,
                color: Colors.white,
                size: size * 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
