import 'dart:math';
import 'dart:ui';
import 'pose_detector.dart';
import 'swing_phase_detector.dart';

/// 挥棒指标数据结构
///
/// 包含挥棒动作的核心分析指标:
/// - 速度: 挥棒速度
/// - 角度: 挥棒平面角度
/// - 协调性: 髋肩时序差、重心转移流畅度
class SwingMetrics {
  const SwingMetrics({
    required this.velocity,
    required this.velocityLevel,
    required this.maxAngle,
    required this.hipShoulderDelay,
    required this.transferSmoothness,
    this.isReference = true,
  });

  /// 挥棒速度 (m/s)
  final double velocity;

  /// 速度等级: 慢/中/快
  final String velocityLevel;

  /// 最大挥棒角度 (度)
  final double maxAngle;

  /// 髋肩时序差 (毫秒)
  /// 正值表示髋部先于肩部转动 (理想)
  final double hipShoulderDelay;

  /// 重心转移流畅度 (0-1)
  /// 1表示最流畅，0表示最不流畅
  final double transferSmoothness;

  /// 是否为参考值
  final bool isReference;

  /// 速度格式化输出
  String get velocityFormatted => '${velocity.toStringAsFixed(1)} m/s${isReference ? " (参考值)" : ""}';

  /// 角度格式化输出
  String get angleFormatted => '${maxAngle.toStringAsFixed(0)}°${isReference ? " (参考值)" : ""}';

  /// 协调性等级
  String get coordinationLevel {
    // 综合评估协调性
    final hipScore = hipShoulderDelay > 0 ? 1.0 : 0.5;
    final transferScore = transferSmoothness;
    final overall = (hipScore + transferScore) / 2;

    if (overall >= 0.8) return '优秀${isReference ? " (参考值)" : ""}';
    if (overall >= 0.6) return '良好${isReference ? " (参考值)" : ""}';
    if (overall >= 0.4) return '一般${isReference ? " (参考值)" : ""}';
    return '较差${isReference ? " (参考值)" : ""}';
  }

  /// 髋肩时序格式化输出
  String get hipShoulderDelayFormatted {
    final value = hipShoulderDelay.abs().toStringAsFixed(0);
    if (hipShoulderDelay > 0) {
      return '$value ms (髋部领先)${isReference ? " (参考值)" : ""}';
    } else if (hipShoulderDelay < 0) {
      return '$value ms (肩部领先)${isReference ? " (参考值)" : ""}';
    }
    return '同步${isReference ? " (参考值)" : ""}';
  }

  /// 重心转移格式化输出
  String get transferSmoothnessFormatted {
    final percentage = (transferSmoothness * 100).toStringAsFixed(0);
    return '$percentage%${isReference ? " (参考值)" : ""}';
  }

  @override
  String toString() {
    return 'SwingMetrics(velocity: $velocityFormatted, angle: $angleFormatted, coordination: $coordinationLevel)';
  }
}

/// 指标计算器配置
class MetricsCalculatorConfig {
  const MetricsCalculatorConfig({
    /// 默认身高 (厘米)
    this.defaultHeightCm = 170.0,

    /// 默认肩宽 (厘米)
    this.defaultShoulderWidthCm = 40.0,

    /// 帧率 (fps)
    this.frameRate = 30.0,

    /// 速度平滑窗口大小
    this.velocitySmoothingWindow = 3,

    /// 角度平滑窗口大小
    this.angleSmoothingWindow = 5,
  });

  /// 默认身高 (厘米)
  final double defaultHeightCm;

  /// 默认肩宽 (厘米)
  final double defaultShoulderWidthCm;

  /// 帧率 (fps)
  final double frameRate;

  /// 速度平滑窗口大小
  final int velocitySmoothingWindow;

  /// 角度平滑窗口大小
  final int angleSmoothingWindow;
}

/// 帧扩展数据
///
/// 包含帧的完整姿态信息，用于指标计算
class ExtendedFrameData {
  const ExtendedFrameData({
    required this.frameIndex,
    required this.timestamp,
    required this.wristPosition,
    required this.shoulderPosition,
    required this.hipCenter,
    this.wristVelocity = 0.0,
    this.swingAngle = 0.0,
    this.hipRotation = 0.0,
    this.shoulderRotation = 0.0,
  });

  /// 帧索引
  final int frameIndex;

  /// 时间戳 (毫秒)
  final int timestamp;

  /// 腕部位置 (x, y, z)
  final Offset wristPosition;

  /// 肩部位置 (x, y, z)
  final Offset shoulderPosition;

  /// 髋部中心位置 (x, y)
  final Offset hipCenter;

