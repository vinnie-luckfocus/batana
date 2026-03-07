import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'design_system/colors.dart';
import 'design_system/neumorphic_theme.dart';
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
    return NeumorphicApp(
      title: 'Batana',
      debugShowCheckedModeBanner: false,
      theme: AppNeumorphicTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
