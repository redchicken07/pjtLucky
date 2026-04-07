import '../models/birth_input.dart';
import '../models/precise_saju_input.dart';
import '../models/precise_saju_result.dart';
import '../models/saju_result.dart';
import 'precise_saju_logic.dart';

class SajuLogic {
  static const List<String> _stems = <String>[
    '갑',
    '을',
    '병',
    '정',
    '무',
    '기',
    '경',
    '신',
    '임',
    '계',
  ];

  static const List<String> _branches = <String>[
    '자',
    '축',
    '인',
    '묘',
    '진',
    '사',
    '오',
    '미',
    '신',
    '유',
    '술',
    '해',
  ];

  static const List<String> _animals = <String>[
    '쥐',
    '소',
    '호랑이',
    '토끼',
    '용',
    '뱀',
    '말',
    '양',
    '원숭이',
    '닭',
    '개',
    '돼지',
  ];

  static const List<String> _elements = <String>['목', '화', '토', '금', '수'];

  static const List<String> _seasons = <String>[
    '한겨울',
    '초봄',
    '봄',
    '늦봄',
    '초여름',
    '한여름',
    '늦여름',
    '초가을',
    '가을',
    '늦가을',
    '초겨울',
    '동절기',
  ];

  static const List<String> _monthFlows = <String>[
    '축월의 마무리 기운',
    '인월의 출발 기운',
    '묘월의 확장 기운',
    '진월의 전환 기운',
    '사월의 상승 기운',
    '오월의 발산 기운',
    '미월의 정리 기운',
    '신월의 수렴 기운',
    '유월의 절제 기운',
    '술월의 건조한 판단 기운',
    '해월의 잠복 기운',
    '자월의 응축 기운',
  ];

  static const List<String> _timeBlocks = <String>[
    '심야',
    '새벽',
    '아침',
    '오전',
    '정오',
    '오후',
    '저녁',
    '밤',
  ];

  static const Map<String, String> _luckyColors = <String, String>{
    '목': '청록',
    '화': '주황',
    '토': '황토',
    '금': '은백',
    '수': '남청',
  };

  static const Map<String, String> _elementTraits = <String, String>{
    '목': '배움과 확장을 붙잡는 선택',
    '화': '표현과 속도를 조절하는 감각',
    '토': '기반과 루틴을 단단히 다지는 태도',
    '금': '기준을 세우고 정리하는 판단',
    '수': '관찰과 정서를 깊게 읽는 집중',
  };

  static const Map<String, String> _supportElements = <String, String>{
    '목': '수',
    '화': '목',
    '토': '화',
    '금': '토',
    '수': '금',
  };

  static const Map<String, String> _balanceAdviceByElement = <String, String>{
    '목': '사람, 정보, 배움이 오가는 흐름을 열어 두는 편이 기본 기운을 살립니다.',
    '화': '표현은 살리되 속도를 너무 끌어올리지 않으면 기운이 더 오래 갑니다.',
    '토': '루틴, 공간, 일정처럼 손에 잡히는 질서를 세울수록 흐름이 안정됩니다.',
    '금': '기준을 정하고 선을 분명히 할수록 잡음이 줄고 판단이 선명해집니다.',
    '수': '혼자 정리하는 시간과 관찰의 여백을 두면 컨디션이 빠르게 회복됩니다.',
  };

  static const Map<String, String> _animalTraits = <String, String>{
    '쥐': '빠르게 흐름을 읽고 빈틈을 메우는 편',
    '소': '느리더라도 기준을 지키며 끝까지 버티는 편',
    '호랑이': '판을 넓게 보고 먼저 움직이려는 편',
    '토끼': '관계를 부드럽게 읽고 타이밍을 고르는 편',
    '용': '큰 흐름을 만들고 중심을 잡으려는 편',
    '뱀': '숨은 의도와 패턴을 먼저 포착하는 편',
    '말': '속도감 있게 밀고 나가며 분위기를 바꾸는 편',
    '양': '감정의 결을 살피고 조화를 만드는 편',
    '원숭이': '상황에 맞게 전략을 빠르게 바꾸는 편',
    '닭': '디테일과 순서를 분명하게 세우는 편',
    '개': '신뢰와 책임을 우선으로 두는 편',
    '돼지': '여유를 만들며 큰 흐름을 편하게 끌고 가는 편',
  };

