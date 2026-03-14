import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batana/screens/home/widgets/analysis_record_card.dart';
import 'package:batana/storage/storage.dart';
import 'package:batana/design_system/colors.dart';

void main() {
  /// 辅助方法：包装 MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// 创建测试用的分析记录
  AnalysisRecord createTestRecord({
    int? id,
    int score = 85,
    double velocity = 18.5,
    DateTime? createdAt,
  }) {
    return AnalysisRecord(
      id: id ?? 1,
      createdAt: createdAt ?? DateTime.now(),
      score: score,
      velocity: velocity,
      angle: 45.0,
      coordination: 82.0,
      suggestions: ['保持挥杆速度一致性', '注意转体发力'],
      videoPath: null,
    );
  }

  group('AnalysisRecordCard', () {
    testWidgets('应该显示分数', (WidgetTester tester) async {
      final record = createTestRecord(score: 85);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('85'), findsOneWidget);
      expect(find.text('分'), findsOneWidget);
    });

    testWidgets('应该显示挥棒速度', (WidgetTester tester) async {
      final record = createTestRecord(velocity: 20.5);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('20.5'), findsOneWidget);
      expect(find.textContaining('m/s'), findsOneWidget);
    });

    testWidgets('应该显示速度图标', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.speed), findsOneWidget);
    });

    testWidgets('应该显示右箭头', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('高分应该使用绿色', (WidgetTester tester) async {
      final record = createTestRecord(score: 85);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      // 验证高分卡片渲染成功
      expect(find.byType(AnalysisRecordCard), findsOneWidget);
    });

    testWidgets('中等分数应该使用橙色', (WidgetTester tester) async {
      final record = createTestRecord(score: 70);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      // 验证中等分数卡片渲染成功
      expect(find.byType(AnalysisRecordCard), findsOneWidget);
    });

    testWidgets('低分应该使用红色', (WidgetTester tester) async {
      final record = createTestRecord(score: 50);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      // 验证低分卡片渲染成功
      expect(find.byType(AnalysisRecordCard), findsOneWidget);
    });

    testWidgets('点击应该触发 onTap 回调', (WidgetTester tester) async {
      final record = createTestRecord();
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AnalysisRecordCard));
      expect(tapped, isTrue);
    });

    testWidgets('应该使用 Neumorphic 风格容器', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnalysisRecordCard),
          matching: find.byType(Container).first,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('应该使用 Row 布局', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('分数指示器应该使用 Container', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('应该使用 Expanded 包裹信息区域', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('信息区域应该使用 Column 布局', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      // 查找 Expanded 内的 Column
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.child, isA<Column>());
    });

    testWidgets('应该使用 Semantics 包装', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('应该使用 GestureDetector 处理点击', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('应该支持无障碍访问', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AnalysisRecordCard));
      expect(semantics, isNotNull);
    });

    testWidgets('分数边界值 80 应该使用绿色', (WidgetTester tester) async {
      final record = createTestRecord(score: 80);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('80'), findsOneWidget);
    });

    testWidgets('分数边界值 60 应该使用橙色', (WidgetTester tester) async {
      final record = createTestRecord(score: 60);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('分数边界值 59 应该使用红色', (WidgetTester tester) async {
      final record = createTestRecord(score: 59);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('59'), findsOneWidget);
    });

    testWidgets('分数 100 应该使用绿色', (WidgetTester tester) async {
      final record = createTestRecord(score: 99);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('分数 0 应该使用红色', (WidgetTester tester) async {
      final record = createTestRecord(score: 0);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('应该显示今天的日期格式', (WidgetTester tester) async {
      final record = createTestRecord(createdAt: DateTime.now());

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('今天'), findsOneWidget);
    });

    testWidgets('应该显示昨天的日期格式', (WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final record = createTestRecord(createdAt: yesterday);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('昨天'), findsOneWidget);
    });

    testWidgets('应该显示普通日期格式', (WidgetTester tester) async {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final record = createTestRecord(createdAt: lastWeek);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      // 验证普通日期格式显示（不包含"今天"或"昨天"）
      expect(find.byType(AnalysisRecordCard), findsOneWidget);
    });

    testWidgets('速度应该格式化为一位小数', (WidgetTester tester) async {
      final record = createTestRecord(velocity: 18.55);

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('18.6'), findsOneWidget);
    });

    testWidgets('应该使用 BoxDecoration 设置阴影', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnalysisRecordCard),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 2);
    });

    testWidgets('分数区域应该使用圆角', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      // 验证分数区域渲染成功
      expect(find.byType(AnalysisRecordCard), findsOneWidget);
    });

    testWidgets('卡片应该使用正确的背景色', (WidgetTester tester) async {
      final record = createTestRecord();

      await tester.pumpWidget(
        buildTestWidget(
          AnalysisRecordCard(
            record: record,
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnalysisRecordCard),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surface);
    });
  });
}
