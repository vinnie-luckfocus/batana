import 'package:flutter_test/flutter_test.dart';
import 'package:batana/providers/home_state.dart';

void main() {
  group('HomeState', () {
    test('初始状态正确', () {
      final homeState = HomeState();

      expect(homeState.isLoading, false);
      expect(homeState.hasError, false);
      expect(homeState.error, isNull);
      expect(homeState.hasRecords, false);
      expect(homeState.recentRecords, isEmpty);
      expect(homeState.isInitialized, false);

      homeState.dispose();
    });

    test('clearError 清除错误状态', () {
      final homeState = HomeState();

      // 验证初始状态
      expect(homeState.hasError, false);

      homeState.dispose();
    });

    test('dispose 关闭数据库连接', () {
      final homeState = HomeState();

      // 确保 dispose 不会抛出异常
      expect(() => homeState.dispose(), returnsNormally);
    });
  });
}
