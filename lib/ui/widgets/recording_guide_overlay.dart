import 'package:flutter/material.dart';

/// 录制引导覆盖层
///
/// 显示站位示意图、拍摄距离建议、光照检测状态
class RecordingGuideOverlay extends StatelessWidget {
  /// 是否显示
  final bool visible;

  /// 光照是否充足
  final bool? lightingOk;

  /// 是否检测到人体
  final bool? humanDetected;

  /// 稳定性状态
  final bool? isStable;

  /// 角度是否合适
  final bool? angleOk;

  const RecordingGuideOverlay({
    super.key,
    this.visible = true,
    this.lightingOk,
    this.humanDetected,
    this.isStable,
    this.angleOk,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 半透明背景
        Container(
          color: Colors.black.withOpacity(0.3),
        ),

        // 2. 站位示意图（右侧）
        Positioned(
          right: 16,
          top: 16,
          bottom: 16,
          width: 80,
          child: _buildPoseGuide(),
        ),

        // 3. 距离提示（底部）
        Positioned(
          left: 16,
          right: 100,
          bottom: 16,
          child: _buildDistanceGuide(),
        ),

        // 4. 状态指示器（顶部）
        Positioned(
          left: 16,
          right: 100,
          top: 16,
          child: _buildStatusIndicators(),
        ),

        // 5. 说明文字（居中）
        Center(
          child: _buildCenterGuide(),
        ),
      ],
    );
  }

  /// 构建站位示意图
  Widget _buildPoseGuide() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '站位',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 简化的人体轮廓示意图
          CustomPaint(
            size: const Size(50, 120),
            painter: _PoseGuidePainter(),
          ),
          const SizedBox(height: 8),
          const Text(
            '45°侧身',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建距离提示
  Widget _buildDistanceGuide() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.straighten,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '拍摄距离',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '2-3 米',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicators() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusItem(
            icon: Icons.wb_sunny,
            label: '光照',
            status: lightingOk,
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            icon: Icons.person,
            label: '人物',
            status: humanDetected,
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            icon: Icons.vibration,
            label: '稳定',
            status: isStable,
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            icon: Icons.rotate_right,
            label: '角度',
            status: angleOk,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool? status,
  }) {
    Color color;
    if (status == null) {
      color = Colors.grey;
    } else if (status) {
      color = Colors.green;
    } else {
      color = Colors.orange;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
        if (status != null) ...[
          const SizedBox(width: 4),
          Icon(
            status ? Icons.check_circle : Icons.warning,
            color: color,
            size: 14,
          ),
        ],
      ],
    );
  }

  /// 构建居中说明
  Widget _buildCenterGuide() {
    final isAllGood = lightingOk == true &&
        humanDetected == true &&
        isStable == true &&
        angleOk == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isAllGood ? Colors.green.withOpacity(0.8) : Colors.black54,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAllGood ? Icons.check_circle : Icons.info,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isAllGood ? '可以开始录制' : '请调整站位',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 站位示意图绘制器
class _PoseGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    // 头部
    canvas.drawCircle(Offset(centerX, 15), 8, paint);
    canvas.drawCircle(Offset(centerX, 15), 8, fillPaint);

    // 身体（略微倾斜表示 45 度）
    final bodyPath = Path()
      ..moveTo(centerX, 23)
      ..lineTo(centerX + 8, 50)
      ..lineTo(centerX + 12, 80)
      ..lineTo(centerX - 8, 80)
      ..lineTo(centerX - 12, 50)
      ..close();
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, fillPaint);

    // 手臂（举起示意击球姿势）
    // 右手（球棒）
    final rightArmPath = Path()
      ..moveTo(centerX + 8, 30)
      ..lineTo(centerX + 25, 20);
    canvas.drawPath(rightArmPath, paint);

    // 球棒
    final batPath = Path()
      ..moveTo(centerX + 25, 20)
      ..lineTo(centerX + 40, 50);
    canvas.drawPath(batPath, paint..strokeWidth = 3);

    // 左手
    final leftArmPath = Path()
      ..moveTo(centerX + 5, 30)
      ..lineTo(centerX - 10, 45);
    canvas.drawPath(leftArmPath, paint);

    // 腿部（站立姿势）
    final legPath = Path()
      ..moveTo(centerX - 5, 80)
      ..lineTo(centerX - 15, 110);
    canvas.drawPath(legPath, paint);

    final legPath2 = Path()
      ..moveTo(centerX + 5, 80)
      ..lineTo(centerX + 15, 110);
    canvas.drawPath(legPath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 录制引导控制器
///
/// 用于管理录制引导的状态
class RecordingGuideController extends ChangeNotifier {
  bool _visible = true;
  bool? _lightingOk;
  bool? _humanDetected;
  bool? _isStable;
  bool? _angleOk;

  bool get visible => _visible;
  bool? get lightingOk => _lightingOk;
  bool? get humanDetected => _humanDetected;
  bool? get isStable => _isStable;
  bool? get angleOk => _angleOk;

  /// 是否所有检查都通过
  bool get isAllGood =>
      _lightingOk == true &&
      _humanDetected == true &&
      _isStable == true &&
      _angleOk == true;

  /// 设置可见性
  void setVisible(bool visible) {
    _visible = visible;
    notifyListeners();
  }

  /// 更新光照状态
  void updateLighting(bool? ok) {
    _lightingOk = ok;
    notifyListeners();
  }

  /// 更新人体检测状态
  void updateHumanDetected(bool? detected) {
    _humanDetected = detected;
    notifyListeners();
  }

  /// 更新稳定性状态
  void updateStability(bool? stable) {
    _isStable = stable;
    notifyListeners();
  }

  /// 更新角度状态
  void updateAngle(bool? ok) {
    _angleOk = ok;
    notifyListeners();
  }

  /// 批量更新状态
  void updateStatus({
    bool? lighting,
    bool? human,
    bool? stable,
    bool? angle,
  }) {
    _lightingOk = lighting;
    _humanDetected = human;
    _isStable = stable;
    _angleOk = angle;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _lightingOk = null;
    _humanDetected = null;
    _isStable = null;
    _angleOk = null;
    notifyListeners();
  }

  /// 隐藏引导
  void hide() {
    _visible = false;
    notifyListeners();
  }

  /// 显示引导
  void show() {
    _visible = true;
    notifyListeners();
  }
}
