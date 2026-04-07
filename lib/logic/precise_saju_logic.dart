import 'package:lunar/lunar.dart';

import '../models/birth_input.dart';
import '../models/precise_pillar.dart';
import '../models/precise_saju_input.dart';
import '../models/precise_saju_result.dart';

class PreciseSajuLogic {
  static const Map<String, String> _stemHangul = <String, String>{
    '甲': '갑',
    '乙': '을',
    '丙': '병',
    '丁': '정',
    '戊': '무',
    '己': '기',
    '庚': '경',
    '辛': '신',
    '壬': '임',
    '癸': '계',
  };

  static const Map<String, String> _branchHangul = <String, String>{
    '子': '자',
    '丑': '축',
    '寅': '인',
    '卯': '묘',
    '辰': '진',
    '巳': '사',
    '午': '오',
    '未': '미',
    '申': '신',
    '酉': '유',
    '戌': '술',
    '亥': '해',
  };

  static const Map<String, String> _elementHangul = <String, String>{
    '木': '목',
    '火': '화',
    '土': '토',
    '金': '금',
    '水': '수',
  };

  static const Map<String, String> _stemElements = <String, String>{
    '甲': '목',
    '乙': '목',
    '丙': '화',
    '丁': '화',
    '戊': '토',
    '己': '토',
    '庚': '금',
    '辛': '금',
    '壬': '수',
    '癸': '수',
  };

  static const Map<String, String> _branchElements = <String, String>{
    '子': '수',
    '丑': '토',
    '寅': '목',
    '卯': '목',
    '辰': '토',
    '巳': '화',
    '午': '화',
    '未': '토',
    '申': '금',
    '酉': '금',
    '戌': '토',
    '亥': '수',
  };

  static const Map<String, String> _tenGodHangul = <String, String>{
    '比肩': '비견',
    '劫财': '겁재',
    '食神': '식신',
    '伤官': '상관',
    '偏财': '편재',
    '正财': '정재',
    '七杀': '칠살',
    '正官': '정관',
    '偏印': '편인',
    '正印': '정인',
    '日主': '일주',
  };

  static const Map<String, String> _dayMasterImages = <String, String>{
    '갑': '큰 나무처럼 방향을 세우고 곧게 뻗으려는 기질이 강합니다.',
    '을': '덩굴이나 화초처럼 유연하게 휘면서도 끝내 자리를 넓히는 힘이 있습니다.',
    '병': '태양처럼 바깥으로 빛과 열을 드러내며 존재감을 남기려는 성향이 있습니다.',
    '정': '촛불처럼 섬세하게 분위기를 읽고 필요한 곳에 온기를 집중시키는 타입입니다.',
    '무': '산처럼 무게 중심을 잡고 쉽게 흔들리지 않으려는 경향이 강합니다.',
    '기': '논밭의 흙처럼 현실을 다지고 주변을 살피며 실속을 챙기는 타입입니다.',
    '경': '원석이나 쇠처럼 단단한 기준을 세우고 정면 돌파를 택하는 기질이 있습니다.',
    '신': '보석이나 칼날처럼 예민한 판단과 정교한 기준을 중시하는 성향입니다.',
    '임': '큰 강물처럼 판을 넓게 보고 흐름 전체를 읽으려는 움직임이 강합니다.',
    '계': '비나 안개처럼 섬세하게 스며들며 감정과 분위기를 먼저 포착하는 타입입니다.',
  };

  static const Map<String, String> _monthRelationNarratives = <String, String>{
    'support':
        '월령이 일간을 받쳐 주는 구조라 기본 바탕은 쉽게 꺼지지 않는 편입니다. 다만 익숙한 판에 오래 머물면 속도가 늦어질 수 있습니다.',
    'same':
        '일간과 월령이 같은 오행 축으로 맞물려 자기 색이 비교적 선명하게 드러납니다. 장점이 또렷한 대신 융통성이 좁아질 수 있습니다.',
    'output':
        '일간의 힘이 바깥으로 흘러 나가 표현과 결과로 이어지는 구조라, 성과는 보이기 쉬워도 체력과 멘탈 소모는 생각보다 빠를 수 있습니다.',
    'control':
        '일간이 환경을 눌러 가며 움직이는 구조라 통제력과 주도권 욕구가 강합니다. 대신 사람이나 일에 과하게 힘을 쓰면 피로가 누적되기 쉽습니다.',
    'pressure':
        '월령이 일간을 누르는 구조라 초반에는 압박과 자기검열이 먼저 들어오기 쉽습니다. 대신 기준이 잡히면 성장 폭은 큽니다.',
  };

