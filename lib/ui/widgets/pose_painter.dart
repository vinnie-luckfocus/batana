import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../analysis/pose_detector.dart';

/// 姿态可视化Painter
///
/// 绘制身体关键点和骨骼连接
class PosePainter extends CustomPainter {
  PosePainter({
    required this.poseData,
    this.showLandmarks = true,
    this.showSkeleton = true,
    this.landmarkRadius = 6.0,
    this.skeletonStrokeWidth = 3.0,
    this.validLandmarkColor = const Color(0xFF00FF00),
    this.invalidLandmarkColor = const Color(0x88FF0000),
    this.skeletonColor = const Color(0xFF00FF00),
    this.backgroundColor = Colors.transparent,
  });

  /// 姿态数据
  final PoseData? poseData;

  /// 是否显示关键点
  final bool showLandmarks;

  /// 是否显示骨架
  final bool showSkeleton;

  /// 关键点半径
  final double landmarkRadius;

  /// 骨架线宽
  final double skeletonStrokeWidth;

  /// 有效关键点颜色
  final Color validLandmarkColor;

  /// 无效关键点颜色
  final Color invalidLandmarkColor;

  /// 骨架颜色
  final Color skeletonColor;

  /// 背景颜色
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (poseData == null || !poseData!.isValid) return;

    // 绘制骨架
    if (showSkeleton) {
      _drawSkeleton(canvas, size);
    }

    // 绘制关键点
    if (showLandmarks) {
      _drawLandmarks(canvas, size);
    }
  }

  /// 绘制骨架
  void _drawSkeleton(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = skeletonColor
      ..strokeWidth = skeletonStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final connection in SkeletonConnection.defaultConnections) {
      final startPoint = poseData!.getLandmark(connection.start);
      final endPoint = poseData!.getLandmark(connection.end);

      if (startPoint == null || endPoint == null) continue;
      if (!startPoint.isValid || !endPoint.isValid) continue;

      final start = startPoint.toOffset(size.width, size.height);
      final end = endPoint.toOffset(size.width, size.height);

      // 根据连接类型选择颜色
      if (connection.color != null) {
        paint.color = Color(connection.color!);
      } else {
        paint.color = skeletonColor;
      }

      canvas.drawLine(start, end, paint);
    }
  }

  /// 绘制关键点
  void _drawLandmarks(Canvas canvas, Size size) {
    for (final landmark in poseData!.landmarks) {
      final point = landmark.toOffset(size.width, size.height);
      final isValid = landmark.isValid;

      // 绘制外圈
      final outerPaint = Paint()
        ..color = isValid ? validLandmarkColor : invalidLandmarkColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, landmarkRadius, outerPaint);

      // 绘制内圈 (白色，增加对比度)
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, landmarkRadius * 0.5, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poseData != poseData;
  }
}

/// 姿态叠加组件
///
/// 将姿态检测结果叠加到视频预览上
class PoseOverlay extends StatelessWidget {
  const PoseOverlay({
    super.key,
    required this.poseData,
    this.showLandmarks = true,
    this.showSkeleton = true,
    this.opacity = 1.0,
  });

  /// 姿态数据
  final PoseData? poseData;

  /// 是否显示关键点
  final bool showLandmarks;

  /// 是否显示骨架
  final bool showSkeleton;

  /// 透明度
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: PosePainter(
            poseData: poseData,
            showLandmarks: showLandmarks,
            showSkeleton: showSkeleton,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// 实时姿态预览组件
///
/// 带动画效果的实时姿态预览
class RealtimePosePreview extends StatefulWidget {
  const RealtimePosePreview({
    super.key,
    required this.poseData,
    this.showLandmarks = true,
    this.showSkeleton = true,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  /// 姿态数据
  final PoseData? poseData;

  /// 是否显示关键点
  final bool showLandmarks;

  /// 是否显示骨架
  final bool showSkeleton;

  /// 动画持续时间
  final Duration animationDuration;

  @override
  State<RealtimePosePreview> createState() => _RealtimePosePreviewState();
}

class _RealtimePosePreviewState extends State<RealtimePosePreview> {
  PoseData? _previousPoseData;

  @override
  void didUpdateWidget(covariant RealtimePosePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.poseData != null) {
      _previousPoseData = oldWidget.poseData;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用动画平滑过渡
    final targetPoseData = widget.poseData ?? _previousPoseData;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.animationDuration,
      builder: (context, value, child) {
        return CustomPaint(
          painter: PosePainter(
            poseData: targetPoseData,
            showLandmarks: widget.showLandmarks,
            showSkeleton: widget.showSkeleton,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 关键点样式配置
class PoseVisualizationStyle {
  const PoseVisualizationStyle({
    this.landmarkRadius = 6.0,
    this.skeletonStrokeWidth = 3.0,
    this.validLandmarkColor = const Color(0xFF00FF00),
    this.invalidLandmarkColor = const Color(0x88FF0000),
    this.skeletonColor = const Color(0xFF00FF00),
  });

  /// 关键点半径
  final double landmarkRadius;

  /// 骨架线宽
  final double skeletonStrokeWidth;

  /// 有效关键点颜色
  final Color validLandmarkColor;

  /// 无效关键点颜色
  final Color invalidLandmarkColor;

  /// 骨架颜色
  final Color skeletonColor;

  /// 创建深色样式
  static const PoseVisualizationStyle dark = PoseVisualizationStyle(
    validLandmarkColor: Color(0xFF00FF00),
    invalidLandmarkColor: Color(0x88FF0000),
    skeletonColor: Color(0xFF00FF00),
  );

  /// 创建亮色样式
  static const PoseVisualizationStyle light = PoseVisualizationStyle(
    validLandmarkColor: Color(0xFF0066FF),
    invalidLandmarkColor: Color(0x88FF6600),
    skeletonColor: Color(0xFF0066FF),
  );

  /// 创建自定义颜色样式
  static PoseVisualizationStyle custom({
    required Color landmarkColor,
    Color? skeletonColor,
    Color? invalidColor,
  }) {
    return PoseVisualizationStyle(
      validLandmarkColor: landmarkColor,
      invalidLandmarkColor: invalidColor ?? landmarkColor.withOpacity(0.5),
      skeletonColor: skeletonColor ?? landmarkColor,
    );
  }
}