  static const Map<String, String> _yinYangTraits = <String, String>{
    '양': '밖으로 드러내고 먼저 제안하는 추진',
    '음': '안으로 응축하고 정리하는 집중',
  };

  static const Map<String, String> _headlines = <String, String>{
    '목-양': '밖으로 뻗는 힘이 강한 개척형',
    '목-음': '겉은 조용하지만 판을 키우는 성장형',
    '화-양': '존재감과 추진력이 선명한 발산형',
    '화-음': '겉은 차분해도 안쪽 열기가 강한 응축형',
    '토-양': '중심을 잡으며 판을 이끄는 안정형',
    '토-음': '천천히 쌓아 큰 결과를 만드는 축적형',
    '금-양': '판단이 빠르고 기준이 분명한 결단형',
    '금-음': '디테일과 균형감이 살아 있는 정리형',
    '수-양': '흐름을 읽고 기민하게 움직이는 탐색형',
    '수-음': '관찰력과 내면 집중이 깊은 잠행형',
  };

  static const Map<String, String> _surfaceReadings = <String, String>{
    '쥐': '겉으로는 눈치가 빠르고 흐름을 먼저 읽는 편이라, 상황 파악이 빠른 사람으로 보이기 쉽습니다.',
    '소': '겉으로는 묵직하고 말수가 적어 보여도, 한 번 맡은 일은 쉽게 흔들리지 않는 인상으로 남습니다.',
    '호랑이': '겉으로는 추진력과 배짱이 먼저 보여, 주도권을 잡는 사람처럼 읽히기 쉽습니다.',
    '토끼': '겉으로는 부드럽고 조심스러워 보이지만, 사람 사이의 미묘한 결을 빠르게 읽는 편입니다.',
    '용': '겉으로는 스케일이 크고 자신감이 있는 편으로 보이며, 중심을 잡는 역할을 자주 맡게 됩니다.',
    '뱀': '겉으로는 차분하고 말수가 적어 보여도, 속으로는 상황의 숨은 의도를 빠르게 계산하는 편입니다.',
    '말': '겉으로는 반응 속도가 빠르고 생기가 있어, 분위기를 바꾸는 사람처럼 비치는 경우가 많습니다.',
    '양': '겉으로는 부드럽고 감각적인 편으로 읽히며, 상대의 기분과 분위기를 살피는 힘이 있습니다.',
    '원숭이': '겉으로는 눈치가 빠르고 유연해 보여, 말이나 태도를 상황에 맞게 바꿀 줄 아는 사람처럼 보입니다.',
    '닭': '겉으로는 기준이 분명하고 깔끔한 인상을 주며, 정리와 순서를 중시하는 편으로 읽힙니다.',
    '개': '겉으로는 의리와 책임감이 강한 사람처럼 보이고, 신뢰를 잃지 않으려는 태도가 먼저 드러납니다.',
    '돼지': '겉으로는 여유롭고 무던해 보여도, 큰 흐름을 편하게 끌고 가는 힘이 있는 편입니다.',
  };