  static const Map<String, String> _workNarratives = <String, String>{
    '비견':
        '일에서는 남의 판에 기대기보다 자기 기준으로 직접 밀고 나갈 때 힘이 납니다. 다만 협업에서는 주도권 충돌을 조절할 필요가 있습니다.',
    '겁재': '일에서는 승부욕과 속도감이 살아 있어 판이 움직일 때 강합니다. 대신 조급함이 올라오면 계산이 짧아질 수 있습니다.',
    '식신': '일에서는 꾸준히 결과를 내고 실무를 굴리는 힘이 좋습니다. 반복성과 완성도를 쌓을수록 강점이 선명해집니다.',
    '상관':
        '일에서는 표현력과 비판적 감각이 강합니다. 다만 답답한 구조에 오래 묶이면 불만이 커질 수 있어, 말의 날을 다듬는 것이 중요합니다.',
    '편재':
        '일에서는 시장 감각과 순발력이 좋아 기회를 빠르게 잡는 편입니다. 대신 한 번에 너무 많은 판을 벌리면 힘이 새기 쉽습니다.',
    '정재': '일에서는 실속과 관리 능력이 강합니다. 눈에 띄는 한 방보다 쌓이는 결과를 만드는 쪽에서 더 안정적입니다.',
    '칠살':
        '일에서는 압박이 걸릴수록 오히려 집중이 올라가는 편입니다. 다만 긴장을 오래 품으면 스스로를 몰아붙이기 쉬워 완급 조절이 필요합니다.',
    '정관': '일에서는 규칙, 책임, 역할이 분명한 자리에서 강합니다. 기준이 뚜렷한 환경일수록 실력이 안정적으로 나옵니다.',
    '편인': '일에서는 직관과 해석력이 살아 있습니다. 혼자 정리할 시간과 자유도가 있을 때 결과물이 좋아집니다.',
    '정인': '일에서는 학습력과 정리력이 안정적입니다. 기본기와 맥락을 이해하면서 가는 쪽에서 오래 강합니다.',
  };

  static const Map<String, String> _relationshipNarratives = <String, String>{
    '비견':
        '관계에서는 대등함과 자존심을 중요하게 여기는 편입니다. 가까워질수록 편해지지만, 선을 넘었다고 느끼면 바로 거리를 둘 수 있습니다.',
    '겁재':
        '관계에서는 친해지는 속도는 빠르지만 감정 기복도 함께 올라오기 쉽습니다. 순간적인 서운함을 오래 끌지 않는 게 중요합니다.',
    '식신': '관계에서는 편안함과 생활 리듬의 합이 중요합니다. 무리하지 않는 호흡이 맞을수록 오래 가는 편입니다.',
    '상관': '관계에서는 솔직함이 강점이지만, 말이 지나치게 날카로워지면 상대가 방어적으로 변할 수 있습니다.',
    '편재': '관계에서는 유연하고 센스 있게 움직이지만, 깊어질수록 책임보다 감각이 먼저 앞설 수 있어 균형이 필요합니다.',
    '정재': '관계에서는 안정감과 꾸준함을 중시합니다. 신뢰가 쌓이면 오래 가지만, 마음을 열기까지 시간이 걸릴 수 있습니다.',
    '칠살':
        '관계에서는 긴장감과 끌림이 함께 작동하기 쉬운 편입니다. 강한 사람에게 끌리기도 하지만, 힘겨루기로 번지지 않게 조절해야 합니다.',
    '정관': '관계에서는 예의와 기준을 중요하게 봅니다. 신뢰가 생기면 단단하지만, 실망 포인트가 분명한 편입니다.',
    '편인': '관계에서는 겉으로 다 설명하지 않고 감으로 판단하는 편입니다. 이해받는다고 느낄 때 깊게 연결됩니다.',
    '정인': '관계에서는 보호와 배려를 중요하게 봅니다. 다만 서운함을 밖으로 바로 말하지 않고 안에 쌓아 둘 수 있습니다.',
  };

  static const Map<String, String> _dominantElementNarratives =
      <String, String>{
        '목': '목 기운이 도드라져 시작과 확장, 사람과의 연결에서 힘이 붙습니다.',
        '화': '화 기운이 도드라져 표현력, 승부욕, 존재감이 쉽게 살아납니다.',
        '토': '토 기운이 도드라져 현실 감각, 구조화, 버티는 힘이 강합니다.',
        '금': '금 기운이 도드라져 판단, 정리, 기준 세우기에서 강점이 큽니다.',
        '수': '수 기운이 도드라져 관찰, 해석, 흐름 읽기에서 감각이 살아납니다.',
      };

