/// 设备配置
///
/// 用于多机型测试验证的配置
class DeviceConfig {
  const DeviceConfig(
    this.name,
    this.platform,
    this.minVersion,
  );

  /// 设备名称
  final String name;

  /// 平台: ios / android
  final String platform;

  /// 最低系统版本
  final String minVersion;

  @override
  String toString() => '$name ($platform $minVersion)';
}

/// 设备测试矩阵
///
/// 定义需要验证的设备组合
class DeviceTestMatrix {
  DeviceTestMatrix._();

  /// iOS 设备列表
  static const List<DeviceConfig> iosDevices = [
    DeviceConfig('iPhone 12', 'ios', '14.0'),
    DeviceConfig('iPhone 13', 'ios', '15.0'),
    DeviceConfig('iPhone 14', 'ios', '16.0'),
    DeviceConfig('iPhone 15', 'ios', '17.0'),
    DeviceConfig('iPhone SE (3rd)', 'ios', '15.0'),
    DeviceConfig('iPad Pro 11"', 'ios', '14.0'),
    DeviceConfig('iPad Air (4th)', 'ios', '14.0'),
  ];

  /// Android 设备列表
  static const List<DeviceConfig> androidDevices = [
    DeviceConfig('Pixel 6', 'android', '12'),
    DeviceConfig('Pixel 7', 'android', '13'),
    DeviceConfig('Pixel 8', 'android', '14'),
    DeviceConfig('Samsung Galaxy S21', 'android', '11'),
    DeviceConfig('Samsung Galaxy S22', 'android', '12'),
    DeviceConfig('Samsung Galaxy S23', 'android', '13'),
    DeviceConfig('Samsung Galaxy A53', 'android', '12'),
    DeviceConfig('OnePlus 9', 'android', '11'),
    DeviceConfig('OnePlus 10', 'android', '12'),
    DeviceConfig('Xiaomi 12', 'android', '12'),
    DeviceConfig('Xiaomi 13', 'android', '13'),
  ];

  /// 完整设备列表
  static const List<DeviceConfig> allDevices = [
    // iOS 设备
    DeviceConfig('iPhone 12', 'ios', '14.0'),
    DeviceConfig('iPhone 13', 'ios', '15.0'),
    DeviceConfig('iPhone 14', 'ios', '16.0'),
    DeviceConfig('iPhone 15', 'ios', '17.0'),

    // Android 设备
    DeviceConfig('Pixel 6', 'android', '12'),
    DeviceConfig('Pixel 7', 'android', '13'),
    DeviceConfig('Samsung Galaxy S22', 'android', '12'),
    DeviceConfig('Samsung Galaxy A53', 'android', '12'),
    DeviceConfig('Xiaomi 12', 'android', '12'),
  ];

  /// 推荐测试设备组合 (MVP 阶段)
  ///
  /// 覆盖主流设备型号和系统版本
  static const List<DeviceConfig> recommendedDevices = [
    DeviceConfig('iPhone 12', 'ios', '14.0'),
    DeviceConfig('iPhone 14', 'ios', '16.0'),
    DeviceConfig('Pixel 6', 'android', '12'),
    DeviceConfig('Samsung Galaxy A53', 'android', '12'),
  ];

  /// 获取指定平台的设备列表
  static List<DeviceConfig> getDevicesByPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return iosDevices;
      case 'android':
        return androidDevices;
      default:
        return allDevices;
    }
  }

  /// 验证设备是否在支持范围内
  static bool isDeviceSupported(DeviceConfig device, String minPlatformVersion) {
    // 简化版本检查逻辑
    final deviceVersion = _parseVersion(device.minVersion);
    final minVersion = _parseVersion(minPlatformVersion);

    return deviceVersion >= minVersion;
  }

  /// 解析版本号
  static int _parseVersion(String version) {
    // 提取主版本号
    final parts = version.split('.');
    if (parts.isEmpty) return 0;

    return int.tryParse(parts.first) ?? 0;
  }
}

/// 性能目标配置
class PerformanceTargets {
  const PerformanceTargets({
    this.p50TargetMs = 10000,
    this.p95TargetMs = 15000,
    this.p99TargetMs = 20000,
  });

  /// P50 目标 (中位数)
  final int p50TargetMs;

  /// P95 目标
  final int p95TargetMs;

  /// P99 目标
  final int p99TargetMs;

  /// MVP 阶段性能目标
  static const PerformanceTargets mvp = PerformanceTargets(
    p50TargetMs: 10000,
    p95TargetMs: 15000,
    p99TargetMs: 20000,
  );

  /// V2 阶段性能目标
  static const PerformanceTargets v2 = PerformanceTargets(
    p50TargetMs: 8000,
    p95TargetMs: 12000,
    p99TargetMs: 15000,
  );

  /// V3 阶段性能目标 (融合分析)
  static const PerformanceTargets v3 = PerformanceTargets(
    p50TargetMs: 6000,
    p95TargetMs: 10000,
    p99TargetMs: 12000,
  );
}

/// 测试环境配置
class TestEnvironment {
  const TestEnvironment({
    required this.name,
    required this.device,
    this.performanceTargets = PerformanceTargets.mvp,
  });

  /// 环境名称
  final String name;

  /// 目标设备
  final DeviceConfig device;

  /// 性能目标
  final PerformanceTargets performanceTargets;

  /// CI 测试环境
  static const TestEnvironment ci = TestEnvironment(
    name: 'CI',
    device: DeviceConfig('CI Simulator', 'ios', '14.0'),
  );

  /// 开发设备环境
  static const TestEnvironment dev = TestEnvironment(
    name: 'Development',
    device: DeviceConfig('Local Device', 'ios', '14.0'),
  );
}
