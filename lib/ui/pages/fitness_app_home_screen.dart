import 'package:flutter/material.dart';
import '../theme/fitness_app_theme.dart';
import '../widgets/bottom_bar_view.dart';
import '../../models/tab_icon_data.dart';
import 'home_page.dart';
import 'history_page.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  const FitnessAppHomeScreen({Key? key}) : super(key: key);

  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  Widget tabBody = Container(color: FitnessAppTheme.background);

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    tabBody = HomePage(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            // 点击中央录制按钮
            _onRecordButtonTap();
          },
          changeIndex: (int index) {
            if (index == 0 || index == 2) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) return;
                setState(() {
                  tabBody = HomePage(animationController: animationController);
                });
              });
            } else if (index == 1 || index == 3) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) return;
                setState(() {
                  tabBody = const HistoryPage();
                });
              });
            }
          },
        ),
      ],
    );
  }

  void _onRecordButtonTap() {
    // 导航到录制页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordingPage(),
      ),
    );
  }
}

// 临时录制页面占位
class RecordingPage extends StatelessWidget {
  const RecordingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        backgroundColor: FitnessAppTheme.nearlyDarkBlue,
        title: const Text('录制挥棒'),
      ),
      body: const Center(
        child: Text('录制页面 - 正在开发中'),
      ),
    );
  }
}