  static const Map<String, String> _weakElementNarratives = <String, String>{
    '목': '목 기운이 약하면 스타트를 끊는 힘이나 낙관적인 확장성이 늦게 붙을 수 있습니다.',
    '화': '화 기운이 약하면 표현력보다 속으로만 끌어안는 시간이 길어질 수 있습니다.',
    '토': '토 기운이 약하면 생활 리듬과 중심축이 흔들릴 때 피로가 크게 느껴질 수 있습니다.',
    '금': '금 기운이 약하면 기준을 세우기 전까지 판단이 길어지거나 미뤄질 수 있습니다.',
    '수': '수 기운이 약하면 쉬는 법을 놓치고 건조하게 몰아붙이기 쉬워 회복력이 떨어질 수 있습니다.',
  };

  static const Map<String, String> _generatedBy = <String, String>{
    '목': '수',
    '화': '목',
    '토': '화',
    '금': '토',
    '수': '금',
  };

  static const Map<String, String> _generates = <String, String>{
    '목': '화',
    '화': '토',
    '토': '금',
    '금': '수',
    '수': '목',
  };

  static const Map<String, String> _controls = <String, String>{
    '목': '토',
    '화': '금',
    '토': '수',
    '금': '목',
    '수': '화',
  };

  static const Map<String, String> _controlledBy = <String, String>{
    '목': '금',
    '화': '수',
    '토': '목',
    '금': '화',
    '수': '토',
  };

  static const Map<String, String> _strengthNarratives = <String, String>{
    '신강': '신강 쪽으로 읽히는 명식이라 자기 기운과 자기 방식이 비교적 쉽게 꺾이지 않는 편입니다.',
    '중화에 가까운 신강':
        '완전한 신강까지는 아니어도 자기 기운이 쉽게 무너지지 않는 편이라, 상황이 열리면 주도권을 잡고 싶어지는 흐름이 있습니다.',
    '중화': '신강과 신약으로 크게 쏠리기보다는 중화에 가까워, 환경과 시기에 따라 기세가 달라질 여지가 있는 명식입니다.',
    '중화에 가까운 신약':
        '극단적인 신약은 아니지만 계절과 주변 기운의 압박을 꽤 받는 편이라, 자기 리듬을 세우는 데 예열이 필요한 명식입니다.',
    '신약':
        '신약 쪽으로 기울어 주변 환경과 계절의 압박이 먼저 체감되기 쉬운 명식입니다. 그래서 컨디션과 타이밍 관리가 특히 중요합니다.',
  };

  static const Map<String, String> _dominantTenGodNarratives = <String, String>{
    '비견': '명식 전반에서 비견이 반복되면 자기 방식과 자존의식이 쉽게 꺾이지 않고, 비교와 경쟁도 자연스럽게 의식하게 됩니다.',
    '겁재': '명식 전반에서 겁재가 반복되면 속도전과 승부욕이 자주 올라오고, 사람 사이에서도 힘의 균형을 민감하게 읽게 됩니다.',
    '식신': '명식 전반에서 식신이 반복되면 결국 손으로 굴리고 결과를 쌓는 실무 감각이 실제 강점으로 굳어지기 쉽습니다.',
    '상관': '명식 전반에서 상관이 반복되면 말과 표현, 판단의 날이 서기 쉬워 남들이 놓친 허점을 먼저 보게 됩니다.',
    '편재': '명식 전반에서 편재가 반복되면 사람과 기회를 넓게 보며 판을 유동적으로 움직이는 감각이 강해집니다.',
    '정재': '명식 전반에서 정재가 반복되면 한 번 잡은 것을 안정적으로 관리하고 현실성을 따지는 면이 강해집니다.',
    '칠살':
        '명식 전반에서 칠살이 반복되면 긴장과 압박을 버티는 힘이 생기지만, 동시에 스스로를 몰아세우는 습관도 함께 생기기 쉽습니다.',
    '정관': '명식 전반에서 정관이 반복되면 기준, 책임, 체면을 중시하는 흐름이 강해져 스스로를 쉽게 느슨하게 풀지 않는 편입니다.',
    '편인': '명식 전반에서 편인이 반복되면 직관과 해석, 혼자 정리하는 방식이 강해져 겉보다 속 사고가 깊어집니다.',
    '정인':
        '명식 전반에서 정인이 반복되면 배우고 정리하고 보호하려는 태도가 강해져, 기본기와 맥락을 챙기는 힘이 안정적으로 살아납니다.',
  };