  /// 腕部速度 (归一化坐标/秒)
  final double wristVelocity;

  /// 挥棒角度 (度)
  final double swingAngle;

  /// 髋部转动角度 (度)
  final double hipRotation;

  /// 肩部转动角度 (度)
  final double shoulderRotation;
}

/// 挥棒指标计算器
///
/// 基于姿态数据计算挥棒的核心指标
class SwingMetricsCalculator {
  SwingMetricsCalculator({MetricsCalculatorConfig? config})
      : _config = config ?? const MetricsCalculatorConfig();

  final MetricsCalculatorConfig _config;

  /// 标定因子: 归一化坐标到米的转换
  /// 基于肩宽计算: 肩宽 / 归一化肩宽
  double get _calibrationFactor {
    // 假设归一化坐标中肩宽约为0.2 (两个肩膀在归一化坐标中的距离)
    const normalizedShoulderWidth = 0.2;
    return _config.defaultShoulderWidthCm / 100.0 / normalizedShoulderWidth;
  }

  /// 计算挥棒指标
  ///
  /// [frames] 包含完整姿态信息的帧数据列表
  /// [phaseResult] 挥棒阶段检测结果
  /// [useDominantHand] 是否使用惯用手 (true=右手)
  SwingMetrics calculate(
    List<ExtendedFrameData> frames,
    SwingPhaseResult phaseResult, {
    bool useDominantHand = true,
  }) {
    // 验证输入
    if (frames.isEmpty) {
      return _createDefaultMetrics();
    }

    // 计算各项指标
    final velocity = _calculateVelocity(frames, phaseResult);
    final maxAngle = _calculateMaxAngle(frames, phaseResult);
    final hipShoulderDelay = _calculateHipShoulderDelay(frames, phaseResult);
    final transferSmoothness = _calculateTransferSmoothness(frames, phaseResult);

    // 确定速度等级
    final velocityLevel = _getVelocityLevel(velocity);

    return SwingMetrics(
      velocity: velocity,
      velocityLevel: velocityLevel,
      maxAngle: maxAngle,
      hipShoulderDelay: hipShoulderDelay,
      transferSmoothness: transferSmoothness,
      isReference: true,
    );
  }

  /// 创建默认指标
  SwingMetrics _createDefaultMetrics() {
    return const SwingMetrics(
      velocity: 0.0,
      velocityLevel: '未知',
      maxAngle: 0.0,
      hipShoulderDelay: 0.0,
      transferSmoothness: 0.0,
      isReference: true,
    );
  }

  /// 计算挥棒速度
  ///
  /// 使用腕部关键点轨迹计算绝对速度
  /// 速度 = 位移 / 时间
  double _calculateVelocity(
    List<ExtendedFrameData> frames,
    SwingPhaseResult phaseResult,
  ) {
    if (frames.length < 2) return 0.0;

    // 找到击球期或速度峰值区域
    final peakIndex = _findPeakIndex(frames, phaseResult);
    if (peakIndex == -1) {
      // 如果没有阶段信息，使用整个序列的最大速度
      return _calculateMaxVelocity(frames);
    }

    // 计算击球前后的速度
    final analysisRange = _getAnalysisRange(frames.length, peakIndex);

    double totalVelocity = 0.0;
    int count = 0;

    for (int i = analysisRange[0]; i < analysisRange[1] && i < frames.length - 1; i++) {
      final current = frames[i];
      final next = frames[i + 1];

      // 计算位移 (使用标定因子转换为米)
      final dx = (next.wristPosition.dx - current.wristPosition.dx) * _calibrationFactor;
      final dy = (next.wristPosition.dy - current.wristPosition.dy) * _calibrationFactor;
      final distance = sqrt(dx * dx + dy * dy);

      // 计算时间差 (秒)
      final timeDelta = (next.timestamp - current.timestamp) / 1000.0;
      if (timeDelta > 0) {
        totalVelocity += distance / timeDelta;
        count++;
      }
    }

    if (count == 0) return 0.0;
    return totalVelocity / count;
  }

  /// 计算最大速度
  double _calculateMaxVelocity(List<ExtendedFrameData> frames) {
    if (frames.length < 2) return 0.0;

    double maxVelocity = 0.0;

    for (int i = 0; i < frames.length - 1; i++) {
      final current = frames[i];
      final next = frames[i + 1];

      // 计算位移
      final dx = (next.wristPosition.dx - current.wristPosition.dx) * _calibrationFactor;
      final dy = (next.wristPosition.dy - current.wristPosition.dy) * _calibrationFactor;
      final distance = sqrt(dx * dx + dy * dy);

      // 计算时间差
      final timeDelta = (next.timestamp - current.timestamp) / 1000.0;
      if (timeDelta > 0) {
        final velocity = distance / timeDelta;
        if (velocity > maxVelocity) {
          maxVelocity = velocity;
        }
      }
    }

    return maxVelocity;
  }

