import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/birth_input.dart';
import '../models/fortune_result.dart';
import '../models/precise_saju_input.dart';
import '../models/precise_saju_result.dart';
import '../models/saju_result.dart';
import '../utils/date_utils.dart';
import 'precise_saju_logic.dart';
import 'saju_logic.dart';

class FortuneLogic {
  static const List<String> _categoryOrder = <String>[
    '종합',
    '금전운',
    '애정운',
    '건강운',
  ];

  static Map<String, dynamic>? _catalog;

  static Future<FortuneResult> buildTodayFortuneFromBirth(
    BirthInput birthInput,
    DateTime now,
  ) async {
    final PreciseSajuInput preciseInput = PreciseSajuInput.defaultForBirth(
      birthInput,
    );
    final PreciseSajuResult precise = PreciseSajuLogic.calculate(
      birthInput,
      preciseInput,
    );
    final SajuResult quick = SajuLogic.calculate(
      birthInput,
      preciseResult: precise,
    );
    return _buildTodayFortuneInternal(
      quick: quick,
      precise: precise,
      now: now,
      birthInput: birthInput,
    );
  }

  static Future<FortuneResult> buildTodayFortune(
    SajuResult saju,
    DateTime now,
  ) async {
    return _buildTodayFortuneInternal(
      quick: saju,
      precise: null,
      now: now,
      birthInput: null,
    );
  }

  static Future<FortuneResult> _buildTodayFortuneInternal({
    required SajuResult quick,
    required DateTime now,
    required BirthInput? birthInput,
    PreciseSajuResult? precise,
  }) async {
    final Map<String, dynamic> catalog = await _loadCatalog();
    final List<Map<String, dynamic>> scoreBands = _readMapList(
      catalog['scoreBands'],
    );
    final Map<String, dynamic> elementMessages = _readMap(
      catalog['elementMessages'],
    );
    final Map<String, dynamic> yinYangMessages = _readMap(
      catalog['yinYangMessages'],
    );
    final Map<String, dynamic> lifeNumberMessages = _readMap(
      catalog['lifeNumberMessages'],
    );
    final Map<String, dynamic> animalMessages = _readMap(
      catalog['animalMessages'],
    );

    final Map<String, int> categoryScores = _buildCategoryScores(
      quick: quick,
      precise: precise,
      now: now,
    );
    final int score = _overallScore(categoryScores, quick, precise, now);
    final Map<String, dynamic> selectedBand = scoreBands.firstWhere((
      Map<String, dynamic> entry,
    ) {
      final int minScore = _asInt(entry['minScore']);
      final int maxScore = _asInt(entry['maxScore']);
      return score >= minScore && score <= maxScore;
    }, orElse: () => scoreBands.last);

    final String overallLabel = _lookupText(selectedBand, 'overallLabel', '무난');
    final String title = '오늘의 종합운은 $overallLabel 입니다';
    final String message = precise == null
        ? <String>[
            _lookupText(
              selectedBand,
              'message',
              '오늘은 크게 무리하지 않는 선에서 리듬을 잡는 편이 좋습니다.',
            ),
            _lookupText(
              elementMessages,
              quick.element,
              '자기 강점을 반복해서 쓰는 쪽이 유리합니다.',
            ),
          ].join(' ')
        : <String>[
            _lookupText(
              selectedBand,
              'message',
              '오늘은 크게 무리하지 않는 선에서 리듬을 잡는 편이 좋습니다.',
            ),
            _strengthTodayMessage(precise),
            _todayAxisMessage(precise),
          ].join(' ');

    final String detailMessage = precise == null
        ? <String>[
            _lookupText(
              yinYangMessages,
              quick.yinYang,
              '마음의 속도와 실제 움직임의 간격을 조절해 보세요.',
            ),
            _lookupText(
              animalMessages,
              quick.animal,
              '지금은 자기 리듬을 먼저 지키는 편이 낫습니다.',
            ),
            _lookupText(
              lifeNumberMessages,
              quick.lifeNumber.toString(),
              '작은 루틴 하나를 지키면 흐름이 정돈됩니다.',
            ),
          ].join(' ')
        : <String>[
            precise.chartSummary,
            _categoryFocusNarrative(categoryScores, precise),
          ].join(' ');

    final String focus = precise == null
        ? <String>[
            _lookupText(selectedBand, 'focus', '속도 조절'),
            '행운색 ${quick.luckyColor}',
          ].join(' · ')
        : <String>[
            _lookupText(selectedBand, 'focus', '속도 조절'),
            '${precise.dayMaster} 일간',
            '${precise.dominantTenGod} 결',
            '행운색 ${quick.luckyColor}',
          ].join(' · ');
    final Map<String, String> categoryNarratives = _buildCategoryNarratives(
      quick: quick,
      precise: precise,
      categoryScores: categoryScores,
      now: now,
    );
    final ({List<int> numbers, String headline, String message}) luckyNumbers =
        _buildLuckyNumbers(
          birthInput: birthInput,
          quick: quick,
          precise: precise,
          score: score,
          now: now,
        );

    return FortuneResult(
      dateKey: AppDateUtils.dayKey(now),
      score: score,
      overallLabel: overallLabel,
      title: title,
      message: message,
      detailMessage: detailMessage,
      focus: focus,
      signals: _buildSignals(quick: quick, precise: precise),
      categoryScores: categoryScores,
      categoryNarratives: categoryNarratives,
      luckyNumbers: luckyNumbers.numbers,
      luckyNumbersHeadline: luckyNumbers.headline,
      luckyNumbersMessage: luckyNumbers.message,
    );
  }