  static const Map<String, String> _innerReadings = <String, String>{
    '목-양':
        '내면에는 한 번 방향을 정하면 바로 뻗어 나가고 싶은 힘이 큽니다. 새로운 판을 열거나 사람을 끌어들이는 데 에너지가 실리는 편입니다.',
    '목-음':
        '내면에는 겉으로 드러나지 않게 판을 넓히고 싶어 하는 욕구가 있습니다. 조용히 준비해 두었다가 기회가 오면 길게 가져가는 타입에 가깝습니다.',
    '화-양': '내면에는 인정 욕구와 승부욕이 강하게 작동해, 기회가 오면 존재감을 분명히 남기고 싶어 하는 쪽입니다.',
    '화-음': '내면에는 열기와 감수성이 함께 있어, 평소엔 차분해 보여도 한번 불이 붙으면 스스로를 강하게 몰아붙이기 쉽습니다.',
    '토-양':
        '내면에는 판을 안정시키고 중심을 잡고 싶어 하는 마음이 큽니다. 사람이나 일의 균형이 무너지면 금방 신경이 쓰이는 편입니다.',
    '토-음': '내면에는 서두르지 않고 실속 있게 쌓아 두려는 힘이 있습니다. 느려 보여도 결과를 남기는 쪽에 가깝습니다.',
    '금-양': '내면에는 빠르게 판단하고 끊어낼 것은 끊고 싶은 성향이 강합니다. 기준이 흐려지면 오히려 피로가 커질 수 있습니다.',
    '금-음': '내면에는 완성도를 올리고 싶어 하는 민감함이 큽니다. 디테일이 맞아떨어질 때 심리적으로 가장 안정됩니다.',
    '수-양': '내면에는 넓게 탐색하고 흐름을 먼저 읽고 싶은 힘이 있습니다. 답이 바로 안 보여도 가능성을 오래 추적하는 편입니다.',
    '수-음': '내면에는 감정과 생각을 깊게 응축하는 힘이 있어, 한 번 마음에 걸린 문제를 오래 곱씹는 편입니다.',
  };

  static const Map<String, String> _workReadings = <String, String>{
    '목':
        '일에서는 사람, 정보, 아이디어가 오가는 자리에서 강점이 드러납니다. 다만 방향만 넓히고 정리를 미루면 힘이 분산될 수 있습니다.',
    '화':
        '일에서는 속도가 붙고 주목도가 올라갈 때 성과가 커집니다. 대신 감정이 먼저 타오르면 판단이 빨라져 중간 점검이 꼭 필요합니다.',
    '토': '일에서는 기반을 다지고 순서를 세우는 역할에서 강합니다. 큰 성과도 결국 루틴과 구조를 잡을 때 나옵니다.',
    '금': '일에서는 기준을 세우고 정리하는 능력이 강점입니다. 애매한 판보다 규칙이 분명한 환경에서 실력이 더 잘 드러납니다.',
    '수':
        '일에서는 분석, 관찰, 흐름 읽기가 필요한 자리에서 힘이 납니다. 즉답을 강요받는 환경보다는 생각할 여지가 있을 때 더 강합니다.',
  };

  static const Map<String, String> _relationshipReadings = <String, String>{
    '양':
        '관계에서는 마음이 움직이면 먼저 손을 내미는 편입니다. 다만 기대가 컸던 만큼 반응이 미지근하면 서운함도 빠르게 올라올 수 있습니다.',
    '음':
        '관계에서는 처음부터 속내를 다 보이기보다 천천히 거리를 재는 편입니다. 한번 신뢰가 생기면 깊지만, 마음이 틀어지면 오래 묵히기 쉽습니다.',
  };

