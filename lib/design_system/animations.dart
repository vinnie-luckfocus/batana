import 'package:flutter/material.dart';

/// 设计系统动画定义
///
/// 定义统一的动画时长和缓动曲线，确保交互流畅自然
/// 所有动画时长都经过精心调校，符合人机交互规范
class AppAnimations {
  AppAnimations._();

  // ============================================================================
  // 动画时长 - 基于用户感知的时间设计
  // ============================================================================

  /// Fast - 快速反馈，用于按钮按压、开关切换
  /// 150ms - 用户几乎感觉不到延迟
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal - 标准过渡，用于页面切换、卡片展开
  /// 250ms - 平衡流畅度和可感知性
  static const Duration normal = Duration(milliseconds: 250);

  /// Slow - 慢速动画，用于复杂变化、引导动画
  /// 400ms - 给用户足够时间理解变化
  static const Duration slow = Duration(milliseconds: 400);

  // ============================================================================
  // 缓动曲线 - 模拟真实物理运动
  // ============================================================================

  /// EaseOut - 元素进入场景
  /// 快速启动，缓慢结束，给人轻盈感
  static const Curve easeOut = Curves.easeOut;

  /// EaseIn - 元素退出场景
  /// 缓慢启动，快速结束，给人果断感
  static const Curve easeIn = Curves.easeIn;

  /// EaseInOut - 状态切换
  /// 两端缓慢，中间快速，给人平滑感
  static const Curve easeInOut = Curves.easeInOut;

  /// Spring - 弹性效果
  /// 模拟弹簧运动，给人活泼感
  static const Curve spring = Curves.elasticOut;

  /// Bounce - 弹跳效果
  /// 用于强调和吸引注意力
  static const Curve bounce = Curves.bounceOut;

  /// Decelerate - 减速曲线
  /// 快速启动后逐渐减速，自然流畅
  static const Curve decelerate = Curves.decelerate;

  // ============================================================================
  // 组合动画配置 - 常用的动画组合
  // ============================================================================

  /// 按钮按压动画配置
  static const AnimationConfig buttonPress = AnimationConfig(
    duration: fast,
    curve: easeOut,
  );

  /// 页面切换动画配置
  static const AnimationConfig pageTransition = AnimationConfig(
    duration: normal,
    curve: easeInOut,
  );

  /// 卡片展开动画配置
  static const AnimationConfig cardExpand = AnimationConfig(
    duration: normal,
    curve: easeOut,
  );

  /// 弹窗出现动画配置
  static const AnimationConfig dialogAppear = AnimationConfig(
    duration: normal,
    curve: spring,
  );

  /// 加载动画配置
  static const AnimationConfig loading = AnimationConfig(
    duration: slow,
    curve: easeInOut,
  );

  /// 错误抖动动画配置
  static const AnimationConfig errorShake = AnimationConfig(
    duration: fast,
    curve: bounce,
  );

  // ============================================================================
  // 特殊动画效果
  // ============================================================================

  /// 淡入淡出动画时长
  static const Duration fadeInOut = normal;

  /// 缩放动画时长
  static const Duration scale = fast;

  /// 旋转动画时长
  static const Duration rotation = normal;

  /// 滑动动画时长
  static const Duration slide = normal;

  // ============================================================================
  // 辅助方法
  // ============================================================================

  /// 创建自定义动画配置
  static AnimationConfig custom({
    required Duration duration,
    required Curve curve,
  }) {
    return AnimationConfig(duration: duration, curve: curve);
  }

  /// 创建延迟动画
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }
}

/// 动画配置类
///
/// 封装动画时长和缓动曲线，方便统一管理
class AnimationConfig {
  /// 动画时长
  final Duration duration;

  /// 缓动曲线
  final Curve curve;

  const AnimationConfig({
    required this.duration,
    required this.curve,
  });

  /// 创建动画控制器
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// 创建曲线动画
  Animation<double> createAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  /// 创建补间动画
  Animation<T> createTween<T>(
    AnimationController controller,
    Tween<T> tween,
  ) {
    return tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
}

/// 动画扩展方法
extension AnimationControllerExtension on AnimationController {
  /// 播放动画并等待完成
  Future<void> playForward() async {
    await forward();
  }

  /// 反向播放动画并等待完成
  Future<void> playReverse() async {
    await reverse();
  }

  /// 停止并重置动画
  void stopAndReset() {
    stop();
    reset();
  }
}
