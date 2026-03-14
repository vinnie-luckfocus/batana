import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'design_system/colors.dart';
import 'design_system/neumorphic_theme.dart';
import 'providers/home_state.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置系统 UI 样式
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const BatanaApp());
}

/// 应用程序入口
class BatanaApp extends StatelessWidget {
  const BatanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeState(),
      child: MaterialApp.router(
        title: 'Batana',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
        ),
        builder: (context, child) {
          return NeumorphicTheme(
            theme: AppNeumorphicTheme.lightTheme,
            child: child!,
          );
        },
        routerConfig: _router,
      ),
    );
  }
}

/// 应用路由配置
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/record',
      builder: (context, state) => const Placeholder(
        child: Scaffold(
          body: Center(child: Text('录制页面 - 待实现')),
        ),
      ),
    ),
    GoRoute(
      path: '/gallery',
      builder: (context, state) => const Placeholder(
        child: Scaffold(
          body: Center(child: Text('相册选择页面 - 待实现')),
        ),
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const Placeholder(
        child: Scaffold(
          body: Center(child: Text('历史记录页面 - 待实现')),
        ),
      ),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        // 可选：从 state.extra 获取分析结果参数
        // final result = state.extra as AnalysisResult?;
        return const Placeholder(
          child: Scaffold(
            body: Center(child: Text('结果展示页面 - 待实现')),
          ),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            '页面未找到: ${state.uri.path}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('返回首页'),
          ),
        ],
      ),
    ),
  ),
);