  static SajuResult calculate(
    BirthInput input, {
    PreciseSajuResult? preciseResult,
  }) {
    final int hour = input.resolvedHour;
    final int minute = input.resolvedMinute;
    final int seasonIndex = _seasonIndex(input.month);
    final int timeBlockIndex = _timeBlockIndex(hour, minute);
    final PreciseSajuResult precise =
        preciseResult ??
        PreciseSajuLogic.calculate(
          input,
          PreciseSajuInput.defaultForBirth(input),
        );
    final int lifeNumber = _reduceToSingleDigit(
      input.year + input.month + input.day,
    );
    final int baseSeed =
        (input.year * 13) +
        (input.month * 17) +
        (input.day * 19) +
        (hour * 23) +
        (minute * 29) +
        (lifeNumber * 31);
    final String animal = _animals[(input.year - 4) % _animals.length];
    final String element = precise.dayMasterElement;
    final String yinYang = _yinYangFromDayMaster(precise.dayMaster);
    final int genderBias = switch (input.gender) {
      '남성' => 9,
      '여성' => 5,
      _ => 7,
    };
    final int energyScore = _energyScoreFromPrecise(
      precise: precise,
      baseSeed: baseSeed,
      genderBias: genderBias,
      lifeNumber: lifeNumber,
    );
    final String supportElement = _supportElementFromPrecise(
      dayMasterElement: element,
      weakestElement: precise.weakestElement,
    );
    final String luckyColor =
        _luckyColors[supportElement] ?? _luckyColors[element] ?? '담백한 색';
    final String yearPillar = precise.fourPillars.isNotEmpty
        ? precise.fourPillars.first.reading
        : _yearPillar(input.year);
    final String season = _seasons[seasonIndex];
    final String monthFlow = _monthFlowFromPrecise(precise, seasonIndex);
    final String timeTone = _timeBlocks[timeBlockIndex];
    final String timeBranch = input.hasKnownTime
        ? '${precise.fourPillars.last.reading} 시주'
        : input.hasBranchTime
        ? '${input.timeBranchSlot?.label ?? '시지'} 기준'
        : '시간 미상';
    final String animalTrait = _animalTraits[animal] ?? '흐름을 잘 읽는 편';
    final String elementTrait = _elementTraits[element] ?? '흐름을 부드럽게 잇는 감각';
    final String yinYangTrait = _yinYangTraits[yinYang] ?? '균형 감각';
    final String profileKey = '$element-$yinYang';
    final String headline =
        '${precise.dayMaster} 일간의 ${_headlines[profileKey] ?? '균형을 잡아 가는 실전형'}';
    final String surfaceReading =
        '${_surfaceReadings[animal] ?? '겉으로는 흐름을 잘 읽는 편으로 보입니다.'} '
        '겉으로 드러나는 결은 $yearPillar 연주와 $monthFlow 쪽이 먼저 살아, '
        '${precise.dominantTenGod} 성향의 기준감과 반응 속도가 표면에서 읽히기 쉽습니다.';
    final String innerReading =
        '${_innerReadings[profileKey] ?? '내면에는 쉽게 드러나지 않는 집중력이 있습니다.'} '
        '${_strengthSentence(precise)} '
        '${precise.dominantElement} 기운이 먼저 서고 $supportElement 쪽 보완이 들어와야 전체 균형이 무너지지 않습니다.';
    final String workReading =
        '${_workReadings[element] ?? '일에서는 기본기를 쌓을수록 힘이 살아납니다.'} '
        '월간은 ${precise.monthTenGod}으로 읽혀, ${_trimTrailingPeriod(precise.workNarrative)}';
    final String relationshipReading =
        '${_relationshipReadings[yinYang] ?? '관계에서는 천천히 결을 맞추는 편입니다.'} '
        '시주 쪽은 ${precise.timeTenGod} 결이 깔려 있어, ${_trimTrailingPeriod(precise.relationshipNarrative)}';
    final String balanceAdvice =
        '${_balanceAdviceByElement[supportElement] ?? '리듬을 급하게 끊지 않는 편이 좋습니다.'} '
        '${_trimTrailingPeriod(precise.riskNarrative)}';
    final String timePhrase = input.hasKnownTime
        ? '$timeTone 기운과 $timeBranch 흐름이 더해져'
        : input.hasBranchTime
        ? '${input.timeBranchSlot?.label ?? '시지'} 구간 흐름을 기준으로 읽으면'
        : '태어난 시간이 없어 시주는 정오 기준의 간이 흐름으로 읽으면';

    return SajuResult(
      animal: animal,
      element: element,
      dominantElement: precise.dominantElement,
      yinYang: yinYang,
      lifeNumber: lifeNumber,
      energyScore: energyScore,
      luckyColor: luckyColor,
      yearPillar: yearPillar,
      monthFlow: monthFlow,
      timeBranch: timeBranch,
      dayMaster: precise.dayMaster,
      strengthLabel: precise.strengthLabel,
      dominantTenGod: precise.dominantTenGod,
      monthTenGod: precise.monthTenGod,
      timeTenGod: precise.timeTenGod,
      supportElement: supportElement,
      headline: headline,
      surfaceReading: surfaceReading,
      innerReading: innerReading,
      workReading: workReading,
      relationshipReading: relationshipReading,
      balanceAdvice: balanceAdvice,
      summary:
          '$headline에 가까운 결을 가지고 있습니다. '
          '$season 기운 위에 $animal 성향이 겹치고, $timePhrase $yinYangTrait이 먼저 움직입니다. '
          '빠른 요약 기준으로는 연주 $yearPillar, 월 흐름 $monthFlow, 일간 ${precise.dayMaster}, '
          '오행은 ${precise.dominantElement} 쪽이 먼저 서고 $supportElement 보완이 중요합니다. '
          '$elementTrait을 살리되 ${_trimTrailingPeriod(precise.chartSummary)} '
          '기본 성향은 $animalTrait 쪽에 가깝습니다.',
    );
  }

