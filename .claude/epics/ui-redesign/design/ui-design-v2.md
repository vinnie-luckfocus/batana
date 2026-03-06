---
name: ui-design-v2
created: 2026-03-06T14:30:00Z
updated: 2026-03-06T14:30:00Z
---

# 主界面重构详细设计 V2

## 1. 设计系统规范

### 1.1 色彩系统

```dart
class DesignSystemColors {
  // 主色调 - 棒球主题
  static const Color primary = Color(0xFF1E88E5);      // 棒球蓝
  static const Color primaryDark = Color(0xFF1565C0);  // 深蓝
  static const Color primaryLight = Color(0xFF64B5F6); // 浅蓝

  // 功能色
  static const Color record = Color(0xFFE53935);       // 录制红
  static const Color gallery = Color(0xFF43A047);      // 相册绿
  static const Color history = Color(0xFFFB8C00);      // 历史橙

  // 中性色
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F0F0);

  // 文字色
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);

  // 状态色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
}
```

### 1.2 字体规范

```dart
class DesignSystemTypography {
  // 标题
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: DesignSystemColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: DesignSystemColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: DesignSystemColors.textPrimary,
  );

  // 正文
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: DesignSystemColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: DesignSystemColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: DesignSystemColors.textTertiary,
  );

  // 标签/按钮
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: DesignSystemColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: DesignSystemColors.textSecondary,
  );
}
```

### 1.3 间距系统

```dart
class DesignSystemSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // 页面边距
  static const double pagePadding = 20;

  // 卡片间距
  static const double cardGap = 16;

  // 组件内边距
  static const double cardPadding = 20;
}
```

### 1.4 圆角系统

```dart
class DesignSystemRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double circular = 999;
}
```

## 2. Neumorphic 设计组件

### 2.1 Neumorphic 容器

```dart
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final bool isPressed;
  final List<BoxShadow>? customShadows;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color,
    this.isPressed = false,
    this.customShadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? DesignSystemColors.surface;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: customShadows ?? _buildShadows(bgColor, isPressed),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }

  List<BoxShadow> _buildShadows(Color color, bool pressed) {
    if (pressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];
    }

    return [
      // 外阴影（下右）
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        offset: const Offset(6, 6),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      // 内高光（上左）
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        offset: const Offset(-6, -6),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
}
```

### 2.2 Neumorphic 按钮

```dart
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color ?? DesignSystemColors.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _buildShadows(_isPressed),
        ),
        child: widget.child,
      ),
    );
  }

  List<BoxShadow> _buildShadows(bool pressed) {
    // 同 NeumorphicContainer
  }
}
```

## 3. 主界面详细设计

### 3.1 布局结构

```
HomeScreen（新主界面）
├── SafeArea
│   └── CustomScrollView
│       ├── SliverToBoxAdapter
│       │   └── 顶部欢迎区 (Header)
│       │       ├── 用户头像（圆形 Neumorphic）
│       │       ├── 欢迎语
│       │       └── 当前日期
│       ├── SliverToBoxAdapter
│       │   └── 功能卡片区 (Function Cards)
│       │       ├── 录制视频卡片（大）
│       │       └── 网格：相册卡片 + 历史卡片
│       ├── SliverToBoxAdapter
│       │   └── 最近分析区标题
│       └── SliverList
│           └── 最近分析列表（3条）
└── 底部导航栏 (BottomNavBar)
```

### 3.2 Header 区域

**高度**: 80px
**内边距**: 20px

```dart
class HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystemSpacing.pagePadding),
      child: Row(
        children: [
          // 用户头像
          NeumorphicContainer(
            width: 56,
            height: 56,
            borderRadius: DesignSystemRadius.circular,
            child: const Icon(
              Icons.person_outline,
              color: DesignSystemColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: DesignSystemSpacing.md),
          // 欢迎语
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '早上好，击球手',
                  style: DesignSystemTypography.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: DesignSystemTypography.bodyMedium,
                ),
              ],
            ),
          ),
          // 设置按钮
          NeumorphicButton(
            width: 48,
            height: 48,
            borderRadius: DesignSystemRadius.circular,
            padding: EdgeInsets.zero,
            onPressed: () => context.push('/settings'),
            child: const Icon(
              Icons.settings_outlined,
              color: DesignSystemColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.month}月${now.day}日 ${weekdays[now.weekday - 1]}';
  }
}
```

