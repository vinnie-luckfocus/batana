import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// 质量门控检测项
enum QualityCheckItem {
  lighting,     // 光照检测
  humanBody,    // 人体检测
  stability,    // 稳定性检测
  angle,        // 角度检测
}

/// 质量检测结果
class QualityCheckResult {
  /// 检测项
  final QualityCheckItem item;

  /// 是否通过
  final bool passed;

  /// 检测分数（0-100）
  final int score;

  /// 问题描述
  final String message;

  const QualityCheckResult({
    required this.item,
    required this.passed,
    required this.score,
    required this.message,
  });
}

/// 质量门控状态
class QualityGateStatus {
  /// 各项检测结果
  final List<QualityCheckResult> checks;

  /// 是否全部通过
  final bool allPassed;

  /// 综合分数
  final int overallScore;

  const QualityGateStatus({
    required this.checks,
    required this.allPassed,
    required this.overallScore,
  });

  /// 创建空状态
  factory QualityGateStatus.empty() {
    return const QualityGateStatus(
      checks: [],
      allPassed: false,
      overallScore: 0,
    );
  }
}

/// 质量门控检测器
///
/// 负责检测光照、人体、稳定性、角度等质量指标
class QualityGate {
  // 检测阈值配置
  static const double _lightingThreshold = 50.0;  // 亮度均值阈值
  static const double _stabilityThreshold = 100.0;  // 稳定性阈值（位移方差）
  static const double _angleMin = 30.0;  // 最小角度（度）
  static const double _angleMax = 60.0;  // 最大角度（度）

  // 关键点历史位置（用于稳定性检测）
  final List<Map<int, Offset>> _poseHistory = [];
  static const int _historyMaxLength = 10;

  // 摄像头参数
  CameraDescription? _camera;

  /// 设置摄像头参数
  void setCamera(CameraDescription camera) {
    _camera = camera;
  }

  /// 检测单帧图像质量
  ///
  /// [image] - 摄像头图像
  /// [poses] - MediaPipe 检测到的姿态关键点（如果可用）
  Future<QualityGateStatus> checkFrame(
    CameraImage image, {
    List<Map<int, Offset>>? poses,
  }) async {
    final checks = <QualityCheckResult>[];

    // 1. 光照检测
    checks.add(await _checkLighting(image));

    // 2. 人体检测
    checks.add(_checkHumanBody(poses));

    // 3. 稳定性检测
    checks.add(_checkStability(poses));

    // 4. 角度检测
    checks.add(_checkAngle(poses));

    // 计算综合分数
    final overallScore = checks.isEmpty
        ? 0
        : checks.map((c) => c.score).reduce((a, b) => a + b) ~/ checks.length;

    final allPassed = checks.every((c) => c.passed);

    return QualityGateStatus(
      checks: checks,
      allPassed: allPassed,
      overallScore: overallScore,
    );
  }

  /// 光照检测：分析图像亮度均值
  Future<QualityCheckResult> _checkLighting(CameraImage image) async {
    try {
      // 将图像转换为灰度并计算亮度均值
      double brightness = 0;

      if (image.format.group == ImageFormatGroup.yuv420) {
        // YUV 格式：使用 Y 通道作为亮度
        final yPlane = image.planes[0];
        final yBytes = yPlane.bytes;

        int sum = 0;
        for (int i = 0; i < yBytes.length; i += 4) {
          sum += yBytes[i];
        }
        brightness = sum / (yBytes.length / 4);
      } else {
        // 其他格式：简单估算
        brightness = 128; // 默认中等亮度
      }

      final passed = brightness > _lightingThreshold;
      final score = (brightness / 255 * 100).round().clamp(0, 100);

      String message;
      if (passed) {
        message = '光照充足';
      } else if (brightness < 30) {
        message = '光线不足，请到更亮的地方';
      } else {
        message = '光线偏暗，建议改善照明';
      }

      return QualityCheckResult(
        item: QualityCheckItem.lighting,
        passed: passed,
        score: score,
        message: message,
      );
    } catch (e) {
      return QualityCheckResult(
        item: QualityCheckItem.lighting,
        passed: false,
        score: 0,
        message: '光照检测失败',
      );
    }
  }