  static int _seasonIndex(int month) {
    return month.clamp(1, 12) - 1;
  }

  static String _yearPillar(int year) {
    final int stemIndex = (year - 4) % _stems.length;
    final int branchIndex = (year - 4) % _branches.length;
    return '${_stems[stemIndex]}${_branches[branchIndex]}';
  }

  static int _timeBlockIndex(int hour, int minute) {
    final int totalMinutes = (hour.clamp(0, 23) * 60) + minute.clamp(0, 59);
    return (totalMinutes ~/ 180) % _timeBlocks.length;
  }

  static String _yinYangFromDayMaster(String dayMaster) {
    final String stem = dayMaster.isEmpty ? '무' : dayMaster.substring(0, 1);
    return switch (stem) {
      '갑' || '병' || '무' || '경' || '임' => '양',
      _ => '음',
    };
  }

  static int _energyScoreFromPrecise({
    required PreciseSajuResult precise,
    required int baseSeed,
    required int genderBias,
    required int lifeNumber,
  }) {
    final int presentElements = _elements
        .where((String item) => (precise.elementBalance[item] ?? 0) > 0)
        .length;
    final int weaknessPenalty =
        (precise.elementBalance[precise.weakestElement] ?? 0) == 0 ? 6 : 2;
    final int strengthBias = switch (precise.strengthLabel) {
      '중화' => 12,
      '중화에 가까운 신강' || '중화에 가까운 신약' => 8,
      '신강' => 5,
      '신약' => -3,
      _ => 0,
    };
    final int base =
        46 + (presentElements * 6) + strengthBias - weaknessPenalty;
    final int wave = ((baseSeed + genderBias + (lifeNumber * 7)) % 11) - 5;
    return (base + wave).clamp(28, 92);
  }

  static String _supportElementFromPrecise({
    required String dayMasterElement,
    required String weakestElement,
  }) {
    if (weakestElement != dayMasterElement) {
      return weakestElement;
    }
    return _supportElements[dayMasterElement] ?? weakestElement;
  }

  static String _monthFlowFromPrecise(
    PreciseSajuResult precise,
    int seasonIndex,
  ) {
    final String fallback = _monthFlows[seasonIndex];
    if (precise.fourPillars.length < 2) {
      return fallback;
    }
    final String monthReading = precise.fourPillars[1].reading;
    final String monthWuXing = precise.fourPillars[1].wuXing;
    return '$monthReading 월령의 $monthWuXing 흐름';
  }

  static String _strengthSentence(PreciseSajuResult precise) {
    return switch (precise.strengthLabel) {
      '신강' => '기본 기세가 쉽게 눌리지 않아 자기 판단을 밀고 가는 힘이 분명합니다.',
      '중화에 가까운 신강' => '자기 기운이 쉽게 꺼지지 않아 판이 열리면 먼저 중심을 잡으려는 흐름이 있습니다.',
      '중화' => '강약이 한쪽으로 크게 치우치지 않아, 상황에 따라 움직임의 결이 달라지는 편입니다.',
      '중화에 가까운 신약' => '완전한 신약은 아니지만 주변 기운의 압박을 먼저 느끼기 쉬워 예열이 필요한 편입니다.',
      '신약' => '주변 환경과 계절의 압박을 먼저 체감하기 쉬워, 리듬과 회복을 잘 챙겨야 힘이 오래 갑니다.',
      _ => '기세의 강약은 상황과 타이밍에 따라 달라질 여지가 있습니다.',
    };
  }

  static String _trimTrailingPeriod(String text) {
    return text.trim().replaceFirst(RegExp(r'[.。]\s*$'), '');
  }

  static int _reduceToSingleDigit(int number) {
    int current = number.abs();
    while (current > 9) {
      final String digits = current.toString();
      current = digits
          .split('')
          .map(int.parse)
          .fold<int>(0, (int sum, int value) => sum + value);
    }
    return current == 0 ? 1 : current;
  }
}