### 3.3 功能卡片区域

#### 3.3.1 录制视频卡片（主卡片）

**尺寸**: 全宽，高度 160px
**样式**: 渐变背景 + 动态效果

```dart
class RecordVideoCard extends StatelessWidget {
  final VoidCallback onTap;

  const RecordVideoCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        height: 160,
        borderRadius: DesignSystemRadius.lg,
        customShadows: _buildGlowShadows(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystemRadius.lg),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignSystemColors.record,
                Color(0xFFC62828),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 背景装饰
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.videocam,
                  size: 140,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              // 内容
              Padding(
                padding: const EdgeInsets.all(DesignSystemSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 录制图标
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: DesignSystemSpacing.md),
                    // 标题
                    const Text(
                      '录制挥棒',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 描述
                    Text(
                      '开始分析你的挥棒动作',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _buildGlowShadows() {
    return [
      BoxShadow(
        color: DesignSystemColors.record.withOpacity(0.4),
        offset: const Offset(0, 8),
        blurRadius: 24,
        spreadRadius: -4,
      ),
    ];
  }
}
```

#### 3.3.2 相册选择卡片

```dart
class GalleryCard extends StatelessWidget {
  final VoidCallback onTap;

  const GalleryCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      height: 120,
      borderRadius: DesignSystemRadius.lg,
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DesignSystemColors.gallery.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: DesignSystemColors.gallery,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '选择相册',
            style: DesignSystemTypography.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '导入已有视频',
            style: DesignSystemTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

#### 3.3.3 历史记录卡片

```dart
class HistoryCard extends StatelessWidget {
  final VoidCallback onTap;
  final int recordCount;

