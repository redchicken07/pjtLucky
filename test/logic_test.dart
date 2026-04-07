import 'package:flutter_test/flutter_test.dart';
import 'package:fortune_app/logic/cards_logic.dart';
import 'package:fortune_app/logic/fortune_logic.dart';
import 'package:fortune_app/logic/precise_saju_logic.dart';
import 'package:fortune_app/logic/saju_logic.dart';
import 'package:fortune_app/models/birth_input.dart';
import 'package:fortune_app/models/precise_saju_input.dart';
import 'package:fortune_app/services/reward_unlock_service.dart';
import 'package:fortune_app/utils/date_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dayKey formats yyyyMMdd', () {
    expect(AppDateUtils.dayKey(DateTime(2026, 3, 22)), '20260322');
  });

  test('saju calculation is deterministic for the same input', () {
    const BirthInput input = BirthInput(
      year: 1992,
      month: 7,
      day: 14,
      hour: 8,
      minute: 30,
      gender: '남성',
    );

    final first = SajuLogic.calculate(input);
    final second = SajuLogic.calculate(input);

    expect(first.toMap(), second.toMap());
    expect(first.energyScore, inInclusiveRange(0, 99));
    expect(first.yearPillar, isNotEmpty);
    expect(first.monthFlow, isNotEmpty);
    expect(first.dayMaster, isNotEmpty);
    expect(first.strengthLabel, isNotEmpty);
    expect(first.dominantElement, isNotEmpty);
    expect(first.dominantTenGod, isNotEmpty);
    expect(first.supportElement, isNotEmpty);
    expect(first.headline, isNotEmpty);
    expect(first.headline, contains('일간'));
    expect(first.surfaceReading, isNotEmpty);
    expect(first.innerReading, isNotEmpty);
    expect(first.summary, isNotEmpty);
    expect(first.summary, contains('일간'));
  });

  test('card numbering maps exactly to 100000 combinations', () {
    expect(CardsLogic.totalCombinations, 100000);
    expect(CardsLogic.slotIndexesFromDrawNumber(1), <int>[0, 0, 0, 0, 0]);
    expect(CardsLogic.slotIndexesFromDrawNumber(100000), <int>[9, 9, 9, 9, 9]);
  });

  test('card draw number is deterministic for the same user and day', () {
    final int first = CardsLogic.drawNumberForDay(
      'tester',
      DateTime(2026, 3, 22),
    );
    final int second = CardsLogic.drawNumberForDay(
      'tester',
      DateTime(2026, 3, 22),
    );

    expect(first, second);
    expect(first, inInclusiveRange(1, CardsLogic.totalCombinations));
  });

  test('card draw loads five slot selections from assets', () async {
    final result = await CardsLogic.drawForDay('tester', DateTime(2026, 3, 22));

    expect(result.slotIndexes, hasLength(CardsLogic.slotCount));
    expect(result.selectedTexts, hasLength(CardsLogic.slotCount));
    expect(int.parse(result.cardNumber), inInclusiveRange(1, 100000));
    expect(result.headline, isNotEmpty);
    expect(result.message, isNotEmpty);
  });

  test('fortune builder combines score band and saju traits', () async {
    const BirthInput input = BirthInput(
      year: 1994,
      month: 11,
      day: 5,
      hour: 21,
      minute: 10,
      gender: '여성',
    );
    final fortune = await FortuneLogic.buildTodayFortune(
      SajuLogic.calculate(input),
      DateTime(2026, 3, 22),
    );

    expect(fortune.title, isNotEmpty);
    expect(fortune.message, isNotEmpty);
    expect(fortune.detailMessage, isNotEmpty);
    expect(fortune.overallLabel, isNotEmpty);
    expect(fortune.signals, isNotEmpty);
    expect(fortune.categoryScores.length, 4);
    expect(
      fortune.categoryScores.keys,
      containsAll(<String>['종합', '금전운', '애정운', '건강운']),
    );
    expect(fortune.categoryNarratives.length, 4);
    expect(fortune.categoryNarratives['금전운'], isNotEmpty);
    expect(fortune.focus, contains('행운색'));
  });

  test(
    'fortune builder can derive precise profile directly from birth input',
    () async {
      const BirthInput input = BirthInput(
        year: 1992,
        month: 10,
        day: 7,
        hour: 16,
        minute: 0,
        gender: '남성',
      );

      final fortune = await FortuneLogic.buildTodayFortuneFromBirth(
        input,
        DateTime(2026, 3, 24),
      );

      expect(fortune.signals, contains('병화 일간'));
      expect(
        fortune.signals.any(
          (String item) =>
              item.contains('신강') || item.contains('신약') || item.contains('중화'),
        ),
        isTrue,
      );
      expect(fortune.categoryScores['종합'], isNotNull);
      expect(fortune.categoryNarratives['애정운'], isNotEmpty);
    },
  );

  test('precise saju supports solar exact time input', () {
    const BirthInput input = BirthInput(
      year: 1992,
      month: 10,
      day: 7,
      hour: 16,
      minute: 0,
      gender: '남성',
    );
    const PreciseSajuInput preciseInput = PreciseSajuInput(
      calendarType: CalendarType.solar,
      timePrecision: TimePrecision.exact,
      exactHour: 16,
      exactMinute: 0,
    );

    final result = PreciseSajuLogic.calculate(input, preciseInput);

    expect(result.fourPillars, hasLength(4));
    expect(result.fourPillars.first.ganZhi, '壬申');
    expect(result.dayMaster, '병화');
    expect(result.strengthLabel, isNotEmpty);
    expect(result.chartSummary, contains('명식'));
    expect(result.mingGongLabel, contains('명궁'));
    expect(result.basisLabel, contains('양력'));
    expect(result.timingNote, contains('분 단위'));
  });

  test('precise saju supports lunar input flow', () {
    const BirthInput input = BirthInput(
      year: 1992,
      month: 10,
      day: 7,
      hour: 16,
      minute: 0,
      gender: '남성',
    );
    const PreciseSajuInput preciseInput = PreciseSajuInput(
      calendarType: CalendarType.lunar,
      isLeapMonth: false,
      timePrecision: TimePrecision.exact,
      exactHour: 16,
      exactMinute: 0,
    );

    final result = PreciseSajuLogic.calculate(input, preciseInput);

    expect(result.basisLabel, contains('음력'));
    expect(result.lunarLabel, contains('음력'));
    expect(result.solarLabel, contains('양력'));
    expect(result.taiYuanLabel, contains('태원'));
    expect(result.fourPillars.last.ganZhi, isNotEmpty);
  });

  test('precise saju marks branch mode as simplified reading', () {
    const BirthInput input = BirthInput(
      year: 1992,
      month: 10,
      day: 7,
      gender: '남성',
    );
    const PreciseSajuInput preciseInput = PreciseSajuInput(
      calendarType: CalendarType.solar,
      timePrecision: TimePrecision.branch,
      timeBranchSlot: TimeBranchSlot.shen,
    );

    final result = PreciseSajuLogic.calculate(input, preciseInput);

    expect(result.basisLabel, contains('간이 판독'));
    expect(result.timingNote, contains('간이 판독'));
    expect(result.shenGongLabel, contains('신궁'));
    expect(result.fourPillars.last.ganZhi, isNotEmpty);
  });

  test('default precise input follows stored birth precision', () {
    const BirthInput exactBirth = BirthInput(
      year: 1992,
      month: 10,
      day: 7,
      hour: 16,
      minute: 0,
      gender: '남성',
    );
    const BirthInput unknownTimeBirth = BirthInput(
      year: 1992,
      month: 10,
      day: 7,
      gender: '남성',
    );

    final exactInput = PreciseSajuInput.defaultForBirth(exactBirth);
    final branchInput = PreciseSajuInput.defaultForBirth(unknownTimeBirth);

    expect(exactInput.timePrecision, TimePrecision.exact);
    expect(branchInput.timePrecision, TimePrecision.branch);
  });

  test('always unlocked reward service keeps unlock API ready', () async {
    const AlwaysUnlockedRewardUnlockService service =
        AlwaysUnlockedRewardUnlockService();

    expect(await service.isUnlocked('sample-signature'), isTrue);
    expect(await service.requestUnlock('sample-signature'), isTrue);
    await service.clear('sample-signature');
  });
}
