import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:batana/design_system/colors.dart';
import 'package:batana/design_system/spacing.dart';
import 'package:batana/providers/home_state.dart';
import 'package:batana/storage/storage.dart';
import 'widgets/home_header.dart';
import 'widgets/function_card.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/recent_analysis_section.dart';

/// 主界面
///
/// 包含顶部标题栏、功能卡片区、最近分析列表、底部导航栏
/// 支持下拉刷新，使用 Provider 管理状态
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 延迟初始化以等待 build 完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeState>().initialize();
    });
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    await context.read<HomeState>().refresh();
  }

  /// 处理底部导航栏点击
  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 根据索引导航到对应页面
    switch (index) {
      case 0:
        // 首页 - 已在首页，无需导航
        break;
      case 1:
        context.push('/history');
        break;
      case 2:
        context.push('/record');
        break;
    }
  }

  /// 处理功能卡片点击
  void _onFunctionCardTap(String function) {
    switch (function) {
      case '录制视频':
        context.push('/record');
        break;
      case '选择相册':
        context.push('/gallery');
        break;
      case '历史记录':
        context.push('/history');
        break;
    }
  }

  /// 处理最近分析记录点击
  void _onRecentRecordTap(AnalysisRecord record) {
    // 导航到结果页，传递记录数据
    context.push('/result', extra: record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 顶部标题栏
          const HomeHeader(),
          // 主体内容
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // 功能卡片区
                  SliverPadding(
                    padding: AppSpacing.pagePadding,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 录制视频卡片
                        FunctionCard(
                          icon: Icons.videocam,
                          title: '录制视频',
                          description: '实时录制挥棒动作',
                          onTap: () => _onFunctionCardTap('录制视频'),
                        ),
                        AppSpacing.verticalSpaceM,
                        // 选择相册卡片
                        FunctionCard(
                          icon: Icons.photo_library,
                          title: '选择相册',
                          description: '从相册选择视频分析',
                          onTap: () => _onFunctionCardTap('选择相册'),
                        ),
                        AppSpacing.verticalSpaceM,
                        // 历史记录卡片
                        FunctionCard(
                          icon: Icons.access_time,
                          title: '历史记录',
                          description: '查看过往分析结果',
                          onTap: () => _onFunctionCardTap('历史记录'),
                        ),
                        AppSpacing.verticalSpaceL,
                        // 最近分析区域
                        RecentAnalysisSection(
                          onRecordTap: _onRecentRecordTap,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部导航栏
          CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavBarTap,
          ),
        ],
      ),
    );
  }
}