  /// 人体检测：检查是否检测到全身
  QualityCheckResult _checkHumanBody(List<Map<int, Offset>>? poses) {
    if (poses == null || poses.isEmpty) {
      return const QualityCheckResult(
        item: QualityCheckItem.humanBody,
        passed: false,
        score: 0,
        message: '未检测到人物，请站在画面中',
      );
    }

    // 检查是否包含关键身体部位
    final pose = poses.first;
    final hasKeyParts = pose.containsKey(0) &&   // 鼻子
        pose.containsKey(11) && // 左肩
        pose.containsKey(12) && // 右肩
        pose.containsKey(23) && // 左髋
        pose.containsKey(24);   // 右髋

    if (!hasKeyParts) {
      return const QualityCheckResult(
        item: QualityCheckItem.humanBody,
        passed: false,
        score: 30,
        message: '请确保全身出现在画面中',
      );
    }

    // 计算人体在画面中的占比
    final bounds = _calculatePoseBounds(pose);
    final coverage = _calculateCoverage(bounds);

    final passed = coverage > 0.3; // 至少占画面 30%
    final score = (coverage * 100).round().clamp(0, 100);

    String message;
    if (passed) {
      message = '人物位置合适';
    } else if (coverage < 0.15) {
      message = '请站近一点';
    } else {
      message = '请退后一些';
    }

    return QualityCheckResult(
      item: QualityCheckItem.humanBody,
      passed: passed,
      score: score,
      message: message,
    );
  }

  /// 稳定性检测：检查关键点位移方差
  QualityCheckResult _checkStability(List<Map<int, Offset>>? poses) {
    if (poses == null || poses.isEmpty) {
      return const QualityCheckResult(
        item: QualityCheckItem.stability,
        passed: false,
        score: 0,
        message: '无法检测稳定性',
      );
    }

    // 添加到历史记录
    _poseHistory.add(poses.first);
    if (_poseHistory.length > _historyMaxLength) {
      _poseHistory.removeAt(0);
    }

    // 需要足够的历史数据
    if (_poseHistory.length < 3) {
      return QualityCheckResult(
        item: QualityCheckItem.stability,
        passed: false,
        score: 50,
        message: '检测稳定性中...',
      );
    }

    // 计算关键点位移方差
    final displacements = <double>[];
    for (int i = 1; i < _poseHistory.length; i++) {
      final prev = _poseHistory[i - 1];
      final curr = _poseHistory[i];

      for (final key in prev.keys) {
        if (curr.containsKey(key)) {
          final dx = curr[key]!.dx - prev[key]!.dx;
          final dy = curr[key]!.dy - prev[key]!.dy;
          displacements.add(dx * dx + dy * dy);
        }
      }
    }

    if (displacements.isEmpty) {
      return const QualityCheckResult(
        item: QualityCheckItem.stability,
        passed: false,
        score: 50,
        message: '稳定性检测中...',
      );
    }

    // 计算平均位移
    final avgDisplacement = displacements.reduce((a, b) => a + b) / displacements.length;
    final variance = avgDisplacement;

    final passed = variance < _stabilityThreshold;
    final score = (100 - (variance / _stabilityThreshold * 100)).round().clamp(0, 100);

    String message;
    if (passed) {
      message = '画面稳定';
    } else if (variance > _stabilityThreshold * 2) {
      message = '请保持身体稳定';
    } else {
      message = '轻微晃动，请站稳';
    }

    return QualityCheckResult(
      item: QualityCheckItem.stability,
      passed: passed,
      score: score,
      message: message,
    );
  }