  static PreciseSajuResult calculate(
    BirthInput birthInput,
    PreciseSajuInput preciseInput,
  ) {
    final _ResolvedCalendar resolved = _resolveCalendar(
      birthInput,
      preciseInput,
    );
    final EightChar eightChar = resolved.lunar.getEightChar();
    final Map<String, int> elementBalance = _buildElementBalance(eightChar);
    final Map<String, double> weightedBalance = _buildWeightedElementBalance(
      eightChar,
    );
    final String dayMasterGan = eightChar.getDayGan();
    final String dayMasterHangul = _stemHangul[dayMasterGan] ?? dayMasterGan;
    final String dayMasterElement = _stemElements[dayMasterGan] ?? '토';
    final String monthElement = _branchElement(eightChar.getMonthZhi());
    final String dominantElement = _pickDominantElement(elementBalance);
    final String weakestElement = _pickWeakestElement(elementBalance);
    final List<String> missingElements = _findMissingElements(elementBalance);
    final String monthTenGod = _translateTenGod(eightChar.getMonthShiShenGan());
    final String timeTenGod = _translateTenGod(eightChar.getTimeShiShenGan());
    final Map<String, int> tenGodCounts = _buildTenGodCounts(eightChar);
    final String dominantTenGod = _pickDominantTenGod(
      tenGodCounts,
      monthTenGod,
    );
    final Map<String, int> stemCounts = _countItems(<String>[
      eightChar.getYearGan(),
      eightChar.getMonthGan(),
      eightChar.getDayGan(),
      eightChar.getTimeGan(),
    ]);
    final Map<String, int> branchCounts = _countItems(<String>[
      eightChar.getYearZhi(),
      eightChar.getMonthZhi(),
      eightChar.getDayZhi(),
      eightChar.getTimeZhi(),
    ]);
    final String relationKey = _monthRelation(dayMasterElement, monthElement);
    final double strengthScore = _strengthScore(
      weightedBalance: weightedBalance,
      dayMasterElement: dayMasterElement,
      relationKey: relationKey,
      dayMasterGan: dayMasterGan,
      stemCounts: stemCounts,
    );
    final String strengthLabel = _strengthLabel(strengthScore);
    final String basisLabel = preciseInput.basisLabel;
    final String branchTimingNote =
        preciseInput.timePrecision == TimePrecision.branch
        ? '이번 결과는 ${preciseInput.timeBranchSlot?.label ?? '시지'} 기준 간이 판독입니다. 분 단위 차이와 자시 경계는 반영하지 않습니다.'
        : '이번 결과는 분 단위까지 반영한 정밀 시각 기준입니다.';

    final List<PrecisePillar> pillars = <PrecisePillar>[
      PrecisePillar(
        label: '연주',
        ganZhi: eightChar.getYear(),
        reading: _readGanZhi(eightChar.getYear()),
        wuXing: _readWuXing(eightChar.getYearWuXing()),
        naYin: eightChar.getYearNaYin(),
        hideGan: _formatHideGan(eightChar.getYearHideGan()),
        shiShenGan: _translateTenGod(eightChar.getYearShiShenGan()),
        shiShenZhi: eightChar
            .getYearShiShenZhi()
            .map(_translateTenGod)
            .toList(),
        diShi: eightChar.getYearDiShi(),
      ),
      PrecisePillar(
        label: '월주',
        ganZhi: eightChar.getMonth(),
        reading: _readGanZhi(eightChar.getMonth()),
        wuXing: _readWuXing(eightChar.getMonthWuXing()),
        naYin: eightChar.getMonthNaYin(),
        hideGan: _formatHideGan(eightChar.getMonthHideGan()),
        shiShenGan: _translateTenGod(eightChar.getMonthShiShenGan()),
        shiShenZhi: eightChar
            .getMonthShiShenZhi()
            .map(_translateTenGod)
            .toList(),
        diShi: eightChar.getMonthDiShi(),
      ),
      PrecisePillar(
        label: '일주',
        ganZhi: eightChar.getDay(),
        reading: _readGanZhi(eightChar.getDay()),
        wuXing: _readWuXing(eightChar.getDayWuXing()),
        naYin: eightChar.getDayNaYin(),
        hideGan: _formatHideGan(eightChar.getDayHideGan()),
        shiShenGan: '일주',
        shiShenZhi: eightChar.getDayShiShenZhi().map(_translateTenGod).toList(),
        diShi: eightChar.getDayDiShi(),
      ),
      PrecisePillar(
        label: '시주',
        ganZhi: eightChar.getTime(),
        reading: _readGanZhi(eightChar.getTime()),
        wuXing: _readWuXing(eightChar.getTimeWuXing()),
        naYin: eightChar.getTimeNaYin(),
        hideGan: _formatHideGan(eightChar.getTimeHideGan()),
        shiShenGan: _translateTenGod(eightChar.getTimeShiShenGan()),
        shiShenZhi: eightChar
            .getTimeShiShenZhi()
            .map(_translateTenGod)
            .toList(),
        diShi: eightChar.getTimeDiShi(),
      ),
    ];

    final String chartSummary =
        '이 명식은 ${_branchDisplay(eightChar.getMonthZhi())} 월령에 놓인 $dayMasterHangul$dayMasterElement 일간입니다. '
        '${_strengthNarratives[strengthLabel] ?? '강약은 중간 흐름으로 읽힙니다.'} '
        '${_monthRelationNarratives[relationKey] ?? '월 기운과 일간의 관계를 함께 읽어야 성향이 선명해집니다.'} '
        '${_stemRepeatNarrative(stemCounts, dayMasterGan)} '
        '${_branchRepeatNarrative(branchCounts)} '
        '${_hiddenStemNarrative(eightChar)} '
        '${_missingElementNarrative(missingElements)}';

    final String coreNarrative =
        '일간은 $dayMasterHangul$dayMasterElement입니다. '
        '${_dayMasterImages[dayMasterHangul] ?? '기본적으로 자기 기운을 밖으로 어떻게 쓰는지가 중요한 타입입니다.'} '
        '월령은 ${_branchDisplay(eightChar.getMonthZhi())}라 ${_readWuXing(eightChar.getMonthWuXing())} 축이 먼저 작동합니다. '
        '${_dominantElementNarratives[dominantElement] ?? ''} '
        '${_strengthNarratives[strengthLabel] ?? ''} '
        '${_dominantTenGodNarratives[dominantTenGod] ?? ''}';

    final String workNarrative =
        '사회적 역할과 바깥 활동을 보는 월간은 $monthTenGod이고, 월지 속 지장간은 ${_formatHideGan(eightChar.getMonthHideGan()).join('·')}로 읽힙니다. '
        '${_workNarratives[monthTenGod] ?? '일에서는 자기 기준과 환경 사이의 속도 조절이 중요합니다.'} '
        '${dominantTenGod == monthTenGod ? '표면에 드러나는 사회적 역할과 실제 일 처리 방식이 크게 어긋나지 않는 편입니다.' : '겉으로는 $monthTenGod처럼 보여도, 명식 전체에서는 $dominantTenGod 흐름이 더 자주 반복되어 실제 실무 습관과 결과물은 그쪽 성향을 더 닮기 쉽습니다.'}';

    final String relationshipNarrative =
        '가까운 관계와 개인 영역을 보는 시주는 $timeTenGod이고, 일지 속 십신은 ${eightChar.getDayShiShenZhi().map(_translateTenGod).join('·')}로 깔려 있습니다. '
        '${_relationshipNarratives[timeTenGod] ?? '관계에서는 속도와 거리감을 함께 맞추는 편이 중요합니다.'} '
        '${_innerLayerNarrative(eightChar.getDayShiShenZhi().map(_translateTenGod).toList())}';

    final String riskNarrative =
        '${_weakElementNarratives[weakestElement] ?? '약한 기운을 보완하는 생활 패턴이 중요합니다.'} '
        '${_distributionNarrative(elementBalance, dominantElement)} '
        '${_riskNarrativeByStrength(strengthLabel)} '
        '$branchTimingNote';

    return PreciseSajuResult(
      birthSignature: birthInput.signature,
      unlockSignature: '${birthInput.signature}|${preciseInput.signature}',
      input: preciseInput,
      basisLabel: basisLabel,
      solarLabel: '양력 ${resolved.solar.toYmdHms()}',
      lunarLabel:
          '음력 ${resolved.lunar.toString()} ${preciseInput.isLunar && preciseInput.isLeapMonth == true ? '(윤달)' : ''}',
      dayMaster: '$dayMasterHangul$dayMasterElement',
      dayMasterElement: dayMasterElement,
      strengthLabel: strengthLabel,
      dominantElement: dominantElement,
      weakestElement: weakestElement,
      dominantTenGod: dominantTenGod,
      monthTenGod: monthTenGod,
      timeTenGod: timeTenGod,
      chartSummary: chartSummary,
      taiYuanLabel: _compoundLabel(
        '태원',
        eightChar.getTaiYuan(),
        eightChar.getTaiYuanNaYin(),
      ),
      taiXiLabel: _compoundLabel(
        '태식',
        eightChar.getTaiXi(),
        eightChar.getTaiXiNaYin(),
      ),
      mingGongLabel: _compoundLabel(
        '명궁',
        eightChar.getMingGong(),
        eightChar.getMingGongNaYin(),
      ),
      shenGongLabel: _compoundLabel(
        '신궁',
        eightChar.getShenGong(),
        eightChar.getShenGongNaYin(),
      ),
      fourPillars: pillars,
      elementBalance: elementBalance,
      coreNarrative: coreNarrative,
      workNarrative: workNarrative,
      relationshipNarrative: relationshipNarrative,
      riskNarrative: riskNarrative,
      timingNote: branchTimingNote,
    );
  }

