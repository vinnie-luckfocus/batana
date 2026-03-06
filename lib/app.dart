import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/result_page.dart';
import 'ui/pages/history_page.dart';
import 'ui/theme/app_theme.dart';

/// 路由配置
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/result',
      name: 'result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResultPage(
          score: extra?['score'] as int? ?? 0,
          velocity: extra?['velocity'] as double? ?? 0.0,
          angle: extra?['angle'] as double? ?? 0.0,
          coordination: extra?['coordination'] as double? ?? 0.0,
          suggestions: (extra?['suggestions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              <String>[],
        );
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);

/// 应用程序入口
class BatanaApp extends StatelessWidget {
  const BatanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Batana',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