  /// 角度检测：检查身体朝向
  QualityCheckResult _checkAngle(List<Map<int, Offset>>? poses) {
    if (poses == null || poses.isEmpty) {
      return const QualityCheckResult(
        item: QualityCheckItem.angle,
        passed: false,
        score: 0,
        message: '无法检测角度',
      );
    }

    final pose = poses.first;

    // 需要肩膀和髋部关键点
    if (!pose.containsKey(11) || !pose.containsKey(12) ||
        !pose.containsKey(23) || !pose.containsKey(24)) {
      return const QualityCheckResult(
        item: QualityCheckItem.angle,
        passed: false,
        score: 50,
        message: '角度检测中...',
      );
    }

    // 计算身体朝向角度（相对于相机）
    // 使用肩膀中点和髋部中点计算身体倾斜角
    final leftShoulder = pose[11]!;
    final rightShoulder = pose[12]!;
    final leftHip = pose[23]!;
    final rightHip = pose[24]!;

    // 肩膀中点和髋部中点
    final shoulderMid = Offset(
      (leftShoulder.dx + rightShoulder.dx) / 2,
      (leftShoulder.dy + rightShoulder.dy) / 2,
    );
    final hipMid = Offset(
      (leftHip.dx + rightHip.dx) / 2,
      (leftHip.dy + rightHip.dy) / 2,
    );

    // 计算身体与垂直线的角度
    final dx = shoulderMid.dx - hipMid.dx;
    final dy = shoulderMid.dy - hipMid.dy;
    final angle = math.atan2(dx.abs(), dy) * 180 / math.pi;

    // 计算侧身角度（相对于完全侧身）
    // 0 度 = 正对镜头，90 度 = 完全侧身
    // 我们希望 45 度左右（±15 度）
    final targetAngle = 45.0;
    final angleDiff = (angle - targetAngle).abs();

    final passed = angleDiff <= 15;
    final score = (100 - angleDiff / 15 * 100).round().clamp(0, 100);

    String message;
    if (passed) {
      message = '角度合适';
    } else if (angle < 30) {
      message = '请转动身体，侧对镜头';
    } else if (angle > 60) {
      message = '请转动身体，正对镜头一些';
    } else {
      message = '请调整身体角度';
    }

    return QualityCheckResult(
      item: QualityCheckItem.angle,
      passed: passed,
      score: score,
      message: message,
    );
  }

  /// 计算姿态边界框
  Rect _calculatePoseBounds(Map<int, Offset> pose) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in pose.values) {
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
      maxX = math.max(maxX, point.dx);
      maxY = math.max(maxY, point.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// 计算覆盖率
  double _calculateCoverage(Rect bounds) {
    // 假设画面比例为 16:9
    const aspectRatio = 16 / 9;
    final area = bounds.width * bounds.height;
    final normalizedArea = area / (aspectRatio * 100 * 100); // 归一化到 100x100
    return normalizedArea.clamp(0.0, 1.0);
  }

  /// 重置历史记录
  void reset() {
    _poseHistory.clear();
  }

  /// 释放资源
  void dispose() {
    _poseHistory.clear();
  }
}

/// 质量门控状态显示组件
class QualityGateIndicator extends StatelessWidget {
  /// 质量门控状态
  final QualityGateStatus status;

  /// 是否展开显示详情
  final bool expanded;

  const QualityGateIndicator({
    super.key,
    required this.status,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(
                status.allPassed ? Icons.check_circle : Icons.warning,
                color: _getIconColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '质量门控',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
              ),
              const Spacer(),
              Text(
                '${status.overallScore}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(),
                ),
              ),
            ],
          ),

          // 详细项目（展开时显示）
          if (expanded && status.checks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...status.checks.map((check) => _buildCheckItem(check)),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItem(QualityCheckResult check) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            check.passed ? Icons.check : Icons.close,
            color: check.passed ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              check.message,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (status.checks.isEmpty) return Colors.grey.shade100;
    if (status.allPassed) return Colors.green.shade50;
    return Colors.orange.shade50;
  }

  Color _getBorderColor() {
    if (status.checks.isEmpty) return Colors.grey.shade300;
    if (status.allPassed) return Colors.green.shade200;
    return Colors.orange.shade200;
  }

  Color _getIconColor() {
    if (status.checks.isEmpty) return Colors.grey;
    if (status.allPassed) return Colors.green;
    return Colors.orange;
  }

  Color _getTextColor() {
    if (status.checks.isEmpty) return Colors.grey;
    if (status.allPassed) return Colors.green.shade700;
    return Colors.orange.shade700;
  }

  Color _getScoreColor() {
    if (status.overallScore >= 80) return Colors.green;
    if (status.overallScore >= 50) return Colors.orange;
    return Colors.red;
  }
}