  const HistoryCard({
    Key? key,
    required this.onTap,
    required this.recordCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      height: 120,
      borderRadius: DesignSystemRadius.lg,
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DesignSystemColors.history.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history,
              color: DesignSystemColors.history,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '历史记录',
            style: DesignSystemTypography.labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '$recordCount 条记录',
            style: DesignSystemTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

### 3.4 最近分析区域

```dart
class RecentAnalysisSection extends StatelessWidget {
  final List<AnalysisRecord> records;

  const RecentAnalysisSection({
    Key? key,
    required this.records,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystemSpacing.pagePadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近分析',
                style: DesignSystemTypography.headlineSmall,
              ),
              TextButton(
                onPressed: () => context.push('/history'),
                child: const Text('查看全部'),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignSystemSpacing.md),
        // 列表
        if (records.isEmpty)
          _buildEmptyState()
        else
          ...records.take(3).map((record) => _buildRecordCard(record)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystemSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: DesignSystemColors.textTertiary,
            ),
            const SizedBox(height: DesignSystemSpacing.md),
            Text(
              '暂无分析记录',
              style: DesignSystemTypography.bodyMedium,
            ),
            const SizedBox(height: DesignSystemSpacing.sm),
            Text(
              '开始录制你的第一次挥棒吧',
              style: DesignSystemTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(AnalysisRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystemSpacing.pagePadding,
        vertical: DesignSystemSpacing.sm,
      ),
      child: NeumorphicButton(
        borderRadius: DesignSystemRadius.md,
        padding: const EdgeInsets.all(DesignSystemSpacing.md),
        onPressed: () => _onRecordTap(record),
        child: Row(
          children: [
            // 分数圆形指示器
            _buildScoreIndicator(record.score),
            const SizedBox(width: DesignSystemSpacing.md),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(record.createdAt),
                    style: DesignSystemTypography.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '挥速: ${record.velocity.toStringAsFixed(1)} m/s',
                    style: DesignSystemTypography.bodySmall,
                  ),
                ],
              ),
            ),
            // 箭头
            const Icon(
              Icons.chevron_right,
              color: DesignSystemColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int score) {
    final color = score >= 80
        ? DesignSystemColors.success
        : score >= 60
            ? DesignSystemColors.warning
            : DesignSystemColors.error;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} 分钟前';
      }
      return '${diff.inHours} 小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    }
    return '${date.month}月${date.day}日';
  }

  void _onRecordTap(AnalysisRecord record) {
    // 导航到结果页面
  }
}
```

### 3.5 底部导航栏

```dart
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystemSpacing.pagePadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: DesignSystemColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, '主页'),
            _buildNavItem(1, Icons.history_rounded, '历史'),
            _buildNavItem(2, Icons.settings_rounded, '设置'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystemColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? DesignSystemColors.primary
                  : DesignSystemColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? DesignSystemColors.primary
                    : DesignSystemColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 4. 完整主界面实现

```dart
class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  int _currentNavIndex = 0;
  List<AnalysisRecord> _recentRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentRecords();
  }

  Future<void> _loadRecentRecords() async {
    final db = DatabaseManager();
    await db.initDatabase();
    final records = await db.getAllRecords();

    setState(() {
      _recentRecords = records;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadRecentRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystemColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: HomeHeader(),
            ),

            // 功能卡片
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DesignSystemSpacing.pagePadding),
                child: Column(
                  children: [
                    // 录制视频卡片
                    RecordVideoCard(
                      onTap: () => context.push('/record'),
                    ),
                    const SizedBox(height: DesignSystemSpacing.cardGap),
                    // 相册和历史
                    Row(
                      children: [
                        Expanded(
                          child: GalleryCard(
                            onTap: () => context.push('/gallery'),
                          ),
                        ),
                        const SizedBox(width: DesignSystemSpacing.cardGap),
                        Expanded(
                          child: HistoryCard(
                            onTap: () => context.push('/history'),
                            recordCount: _recentRecords.length,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 最近分析标题
            const SliverToBoxAdapter(
              child: SizedBox(height: DesignSystemSpacing.lg),
            ),

            // 最近分析列表
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverToBoxAdapter(
                child: RecentAnalysisSection(records: _recentRecords),
              ),

            // 底部留白
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          // 处理导航切换
        },
      ),
    );
  }
}
```

## 5. 动画效果规范

### 5.1 页面过渡动画

```dart
class PageTransitions {
  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 1);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
```

### 5.2 卡片按压效果

```dart
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableCard({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
```

## 6. 响应式适配

```dart
class ResponsiveHomeLayout {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 375; // iPhone SE
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600; // iPad
  }

  static double getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 375) return 140;
    if (width > 600) return 200;
    return 160;
  }

  static EdgeInsets getPagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return const EdgeInsets.all(32);
    return const EdgeInsets.all(20);
  }
}
```

## 7. 性能优化

### 7.1 Widget 优化清单

- [x] 使用 `const` 构造函数
- [x] 使用 `RepaintBoundary` 隔离动画区域
- [x] 使用 `ListView.builder` 替代 `Column` 显示列表
- [x] 图片使用缓存
- [x] 避免在 `build` 中创建对象

### 7.2 阴影性能优化

```dart
// 使用物理层优化阴影渲染
class OptimizedNeumorphic extends StatelessWidget {
  final Widget child;

  const OptimizedNeumorphic({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
```

## 8. 实现检查清单

### 8.1 功能检查
- [ ] 录制视频卡片点击跳转到录制页面
- [ ] 相册卡片点击打开文件选择器
- [ ] 历史卡片点击跳转到历史列表
- [ ] 最近分析记录正确显示
- [ ] 记录点击跳转到详情页
- [ ] 下拉刷新更新数据
- [ ] 底部导航栏切换页面

### 8.2 UI 检查
- [ ] Neumorphic 阴影效果正常
- [ ] 按压动画流畅
- [ ] 页面过渡动画正常
- [ ] 响应式布局适配各种屏幕
- [ ] 暗色模式支持（如需要）

### 8.3 性能检查
- [ ] 页面加载时间 < 100ms
- [ ] 滚动流畅无卡顿
- [ ] 动画 60fps
- [ ] 内存占用合理