  static Map<String, int> _buildCategoryScores({
    required SajuResult quick,
    required DateTime now,
    PreciseSajuResult? precise,
  }) {
    final Map<String, int> scores = <String, int>{};
    for (final String category in _categoryOrder) {
      final int seed = _stableHash(
        '$category-${AppDateUtils.dayKey(now)}-${precise?.dayMaster ?? quick.element}-${precise?.strengthLabel ?? quick.yinYang}-${precise?.dominantTenGod ?? quick.animal}',
      );
      final int dailyOffset = (seed % 25) - 12;
      final int base = quick.energyScore + _categoryBase(category, quick);
      final int preciseBias = precise == null
          ? 0
          : _preciseCategoryBias(category, precise);
      final int mixed = (base + dailyOffset + preciseBias).clamp(26, 94);
      scores[category] = mixed;
    }
    return scores;
  }

  static int _overallScore(
    Map<String, int> categoryScores,
    SajuResult quick,
    PreciseSajuResult? precise,
    DateTime now,
  ) {
    final int average =
        categoryScores.values.fold<int>(0, (int sum, int item) => sum + item) ~/
        categoryScores.length;
    final int dailyWave =
        (_stableHash(
              'overall-${AppDateUtils.dayKey(now)}-${precise?.dayMaster ?? quick.element}-${precise?.strengthLabel ?? quick.yinYang}',
            ) %
            9) -
        4;
    return (average + dailyWave).clamp(0, 99);
  }

  static int _categoryBase(String category, SajuResult saju) {
    return switch (category) {
      '종합' => 8,
      '금전운' => saju.element == '금' || saju.element == '토' ? 12 : 6,
      '애정운' => saju.yinYang == '음' ? 10 : 4,
      '건강운' => saju.supportElement == '수' ? 9 : 6,
      _ => 0,
    };
  }

  static int _preciseCategoryBias(String category, PreciseSajuResult precise) {
    return switch (category) {
      '종합' => _overallBias(precise),
      '금전운' => _moneyBias(precise),
      '애정운' => _relationshipBias(precise),
      '건강운' => _healthBias(precise),
      _ => 0,
    };
  }

  static int _overallBias(PreciseSajuResult precise) {
    int bias = switch (precise.strengthLabel) {
      '중화' => 8,
      '중화에 가까운 신강' || '중화에 가까운 신약' => 4,
      '신강' => 1,
      '신약' => -3,
      _ => 0,
    };
    if (_weakCount(precise) == 0) {
      bias -= 4;
    }
    if (precise.dominantElement == precise.dayMasterElement) {
      bias += 2;
    }
    return bias;
  }

