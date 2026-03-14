import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../design_system/colors.dart';

/// 全屏相机预览组件
///
/// 提供无黑边的全屏相机预览，支持横竖屏切换
class CameraPreviewWidget extends StatelessWidget {
  /// 相机控制器
  final CameraController? controller;

  /// 是否显示网格辅助线
  final bool showGrid;

  const CameraPreviewWidget({
    Key? key,
    this.controller,
    this.showGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 控制器为空或未初始化时显示加载指示器
    if (controller == null || !controller!.value.isInitialized) {
      return _buildLoadingView();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 全屏相机预览
            _buildCameraPreview(constraints),

            // 网格辅助线
            if (showGrid)
              const _GridOverlay(),
          ],
        );
      },
    );
  }

  /// 构建相机预览
  ///
  /// 根据屏幕比例和相机预览比例，实现无黑边的全屏预览
  Widget _buildCameraPreview(BoxConstraints constraints) {
    final size = constraints.biggest;
    final previewSize = controller!.value.previewSize;

    if (previewSize == null) {
      return CameraPreview(controller!);
    }

    // 计算缩放比例以填满屏幕（无黑边）
    final screenAspect = size.width / size.height;
    final previewAspect = previewSize.width / previewSize.height;

    // 根据方向调整
    final isPortrait = screenAspect < 1;
    final adjustedPreviewAspect = isPortrait
        ? previewAspect
        : 1 / previewAspect;

    // 计算缩放以填满屏幕
    double scale;
    if (screenAspect > adjustedPreviewAspect) {
      // 屏幕比预览宽，按高度缩放
      scale = size.width / (size.height * adjustedPreviewAspect);
    } else {
      // 屏幕比预览窄，按宽度缩放
      scale = size.height / (size.width / adjustedPreviewAspect);
    }

    return ClipRect(
      child: OverflowBox(
        maxWidth: size.width * scale,
        maxHeight: size.height * scale,
        child: CameraPreview(controller!),
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '相机初始化中...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 内部网格辅助线组件
class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GridPainter(),
      ),
    );
  }
}

/// 九宫格辅助线绘制器
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 计算九宫格线位置
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    // 绘制垂直线
    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      paint,
    );

    // 绘制水平线
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