  static _ResolvedCalendar _resolveCalendar(
    BirthInput birthInput,
    PreciseSajuInput preciseInput,
  ) {
    try {
      if (preciseInput.calendarType == CalendarType.solar) {
        final Solar solar = Solar.fromYmdHms(
          birthInput.year,
          birthInput.month,
          birthInput.day,
          preciseInput.resolvedHour,
          preciseInput.resolvedMinute,
          0,
        );
        return _ResolvedCalendar(solar, Lunar.fromSolar(solar));
      }

      final int lunarMonth = preciseInput.isLeapMonth == true
          ? -birthInput.month
          : birthInput.month;
      final Lunar lunar = Lunar.fromYmdHms(
        birthInput.year,
        lunarMonth,
        birthInput.day,
        preciseInput.resolvedHour,
        preciseInput.resolvedMinute,
        0,
      );
      return _ResolvedCalendar(lunar.getSolar(), lunar);
    } catch (_) {
      if (preciseInput.calendarType == CalendarType.lunar &&
          preciseInput.isLeapMonth == true) {
        throw const FormatException('해당 생년에는 선택한 윤달이 없을 수 있습니다.');
      }
      throw const FormatException('정밀 사주 입력값을 다시 확인해 주세요.');
    }
  }

  static Map<String, int> _buildElementBalance(EightChar eightChar) {
    final Map<String, int> balance = <String, int>{
      '목': 0,
      '화': 0,
      '토': 0,
      '금': 0,
      '수': 0,
    };
    final List<String> raw = <String>[
      eightChar.getYearWuXing(),
      eightChar.getMonthWuXing(),
      eightChar.getDayWuXing(),
      eightChar.getTimeWuXing(),
    ];
    for (final String unit in raw) {
      for (final String rune in unit.split('')) {
        final String translated = _elementHangul[rune] ?? '';
        if (translated.isNotEmpty) {
          balance[translated] = (balance[translated] ?? 0) + 1;
        }
      }
    }
    return balance;
  }