  static int _relationshipBias(PreciseSajuResult precise) {
    int bias = switch (precise.timeTenGod) {
      '정재' || '편재' => 8,
      '정인' || '편인' || '식신' => 5,
      '비견' || '정관' => 2,
      '상관' => -2,
      '겁재' => -3,
      '칠살' => -4,
      _ => 0,
    };
    if (precise.strengthLabel == '신약') {
      bias -= 2;
    }
    if (_weakCount(precise) == 0) {
      bias -= 2;
    }
    return bias;
  }

  static int _moneyBias(PreciseSajuResult precise) {
    int bias = switch (precise.dominantTenGod) {
      '정재' || '편재' => 10,
      '식신' || '상관' => 4,
      '정관' || '칠살' => 2,
      _ => 0,
    };
    if (precise.dominantElement == '금' || precise.dominantElement == '토') {
      bias += 3;
    }
    if (precise.weakestElement == '금' && _weakCount(precise) <= 1) {
      bias -= 4;
    }
    return bias;
  }

  static int _healthBias(PreciseSajuResult precise) {
    int bias = switch (precise.strengthLabel) {
      '중화' => 7,
      '중화에 가까운 신강' || '중화에 가까운 신약' => 3,
      '신강' => 1,
      '신약' => -5,
      _ => 0,
    };
    if (_weakCount(precise) == 0) {
      bias -= 5;
    }
    return bias;
  }

  static int _weakCount(PreciseSajuResult precise) {
    return precise.elementBalance[precise.weakestElement] ?? 0;
  }

  static List<String> _buildSignals({
    required SajuResult quick,
    PreciseSajuResult? precise,
  }) {
    if (precise == null) {
      return <String>[
        '간이 명리 기반',
        quick.yearPillar,
        '${quick.element} 기운',
        '${quick.yinYang} 흐름',
      ];
    }

    return <String>[
      precise.basisLabel,
      '${precise.dayMaster} 일간',
      precise.strengthLabel,
      '${precise.dominantElement} 강',
      _weakCount(precise) == 0
          ? '${precise.weakestElement} 부족'
          : '${precise.weakestElement} 약',
      '${precise.dominantTenGod} 반복',
    ];
  }

  static Map<String, String> _buildCategoryNarratives({
    required SajuResult quick,
    required Map<String, int> categoryScores,
    required DateTime now,
    PreciseSajuResult? precise,
  }) {
    return <String, String>{
      '종합': _overallNarrative(
        score: categoryScores['종합'] ?? 0,
        quick: quick,
        precise: precise,
        now: now,
      ),
      '금전운': _moneyNarrative(
        score: categoryScores['금전운'] ?? 0,
        quick: quick,
        precise: precise,
        now: now,
      ),
      '애정운': _relationshipNarrative(
        score: categoryScores['애정운'] ?? 0,
        quick: quick,
        precise: precise,
        now: now,
      ),
      '건강운': _healthNarrative(
        score: categoryScores['건강운'] ?? 0,
        quick: quick,
        precise: precise,
        now: now,
      ),
    };
  }

  static String _strengthTodayMessage(PreciseSajuResult precise) {
    return switch (precise.strengthLabel) {
      '신강' => '오늘은 자기 판단이 너무 강해지지 않게 속도를 조절하면 결과가 더 안정됩니다.',
      '중화에 가까운 신강' => '오늘은 밀어붙일 힘은 충분하지만, 한 번 더 정리한 뒤 움직일수록 손실이 줄어듭니다.',
      '중화' => '오늘은 기세가 한쪽으로 치우치지 않아, 순서만 잘 잡으면 여러 일을 무난하게 풀 수 있습니다.',
      '중화에 가까운 신약' => '오늘은 초반 페이스를 급하게 끌어올리기보다 흐름을 읽고 몸을 맞추는 편이 유리합니다.',
      '신약' => '오늘은 기세보다 리듬 관리가 먼저입니다. 무리한 승부보다 판을 가볍게 정리하는 쪽이 더 좋습니다.',
      _ => '오늘은 리듬과 균형을 먼저 챙기는 편이 좋습니다.',
    };
  }

