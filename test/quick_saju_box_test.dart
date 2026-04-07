import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_app/logic/saju_logic.dart';
import 'package:fortune_app/models/birth_input.dart';
import 'package:fortune_app/widgets/quick_saju_box.dart';

void main() {
  testWidgets('quick saju box exposes core saju signals first', (
    WidgetTester tester,
  ) async {
    const BirthInput input = BirthInput(
      year: 1992,
      month: 10,
      day: 7,
      hour: 16,
      minute: 0,
      gender: '남성',
    );
    final result = SajuLogic.calculate(input);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: QuickSajuBox(result: result)),
        ),
      ),
    );

    expect(find.text('빠른 사주 요약'), findsOneWidget);
    expect(find.textContaining('일간'), findsWidgets);
    expect(find.text('연주'), findsOneWidget);
    expect(find.text('월령'), findsOneWidget);
    expect(find.text('시주'), findsOneWidget);
    expect(find.text('강한 기운'), findsOneWidget);
    expect(find.text('보완 기운'), findsOneWidget);
    expect(find.text('한 번에 보는 핵심'), findsOneWidget);
    expect(find.textContaining(result.dayMaster), findsWidgets);
    expect(find.textContaining(result.strengthLabel), findsWidgets);
  });
}
