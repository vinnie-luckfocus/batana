import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/pages/fitness_app_home_screen.dart';
import 'ui/theme/fitness_app_theme.dart';

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
    return MaterialApp(
      title: 'Batana',
      debugShowCheckedModeBanner: false,
      theme: FitnessAppTheme.theme,
      home: const FitnessAppHomeScreen(),
    );
  }
}