  static Map<String, double> _buildWeightedElementBalance(EightChar eightChar) {
    final Map<String, double> balance = <String, double>{
      '목': 0,
      '화': 0,
      '토': 0,
      '금': 0,
      '수': 0,
    };

    void add(String element, double weight) {
      balance[element] = (balance[element] ?? 0) + weight;
    }

    add(_stemElements[eightChar.getYearGan()] ?? '토', 1.6);
    add(_branchElement(eightChar.getYearZhi()), 1.2);
    for (final String stem in eightChar.getYearHideGan()) {
      add(_stemElements[stem] ?? '토', 0.7);
    }

    add(_stemElements[eightChar.getMonthGan()] ?? '토', 2.0);
    add(_branchElement(eightChar.getMonthZhi()), 2.6);
    for (final String stem in eightChar.getMonthHideGan()) {
      add(_stemElements[stem] ?? '토', 1.0);
    }

    add(_stemElements[eightChar.getDayGan()] ?? '토', 2.2);
    add(_branchElement(eightChar.getDayZhi()), 1.4);
    for (final String stem in eightChar.getDayHideGan()) {
      add(_stemElements[stem] ?? '토', 0.8);
    }

    add(_stemElements[eightChar.getTimeGan()] ?? '토', 1.4);
    add(_branchElement(eightChar.getTimeZhi()), 1.1);
    for (final String stem in eightChar.getTimeHideGan()) {
      add(_stemElements[stem] ?? '토', 0.6);
    }

    return balance;
  }

  static double _strengthScore({
    required Map<String, double> weightedBalance,
    required String dayMasterElement,
    required String relationKey,
    required String dayMasterGan,
    required Map<String, int> stemCounts,
  }) {
    final String resourceElement = _generatedBy[dayMasterElement] ?? '토';
    final String outputElement = _generates[dayMasterElement] ?? '토';
    final String wealthElement = _controls[dayMasterElement] ?? '토';
    final String officerElement = _controlledBy[dayMasterElement] ?? '토';

    final double supportScore =
        (weightedBalance[dayMasterElement] ?? 0) * 1.2 +
        (weightedBalance[resourceElement] ?? 0) * 1.1;
    final double drainScore =
        (weightedBalance[outputElement] ?? 0) * 0.8 +
        (weightedBalance[wealthElement] ?? 0) * 1.0 +
        (weightedBalance[officerElement] ?? 0) * 1.15;
    final double seasonalBonus = switch (relationKey) {
      'same' => 2.4,
      'support' => 1.8,
      'output' => -1.0,
      'control' => -1.5,
      _ => -2.2,
    };
    final double repeatBonus = (stemCounts[dayMasterGan] ?? 0) >= 2 ? 1.0 : 0.0;

    return supportScore - drainScore + seasonalBonus + repeatBonus;
  }

  static String _strengthLabel(double score) {
    if (score >= 4.0) {
      return '신강';
    }
    if (score >= 1.5) {
      return '중화에 가까운 신강';
    }
    if (score > -1.5) {
      return '중화';
    }
    if (score > -4.0) {
      return '중화에 가까운 신약';
    }
    return '신약';
  }