  static String _todayAxisMessage(PreciseSajuResult precise) {
    return '${precise.dayMaster} 일간에 ${precise.monthTenGod}과 ${precise.timeTenGod} 흐름이 함께 걸려 있어, 오늘은 ${_todayActionByTenGod(precise)}';
  }

  static String _todayActionByTenGod(PreciseSajuResult precise) {
    return switch (precise.dominantTenGod) {
      '정재' || '편재' => '현실적인 판단과 이해득실 계산이 평소보다 더 선명하게 작동할 수 있습니다.',
      '식신' || '상관' => '생각을 밖으로 꺼내고 손으로 굴리는 과정에서 흐름이 풀릴 가능성이 큽니다.',
      '정인' || '편인' => '급히 결론 내기보다 자료를 보고 정리하는 시간이 결과를 더 좋게 만듭니다.',
      '정관' || '칠살' => '기준과 책임이 분명한 일에 집중할수록 오히려 심리가 안정되기 쉽습니다.',
      _ => '자기 기준과 거리 조절을 동시에 챙기는 편이 전체 리듬을 더 살립니다.',
    };
  }

  static String _categoryFocusNarrative(
    Map<String, int> categoryScores,
    PreciseSajuResult precise,
  ) {
    final MapEntry<String, int> top = categoryScores.entries.reduce(
      (MapEntry<String, int> current, MapEntry<String, int> next) =>
          next.value > current.value ? next : current,
    );
    final MapEntry<String, int> bottom = categoryScores.entries.reduce(
      (MapEntry<String, int> current, MapEntry<String, int> next) =>
          next.value < current.value ? next : current,
    );
    return '오늘 카테고리 흐름으로는 ${top.key} 쪽이 가장 앞에 서고, ${bottom.key} 쪽은 조금 더 신중하게 가져가는 편이 좋습니다. '
        '명식 기준으로는 ${precise.dominantElement} 기운과 ${precise.dominantTenGod} 결이 먼저 움직이므로, 강점을 밀어붙이되 ${precise.weakestElement} 쪽 과소모는 피하는 편이 좋습니다.';
  }

  static String _overallNarrative({
    required int score,
    required SajuResult quick,
    required DateTime now,
    PreciseSajuResult? precise,
  }) {
    final String pace = switch (_scoreLabelKey(score)) {
      '강세' => '전체 리듬이 위로 붙는 날이라, 결정을 미루기보다 먼저 잡은 흐름을 확장하는 편이 좋습니다.',
      '상승' => '큰 무리만 하지 않으면 손을 뻗은 일에서 반응이 따라오기 쉬운 흐름입니다.',
      '무난' => '눈에 띄는 반전보다는 기존 흐름을 정리하고 균형을 맞추는 쪽에서 안정감이 생깁니다.',
      '유의' => '하고 싶은 일과 실제 상황 사이에 간격이 생길 수 있어, 속도보다 순서를 먼저 챙기는 편이 좋습니다.',
      _ => '오늘은 판을 키우기보다 지키는 쪽에 힘을 실어야 손실을 줄일 수 있습니다.',
    };
    if (precise == null) {
      return '$pace ${quick.element} 기운이 먼저 움직이는 날이니, ${quick.balanceAdvice}';
    }
    return '$pace ${precise.dayMaster} 일간에 ${precise.strengthLabel} 흐름이 겹쳐 있어, '
        '${precise.dominantElement} 쪽 강점은 살리되 ${precise.weakestElement} 과소모는 피하는 편이 좋습니다.';
  }

