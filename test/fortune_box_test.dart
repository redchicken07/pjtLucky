import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_app/models/fortune_result.dart';
import 'package:fortune_app/widgets/fortune_box.dart';

void main() {
  testWidgets('fortune box renders four category narratives', (
    WidgetTester tester,
  ) async {
    const FortuneResult fortune = FortuneResult(
      dateKey: '20260324',
      score: 72,
      overallLabel: '상승세',
      title: '오늘의 종합운은 상승세 입니다',
      message: '오늘은 속도를 억지로 올리기보다 이미 잡힌 감을 정리하는 편이 좋습니다.',
      detailMessage: '병화 일간의 바깥 추진력은 살아 있지만 금 기운이 강해 판단과 긴장감이 먼저 작동하는 날입니다.',
      focus: '속도 조절 · 병화 일간 · 행운색 남청',
      signals: <String>['양력 · 정확한 시각 기준', '병화 일간', '신약', '금 강'],
      categoryScores: <String, int>{'종합': 72, '금전운': 68, '애정운': 61, '건강운': 57},
      categoryNarratives: <String, String>{
        '종합': '전체적으로는 기준을 다시 세우는 쪽이 흐름을 안정시키는 하루입니다.',
        '금전운': '금전은 큰 승부보다 새는 지점을 줄이는 쪽이 더 유리합니다.',
        '애정운': '애정은 감정보다 타이밍과 말의 온도를 먼저 보는 편이 좋습니다.',
        '건강운': '건강은 피로를 한 번에 푸는 것보다 리듬을 무너뜨리지 않는 편이 중요합니다.',
      },
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: FortuneBox(fortune: fortune)),
        ),
      ),
    );

    expect(find.text('오늘의 운세'), findsOneWidget);
    expect(find.text('종합'), findsWidgets);
    expect(find.text('금전운'), findsWidgets);
    expect(find.text('애정운'), findsWidgets);
    expect(find.text('건강운'), findsWidgets);
    expect(find.textContaining('기준을 다시 세우는 쪽이 흐름을 안정시키는 하루'), findsOneWidget);
    expect(find.textContaining('새는 지점을 줄이는 쪽이 더 유리합니다'), findsOneWidget);
    expect(find.textContaining('말의 온도를 먼저 보는 편이 좋습니다'), findsOneWidget);
    expect(find.textContaining('리듬을 무너뜨리지 않는 편이 중요합니다'), findsOneWidget);
  });
}