  /// 找到峰值索引
  int _findPeakIndex(List<ExtendedFrameData> frames, SwingPhaseResult phaseResult) {
    // 优先使用阶段检测的击球期索引
    if (phaseResult.phaseBoundaries.isNotEmpty) {
      // 击球期在第二个边界
      if (phaseResult.phaseBoundaries.length >= 2) {
        return phaseResult.phaseBoundaries[1];
      }
    }

    // 否则找速度最大的帧
    double maxVel = 0.0;
    int maxIndex = -1;

    for (int i = 0; i < frames.length; i++) {
      if (frames[i].wristVelocity > maxVel) {
        maxVel = frames[i].wristVelocity;
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  /// 获取分析范围
  List<int> _getAnalysisRange(int totalFrames, int peakIndex) {
    // 分析击球前后各一段范围
    final start = max(0, peakIndex - totalFrames ~/ 4);
    final end = min(totalFrames - 1, peakIndex + totalFrames ~/ 4);
    return [start, end];
  }

  /// 获取速度等级
  String _getVelocityLevel(double velocity) {
    // 基于典型棒球挥棒速度的分级
    // 职业棒球运动员挥棒速度通常在 25-35 m/s
    // 普通业余爱好者通常在 15-25 m/s
    // 初学者通常在 10-15 m/s
    if (velocity >= 25) return '快';
    if (velocity >= 18) return '中';
    return '慢';
  }

  /// 计算最大挥棒角度
  ///
  /// 计算挥棒平面：腕部-肩部连线与水平面的夹角
  /// 识别最大挥棒角度（击球期）
  double _calculateMaxAngle(
    List<ExtendedFrameData> frames,
    SwingPhaseResult phaseResult,
  ) {
    if (frames.isEmpty) return 0.0;

    // 找到击球期区域
    final peakIndex = _findPeakIndex(frames, phaseResult);
    final range = _getAnalysisRange(frames.length, peakIndex);

    // 分析击球前后范围内的角度
    double maxAngle = 0.0;
    for (int i = range[0]; i < range[1] && i < frames.length; i++) {
      final angle = frames[i].swingAngle;
      if (angle > maxAngle) {
        maxAngle = angle;
      }
    }

    // 如果没有预计算的角度，手动计算
    if (maxAngle == 0.0) {
      maxAngle = _calculateSwingAngleManually(frames, range);
    }

    return maxAngle;
  }

  /// 手动计算挥棒角度
  double _calculateSwingAngleManually(
    List<ExtendedFrameData> frames,
    List<int> range,
  ) {
    if (frames.isEmpty) return 0.0;

    double maxAngle = 0.0;

    for (int i = range[0]; i < range[1] && i < frames.length; i++) {
      final wrist = frames[i].wristPosition;
      final shoulder = frames[i].shoulderPosition;

      // 计算腕部到肩部的向量
      final dx = wrist.dx - shoulder.dx;
      final dy = wrist.dy - shoulder.dy;

      // 计算与水平面的夹角
      // atan2 返回弧度，转换为度
      var angle = atan2(dy.abs(), dx) * 180 / pi;

      // 确保角度在 0-90 度范围内
      angle = angle.clamp(0.0, 90.0);

      if (angle > maxAngle) {
        maxAngle = angle;
      }
    }

    return maxAngle;
  }

  /// 计算髋肩启动时序差
  ///
  /// - 计算髋部转动角度变化
  /// - 计算肩部转动角度变化
  /// - 时序差 = 髋部转动时间 - 肩部转动时间
  /// - 理想值: 髋部先于肩部 (时序差 > 0)
  double _calculateHipShoulderDelay(
    List<ExtendedFrameData> frames,
    SwingPhaseResult phaseResult,
  ) {
    if (frames.length < 10) return 0.0;

    // 找到准备期结束点
    int prepareEndIndex = 0;
    if (phaseResult.phaseBoundaries.isNotEmpty) {
      prepareEndIndex = phaseResult.phaseBoundaries[0];
    } else {
      prepareEndIndex = frames.length ~/ 4;
    }

    // 分析准备期到击球期的转动变化
    final hipRotationStart = _getRotationChange(
      frames,
      0,
      prepareEndIndex,
      isHip: true,
    );

    final shoulderRotationStart = _getRotationChange(
      frames,
      0,
      prepareEndIndex,
      isHip: false,
    );

    // 计算时序差
    // 使用角速度来判断谁先启动
    final hipStartTime = _findRotationStartTime(frames, 0, prepareEndIndex, isHip: true);
    final shoulderStartTime = _findRotationStartTime(frames, 0, prepareEndIndex, isHip: false);

    // 返回时序差 (毫秒)
    // 正值表示髋部先启动
    return shoulderStartTime - hipStartTime;
  }

  /// 获取转动变化量
  double _getRotationChange(
    List<ExtendedFrameData> frames,
    int startIndex,
    int endIndex, {
    required bool isHip,
  }) {
    if (startIndex >= endIndex || endIndex >= frames.length) return 0.0;

    final startFrame = frames[startIndex];
    final endFrame = frames[min(endIndex, frames.length - 1)];

    if (isHip) {
      return (endFrame.hipRotation - startFrame.hipRotation).abs();
    } else {
      return (endFrame.shoulderRotation - startFrame.shoulderRotation).abs();
    }
  }

  /// 找到转动开始时间
  int _findRotationStartTime(
    List<ExtendedFrameData> frames,
    int startIndex,
    int endIndex, {
    required bool isHip,
  }) {
    if (frames.length < 2) return 0;

    // 阈值：转动超过一定角度认为开始
    const rotationThreshold = 5.0; // 度

    for (int i = startIndex; i < endIndex && i < frames.length; i++) {
      final rotation = isHip ? frames[i].hipRotation : frames[i].shoulderRotation;
      if (rotation.abs() > rotationThreshold) {
        return frames[i].timestamp;
      }
    }

    // 如果没找到，返回起始时间
    return frames[startIndex].timestamp;
  }

  /// 计算重心转移流畅度
  ///
  /// - 计算左右髋部关键点中点作为髋部中心
  /// - 分析髋部中心在击球前后的位移
  /// - 评估平滑度
  double _calculateTransferSmoothness(
    List<ExtendedFrameData> frames,
    SwingPhaseResult phaseResult,
  ) {
    if (frames.length < 10) return 0.0;

    // 找到击球期
    final peakIndex = _findPeakIndex(frames, phaseResult);
    final range = _getAnalysisRange(frames.length, peakIndex);

    // 分析击球前后的重心位移
    final beforeStrike = range[0];
    final afterStrike = min(range[1], frames.length - 1);

    // 提取重心轨迹
    final hipPositions = <Offset>[];
    for (int i = beforeStrike; i <= afterStrike; i++) {
      hipPositions.add(frames[i].hipCenter);
    }

    if (hipPositions.length < 3) return 0.0;

    // 计算位移方差作为流畅度指标
    // 方差越小表示越流畅
    final smoothness = _calculateTrajectorySmoothness(hipPositions);

    return smoothness;
  }

  /// 计算轨迹流畅度
  ///
  /// 使用位移变化率的方差来评估流畅度
  /// 方差越小越流畅
  double _calculateTrajectorySmoothness(List<Offset> positions) {
    if (positions.length < 3) return 0.0;

    // 计算相邻位移
    final displacements = <double>[];
    for (int i = 1; i < positions.length; i++) {
      final dx = positions[i].dx - positions[i - 1].dx;
      final dy = positions[i].dy - positions[i - 1].dy;
      displacements.add(sqrt(dx * dx + dy * dy));
    }

    if (displacements.isEmpty) return 0.0;

    // 计算平均位移
    double sum = 0.0;
    for (final d in displacements) {
      sum += d;
    }
    final mean = sum / displacements.length;

    // 计算方差
    double variance = 0.0;
    for (final d in displacements) {
      variance += (d - mean) * (d - mean);
    }
    variance /= displacements.length;

    // 转换为流畅度分数 (0-1)
    // 方差越小，流畅度越高
    // 使用指数衰减来映射方差到流畅度
    final smoothness = exp(-variance * 10);

    return smoothness.clamp(0.0, 1.0);
  }
}

/// 扩展帧数据构建器
///
/// 用于从姿态数据构建扩展帧数据
class ExtendedFrameBuilder {
  ExtendedFrameBuilder({
    MetricsCalculatorConfig? config,
    this.useDominantHand = true,
  }) : _config = config ?? const MetricsCalculatorConfig();

  final MetricsCalculatorConfig _config;
  final bool useDominantHand;

  /// 构建扩展帧数据
  ExtendedFrameData build(int frameIndex, int timestamp, PoseData poseData) {
    // 获取腕部位置
    final wrist = _getWristPosition(poseData);
    final shoulder = _getShoulderPosition(poseData);
    final hipCenter = _getHipCenter(poseData);

    // 计算挥棒角度
    final swingAngle = _calculateSwingAngle(wrist, shoulder);

    // 计算髋部和肩部转动角度
    final hipRotation = _calculateHipRotation(poseData);
    final shoulderRotation = _calculateShoulderRotation(poseData);

    return ExtendedFrameData(
      frameIndex: frameIndex,
      timestamp: timestamp,
      wristPosition: wrist,
      shoulderPosition: shoulder,
      hipCenter: hipCenter,
      swingAngle: swingAngle,
      hipRotation: hipRotation,
      shoulderRotation: shoulderRotation,
    );
  }

  /// 获取腕部位置
  Offset _getWristPosition(PoseData poseData) {
    final wrist = useDominantHand
        ? poseData.getLandmark(PoseLandmark.rightWrist)
        : poseData.getLandmark(PoseLandmark.leftWrist);

    if (wrist != null && wrist.isValid) {
      return Offset(wrist.x, wrist.y);
    }

    // 备用手腕
    final altWrist = useDominantHand
        ? poseData.getLandmark(PoseLandmark.leftWrist)
        : poseData.getLandmark(PoseLandmark.rightWrist);

    if (altWrist != null && altWrist.isValid) {
      return Offset(altWrist.x, altWrist.y);
    }

    return Offset.zero;
  }

  /// 获取肩部位置
  Offset _getShoulderPosition(PoseData poseData) {
    final shoulder = useDominantHand
        ? poseData.getLandmark(PoseLandmark.rightShoulder)
        : poseData.getLandmark(PoseLandmark.leftShoulder);

    if (shoulder != null && shoulder.isValid) {
      return Offset(shoulder.x, shoulder.y);
    }

    // 使用肩膀中心
    final center = poseData.shoulderCenter;
    return center ?? Offset.zero;
  }

  /// 获取髋部中心
  Offset _getHipCenter(PoseData poseData) {
    final center = poseData.hipCenter;
    return center ?? Offset.zero;
  }

  /// 计算挥棒角度
  double _calculateSwingAngle(Offset wrist, Offset shoulder) {
    // 计算腕部到肩部的向量
    final dx = wrist.dx - shoulder.dx;
    final dy = wrist.dy - shoulder.dy;

    // 计算与水平面的夹角
    final angle = atan2(dy.abs(), dx) * 180 / pi;

    // 确保角度在 0-90 度范围内
    return angle.clamp(0.0, 90.0);
  }

  /// 计算髋部转动角度
  ///
  /// 基于髋部关键点相对于躯干的角度变化
  double _calculateHipRotation(PoseData poseData) {
    final leftHip = poseData.getLandmark(PoseLandmark.leftHip);
    final rightHip = poseData.getLandmark(PoseLandmark.rightHip);
    final nose = poseData.getLandmark(PoseLandmark.nose);

    if (leftHip == null || rightHip == null || nose == null) return 0.0;
    if (!leftHip.isValid || !rightHip.isValid || !nose.isValid) return 0.0;

    // 计算髋部中心到鼻子的角度
    final hipCenterX = (leftHip.x + rightHip.x) / 2;
    final hipCenterY = (leftHip.y + rightHip.y) / 2;

    final dx = nose.x - hipCenterX;
    final dy = nose.y - hipCenterY;

    // 计算相对于初始帧的角度变化
    final angle = atan2(dx, -dy) * 180 / pi;

    return angle;
  }

  /// 计算肩部转动角度
  ///
  /// 基于肩部关键点相对于髋部的角度变化
  double _calculateShoulderRotation(PoseData poseData) {
    final leftShoulder = poseData.getLandmark(PoseLandmark.leftShoulder);
    final rightShoulder = poseData.getLandmark(PoseLandmark.rightShoulder);
    final nose = poseData.getLandmark(PoseLandmark.nose);

    if (leftShoulder == null || rightShoulder == null || nose == null) return 0.0;
    if (!leftShoulder.isValid || !rightShoulder.isValid || !nose.isValid) return 0.0;

    // 计算肩膀中心到鼻子的角度
    final shoulderCenterX = (leftShoulder.x + rightShoulder.x) / 2;
    final shoulderCenterY = (leftShoulder.y + rightShoulder.y) / 2;

    final dx = nose.x - shoulderCenterX;
    final dy = nose.y - shoulderCenterY;

    // 计算相对于初始帧的角度变化
    final angle = atan2(dx, -dy) * 180 / pi;

    return angle;
  }
}