  static String _moneyNarrative({
    required int score,
    required SajuResult quick,
    required DateTime now,
    PreciseSajuResult? precise,
  }) {
    final String core = switch (_scoreLabelKey(score)) {
      '강세' =>
        '금전운은 들어오고 나가는 흐름을 동시에 잡기 좋은 쪽입니다. 급하게 써야 할 일도 비교적 통제 범위 안에 두기 쉽습니다.',
      '상승' => '현실적인 계산이 잘 맞는 편이라, 오늘은 애매한 지출보다 목적이 분명한 선택이 더 유리합니다.',
      '무난' => '큰 이익을 노리기보다 새는 부분만 막아도 충분히 괜찮은 결과를 만들 수 있습니다.',
      '유의' =>
        '당장 작은 금액이라고 쉽게 넘기면 누수가 쌓일 수 있으니, 오늘은 기준 가격과 우선순위를 먼저 보는 편이 좋습니다.',
      _ => '금전운은 공격보다 방어가 우선입니다. 기분 따라 움직이는 소비나 성급한 판단은 피하는 편이 좋습니다.',
    };
    if (precise == null) {
      return '$core ${quick.element == '금' || quick.element == '토' ? '현실 감각은 살아 있으니' : '감으로만 판단하지 말고'} 최종 확정 전에 한 번 더 계산을 맞추는 편이 좋습니다.';
    }
    return '$core 명식상 ${precise.dominantTenGod} 결과 ${precise.dominantElement} 축이 재물 판단에 먼저 개입하므로, '
        '${precise.dominantTenGod == '정재' || precise.dominantTenGod == '편재' ? '기회 포착과 실속 계산을 같이 챙기면 흐름이 좋아질 수 있습니다.' : '숫자와 조건을 확인한 뒤 움직여야 손실을 줄일 수 있습니다.'}';
  }

  static String _relationshipNarrative({
    required int score,
    required SajuResult quick,
    required DateTime now,
    PreciseSajuResult? precise,
  }) {
    final String core = switch (_scoreLabelKey(score)) {
      '강세' => '애정운은 마음이 오가는 흐름이 비교적 부드러운 편입니다. 평소보다 먼저 말을 꺼내도 부담이 덜할 수 있습니다.',
      '상승' => '가볍게 던진 말이나 반응이 생각보다 좋은 신호로 이어질 수 있어, 타이밍을 너무 늦추지 않는 편이 좋습니다.',
      '무난' => '관계는 큰 기복 없이 흘러가지만, 먼저 기대를 키우기보다 상대 호흡을 맞춰 가는 쪽이 더 안정적입니다.',
      '유의' => '작은 서운함이나 말투 차이가 예상보다 오래 남을 수 있어, 감정 정리를 하고 말하는 편이 낫습니다.',
      _ => '애정운은 속도보다 거리 조절이 중요합니다. 오늘은 억지로 결론을 내리기보다 분위기를 읽는 편이 좋습니다.',
    };
    if (precise == null) {
      return '$core ${quick.relationshipReading}';
    }
    return '$core 가까운 관계를 보는 흐름이 ${precise.timeTenGod} 쪽에 치우쳐 있어, '
        '${precise.timeTenGod == '비견' || precise.timeTenGod == '상관' || precise.timeTenGod == '겁재' ? '자존심이 먼저 움직이지 않게 한 박자 늦추는 편이 좋습니다.' : '상대 반응을 확인하면서 천천히 깊이를 더하는 편이 유리합니다.'}';
  }

