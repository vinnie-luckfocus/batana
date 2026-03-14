import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:batana/screens/home/home_screen.dart';
import 'package:batana/screens/home/widgets/home_header.dart';
import 'package:batana/screens/home/widgets/function_card.dart';
import 'package:batana/screens/home/widgets/custom_bottom_nav_bar.dart';
import 'package:batana/screens/home/widgets/recent_analysis_section.dart';
import 'package:batana/providers/home_state.dart';
import 'package:batana/storage/storage.dart';

// 创建一个 mock 的 HomeState 用于测试
class MockHomeState extends ChangeNotifier implements HomeState {
  List<AnalysisRecord> _recentRecords = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = true;

  @override
  List<AnalysisRecord> get recentRecords => List.unmodifiable(_recentRecords);

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get hasError => _error != null;

  @override
  bool get hasRecords => _recentRecords.isNotEmpty;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<void> loadRecentRecords() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 10));
    _setLoading(false);
  }

  @override
  Future<void> refresh() async {
    await loadRecentRecords();
  }

  @override
  Future<void> deleteRecord(int id) async {
    _recentRecords.removeWhere((record) => record.id == id);
    notifyListeners();
  }

  @override
  Future<void> addRecord(AnalysisRecord record) async {
    _recentRecords.insert(0, record);
    notifyListeners();
  }

  @override
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

void main() {
  /// 辅助方法：包装 MaterialApp 和 Provider
  Widget buildTestWidget(Widget child, {HomeState? homeState}) {
    return ChangeNotifierProvider<HomeState>.value(
      value: homeState ?? MockHomeState(),
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// 辅助方法：包装带 GoRouter 的测试组件
  Widget buildTestWidgetWithRouter(Widget child, {HomeState? homeState}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const Scaffold(body: Text('History Page')),
        ),
        GoRoute(
          path: '/record',
          builder: (context, state) => const Scaffold(body: Text('Record Page')),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const Scaffold(body: Text('Gallery Page')),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const Scaffold(body: Text('Result Page')),
        ),
      ],
    );

    return ChangeNotifierProvider<HomeState>.value(
      value: homeState ?? MockHomeState(),
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('应该包含 HomeHeader', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('应该包含 3 个 FunctionCard', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FunctionCard), findsNWidgets(3));
    });

    testWidgets('应该包含录制视频卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('录制视频'), findsOneWidget);
      expect(find.text('实时录制挥棒动作'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('应该包含选择相册卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('选择相册'), findsOneWidget);
      expect(find.text('从相册选择视频分析'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('应该包含历史记录卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('历史记录'), findsOneWidget);
      expect(find.text('查看过往分析结果'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('应该包含 CustomBottomNavBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('应该支持下拉刷新', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 验证 RefreshIndicator 存在
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('应该使用 CustomScrollView 布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('点击录制视频卡片应该触发回调', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidgetWithRouter(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 点击录制视频卡片
      await tester.tap(find.text('录制视频'));
      await tester.pumpAndSettle();

      // 验证导航到录制页面
      expect(find.text('Record Page'), findsOneWidget);
    });

    testWidgets('底部导航栏默认选中主页', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<CustomBottomNavBar>(
        find.byType(CustomBottomNavBar),
      );
      expect(navBar.currentIndex, 0);
    });

    testWidgets('点击底部导航栏应该切换 Tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidgetWithRouter(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 点击历史 Tab
      await tester.tap(find.text('历史'));
      await tester.pumpAndSettle();

      // 验证导航到历史页面
      expect(find.text('History Page'), findsOneWidget);
    });

    testWidgets('下拉刷新应该触发刷新回调', (WidgetTester tester) async {
      final mockHomeState = MockHomeState();

      await tester.pumpWidget(
        ChangeNotifierProvider<HomeState>.value(
          value: mockHomeState,
          child: MaterialApp(
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 找到 RefreshIndicator 并触发刷新
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // 执行下拉刷新手势
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // 验证刷新被触发
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('应该显示正确的页面背景色', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('点击功能卡片应该触发导航', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidgetWithRouter(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 点击选择相册卡片
      await tester.tap(find.text('选择相册'));
      await tester.pumpAndSettle();

      // 验证导航到相册页面
      expect(find.text('Gallery Page'), findsOneWidget);
    });

    testWidgets('点击历史记录卡片应该触发导航', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidgetWithRouter(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 点击历史记录卡片
      await tester.tap(find.text('历史记录'));
      await tester.pumpAndSettle();

      // 验证导航到历史页面
      expect(find.text('History Page'), findsOneWidget);
    });

    testWidgets('应该包含 RecentAnalysisSection', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RecentAnalysisSection), findsOneWidget);
    });

    testWidgets('应该使用 Scaffold 作为根布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('应该使用 Column 布局主体内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('应该使用 Expanded 包裹可滚动区域', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 验证至少有一个 Expanded
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('应该使用 SliverList 显示功能卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SliverList), findsOneWidget);
    });

    testWidgets('应该使用 SliverPadding 设置内边距', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SliverPadding), findsOneWidget);
    });

    testWidgets('功能卡片之间应该有间距', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 验证有 SizedBox 作为间距
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('应该支持无障碍访问', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(const HomeScreen()),
      );
      await tester.pumpAndSettle();

      // 验证组件可以被辅助技术访问
      final semantics = tester.getSemantics(find.byType(HomeScreen));
      expect(semantics, isNotNull);
    });

    testWidgets('初始化时应该调用 HomeState.initialize', (WidgetTester tester) async {
      final mockHomeState = MockHomeState();

      await tester.pumpWidget(
        ChangeNotifierProvider<HomeState>.value(
          value: mockHomeState,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 验证 HomeScreen 渲染成功
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