  static Map<String, int> _buildTenGodCounts(EightChar eightChar) {
    final Map<String, int> counts = <String, int>{};
    final List<String> raw = <String>[
      _translateTenGod(eightChar.getYearShiShenGan()),
      _translateTenGod(eightChar.getMonthShiShenGan()),
      _translateTenGod(eightChar.getTimeShiShenGan()),
      ...eightChar.getYearShiShenZhi().map(_translateTenGod),
      ...eightChar.getMonthShiShenZhi().map(_translateTenGod),
      ...eightChar.getDayShiShenZhi().map(_translateTenGod),
      ...eightChar.getTimeShiShenZhi().map(_translateTenGod),
    ];
    for (final String item in raw) {
      if (item.isEmpty || item == '일주') {
        continue;
      }
      counts[item] = (counts[item] ?? 0) + 1;
    }
    return counts;
  }

  static String _pickDominantTenGod(Map<String, int> counts, String fallback) {
    if (counts.isEmpty) {
      return fallback;
    }
    return counts.entries
        .reduce(
          (MapEntry<String, int> current, MapEntry<String, int> next) =>
              next.value > current.value ? next : current,
        )
        .key;
  }

  static Map<String, int> _countItems(List<String> items) {
    final Map<String, int> counts = <String, int>{};
    for (final String item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    return counts;
  }

  static List<String> _findMissingElements(Map<String, int> balance) {
    return balance.entries
        .where((MapEntry<String, int> entry) => entry.value == 0)
        .map((MapEntry<String, int> entry) => entry.key)
        .toList();
  }

  static String _pickDominantElement(Map<String, int> balance) {
    return balance.entries
        .reduce(
          (MapEntry<String, int> current, MapEntry<String, int> next) =>
              next.value > current.value ? next : current,
        )
        .key;
  }

  static String _pickWeakestElement(Map<String, int> balance) {
    return balance.entries
        .reduce(
          (MapEntry<String, int> current, MapEntry<String, int> next) =>
              next.value < current.value ? next : current,
        )
        .key;
  }

  static String _monthRelation(String dayMaster, String monthElement) {
    if (dayMaster == monthElement) {
      return 'same';
    }
    if (_generatedBy[dayMaster] == monthElement) {
      return 'support';
    }
    if (_generates[dayMaster] == monthElement) {
      return 'output';
    }
    if (_controls[dayMaster] == monthElement) {
      return 'control';
    }
    return 'pressure';
  }

  static String _branchElement(String branch) {
    return _branchElements[branch] ?? '토';
  }

  static String _readGanZhi(String value) {
    final List<String> chars = value.split('');
    if (chars.length != 2) {
      return value;
    }
    final String gan = _stemHangul[chars[0]] ?? chars[0];
    final String zhi = _branchHangul[chars[1]] ?? chars[1];
    return '$gan$zhi';
  }

  static String _readWuXing(String value) {
    return value
        .split('')
        .map((String item) => _elementHangul[item] ?? item)
        .join('·');
  }

  static String _translateTenGod(String raw) {
    return _tenGodHangul[raw] ?? raw;
  }

  static List<String> _formatHideGan(List<String> stems) {
    return stems.map(_stemDisplay).toList();
  }

  static String _stemDisplay(String stem) {
    final String hangul = _stemHangul[stem] ?? stem;
    final String element = _stemElements[stem] ?? '';
    return '$stem($hangul$element)';
  }

  static String _branchDisplay(String branch) {
    return '$branch(${_branchHangul[branch] ?? branch})';
  }

  static String _compoundLabel(String prefix, String ganZhi, String naYin) {
    return '$prefix $ganZhi(${_readGanZhi(ganZhi)}) · $naYin';
  }

  static String _stemRepeatNarrative(
    Map<String, int> counts,
    String dayMasterGan,
  ) {
    final List<MapEntry<String, int>> repeated =
        counts.entries
            .where((MapEntry<String, int> entry) => entry.value >= 2)
            .toList()
          ..sort(
            (MapEntry<String, int> a, MapEntry<String, int> b) =>
                b.value.compareTo(a.value),
          );
    if (repeated.isEmpty) {
      return '천간은 각기 다른 얼굴을 보여 겉으로 보이는 인상보다 속 구조가 더 복합적으로 작동합니다.';
    }
    final MapEntry<String, int> top = repeated.first;
    if (top.key == dayMasterGan) {
      return '천간에는 ${_stemDisplay(top.key)}가 ${top.value}번 떠 있어 자기 기운과 자기 기준이 표면에서 한 번 더 강조됩니다.';
    }
    return '천간에는 ${_stemDisplay(top.key)}가 ${top.value}번 반복되어 그 성향이 바깥 인상에서도 비교적 쉽게 드러납니다.';
  }

  static String _branchRepeatNarrative(Map<String, int> counts) {
    final List<MapEntry<String, int>> repeated =
        counts.entries
            .where((MapEntry<String, int> entry) => entry.value >= 2)
            .toList()
          ..sort(
            (MapEntry<String, int> a, MapEntry<String, int> b) =>
                b.value.compareTo(a.value),
          );
    if (repeated.isEmpty) {
      return '지지는 한 가지 패턴으로만 몰리지 않아 삶의 무대가 비교적 분산되어 있습니다.';
    }
    final MapEntry<String, int> top = repeated.first;
    final String element = _branchElement(top.key);
    return '지지에는 ${_branchDisplay(top.key)}가 ${top.value}번 반복되어 $element 기운의 생활 패턴이 여러 영역에서 되풀이되기 쉽습니다.';
  }

  static String _hiddenStemNarrative(EightChar eightChar) {
    final String monthHidden = _formatHideGan(
      eightChar.getMonthHideGan(),
    ).join('·');
    final String dayHidden = _formatHideGan(
      eightChar.getDayHideGan(),
    ).join('·');
    return '월지 ${_branchDisplay(eightChar.getMonthZhi())} 속에는 $monthHidden가 깔려 있어 사회적으로 드러나는 결이 단선적이지 않습니다. 일지 ${_branchDisplay(eightChar.getDayZhi())} 안의 $dayHidden는 속마음과 실제 관계 방식이 겉표현보다 더 복합적이라는 점을 보여 줍니다.';
  }

  static String _missingElementNarrative(List<String> missingElements) {
    if (missingElements.isEmpty) {
      return '오행이 한쪽으로 완전히 비지는 않아 환경에 따라 보완 여지는 남아 있습니다.';
    }
    if (missingElements.length == 1) {
      return '${missingElements.first} 기운이 겉으로 거의 드러나지 않아, 그 영역은 의식적으로 채워 넣어야 밸런스가 맞습니다.';
    }
    return '${missingElements.join('·')} 기운이 약하거나 비어 있어 한쪽 감각으로만 밀어붙이면 균형이 무너지기 쉽습니다.';
  }

  static String _innerLayerNarrative(List<String> innerTenGods) {
    if (innerTenGods.contains('정인') || innerTenGods.contains('편인')) {
      return '겉으로 보이는 반응보다 속에서는 이해받고 싶은 마음과 해석 욕구가 더 크게 움직일 수 있습니다.';
    }
    if (innerTenGods.contains('정관') || innerTenGods.contains('칠살')) {
      return '겉으로는 담담해 보여도 속에서는 기준과 긴장을 쉽게 내려놓지 못하는 편으로 읽힙니다.';
    }
    if (innerTenGods.contains('식신') || innerTenGods.contains('상관')) {
      return '마음을 열면 말과 표현이 생각보다 강하게 나가거나, 반대로 너무 많이 참은 뒤 한 번에 터질 수 있습니다.';
    }
    return '겉으로 드러난 태도와 실제 속마음 사이에 간격이 생기기 쉬워, 가까워질수록 천천히 결을 맞추는 편이 유리합니다.';
  }

  static String _distributionNarrative(
    Map<String, int> balance,
    String dominantElement,
  ) {
    final String summary = balance.entries
        .map((MapEntry<String, int> entry) => '${entry.key}${entry.value}')
        .join(' / ');
    return '오행 분포는 $summary로 읽히며, 특히 $dominantElement 축이 상대적으로 앞에 서 있습니다.';
  }

  static String _riskNarrativeByStrength(String strengthLabel) {
    switch (strengthLabel) {
      case '신강':
        return '신강한 명식은 장점이 분명한 대신 자기 기준이 지나치면 사람과 상황을 밀어붙이기 쉽습니다.';
      case '중화에 가까운 신강':
        return '자기 기운이 적지 않은 편이라 무리해서 끌고 가는 순간 피로가 뒤늦게 몰릴 수 있습니다.';
      case '중화':
        return '중화형 명식은 상황 적응력은 있지만, 오히려 어느 쪽으로 에너지를 써야 할지 흐려질 때가 있습니다.';
      case '중화에 가까운 신약':
        return '계절과 주변 압박을 받는 편이라, 리듬이 무너지면 회복보다 방어가 먼저 작동할 수 있습니다.';
      default:
        return '신약 쪽 명식은 무리하게 강한 판에 자신을 오래 노출시키면 쉽게 소진될 수 있습니다.';
    }
  }
}

class _ResolvedCalendar {
  const _ResolvedCalendar(this.solar, this.lunar);

  final Solar solar;
  final Lunar lunar;
}