  static String _healthNarrative({
    required int score,
    required SajuResult quick,
    required DateTime now,
    PreciseSajuResult? precise,
  }) {
    final String core = switch (_scoreLabelKey(score)) {
      '강세' => '건강운은 회복력이 비교적 안정적인 편이라, 기본 리듬만 깨지지 않으면 컨디션을 유지하기 좋습니다.',
      '상승' => '몸이 완전히 가볍지는 않아도 생활 리듬을 잘 맞추면 피로가 오래 남지 않는 흐름입니다.',
      '무난' => '건강운은 무난하지만 무리한 일정이 겹치면 바로 티가 날 수 있으니, 쉬는 타이밍은 챙기는 편이 좋습니다.',
      '유의' =>
        '누적 피로나 수면 리듬 흔들림이 컨디션에 바로 반영되기 쉬운 날이라, 오늘은 회복 시간을 의식적으로 확보해야 합니다.',
      _ => '건강운은 강하게 밀어붙이기보다 몸 신호를 먼저 읽는 편이 중요합니다. 일정 과밀과 감정 소모를 줄여야 합니다.',
    };
    if (precise == null) {
      return '$core ${quick.supportElement} 쪽 보완 흐름을 살리는 생활 패턴이 도움이 됩니다.';
    }
    return '$core 명식 기준으로 ${precise.weakestElement} 쪽이 약점으로 작동하기 쉬워, '
        '${precise.weakestElement == '수'
            ? '휴식과 수면 리듬이 무너지지 않게 챙기는 편이 우선입니다.'
            : precise.weakestElement == '화'
            ? '열과 집중의 과소모를 줄이고 체력 배분을 먼저 보는 편이 좋습니다.'
            : precise.weakestElement == '토'
            ? '식사, 소화, 생활 루틴처럼 바닥 리듬을 먼저 잡아야 흔들림이 줄어듭니다.'
            : precise.weakestElement == '금'
            ? '긴장 누적과 예민함이 올라오기 쉬우니 과하게 날 선 상태를 오래 끌지 않는 편이 좋습니다.'
            : '시작부터 무리하게 에너지를 끌어올리지 말고 천천히 몸을 데우는 편이 더 안정적입니다.'}';
  }

  static String _scoreLabelKey(int score) {
    if (score >= 80) {
      return '강세';
    }
    if (score >= 65) {
      return '상승';
    }
    if (score >= 45) {
      return '무난';
    }
    if (score >= 30) {
      return '유의';
    }
    return '주의';
  }

  static ({List<int> numbers, String headline, String message})
  _buildLuckyNumbers({
    required BirthInput? birthInput,
    required SajuResult quick,
    required PreciseSajuResult? precise,
    required int score,
    required DateTime now,
  }) {
    final String profileSignature = birthInput?.signature ?? quick.summary;
    final String personalSeed = birthInput?.name.trim().isNotEmpty == true
        ? birthInput!.name.trim()
        : quick.animal;
    final String signalSeed = precise == null
        ? '${quick.dayMaster}-${quick.dominantTenGod}-${quick.supportElement}'
        : '${precise.dayMaster}-${precise.dominantTenGod}-${precise.weakestElement}-${precise.strengthLabel}';
    final String seed =
        '${AppDateUtils.dayKey(now)}|$profileSignature|$personalSeed|$score|${_buildSignals(quick: quick, precise: precise).join('|')}|$signalSeed';

    final Set<int> unique = <int>{};
    int salt = 0;
    while (unique.length < 3) {
      final int value = (_stableHash('$seed|$salt') % 45) + 1;
      unique.add(value);
      salt += 1;
    }

    final List<int> numbers = unique.toList()..sort();
    final String namePrefix = birthInput?.hasName == true
        ? '${birthInput!.name.trim()}님에게 '
        : '';
    final String headline = '$namePrefix오늘 흐름에 맞는 추천 숫자';
    final String message = precise == null
        ? '오늘은 ${quick.supportElement} 보완 흐름과 ${quick.dominantTenGod} 결을 기준으로 숫자를 골랐습니다. 당첨 보장을 뜻하기보다, 오늘의 리듬을 상징적으로 붙잡는 추천 번호입니다.'
        : '오늘은 ${precise.dayMaster} 일간과 ${precise.dominantTenGod} 흐름, ${precise.weakestElement} 보완 축을 함께 반영해 숫자를 골랐습니다. 당첨 보장이 아니라 오늘 운의 결을 가볍게 붙잡는 추천 번호로 보시면 됩니다.';
    return (numbers: numbers, headline: headline, message: message);
  }

  static Future<Map<String, dynamic>> _loadCatalog() async {
    if (_catalog != null) {
      return _catalog!;
    }

    final String raw = await rootBundle.loadString(
      'assets/content/fortune.json',
    );
    _catalog = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return _catalog!;
  }

  static List<Map<String, dynamic>> _readMapList(Object? value) {
    final List<dynamic> items = value as List<dynamic>? ?? <dynamic>[];
    return items
        .map((dynamic item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Map<String, dynamic> _readMap(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static String _lookupText(
    Map<String, dynamic> source,
    String key,
    String fallback,
  ) {
    final Object? value = source[key];
    return value is String ? value : fallback;
  }

  static int _stableHash(String source) {
    const int mod = 2147483647;
    int hash = 23;
    for (final int unit in source.codeUnits) {
      hash = (hash * 131 + unit) % mod;
    }
    return hash;
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}
