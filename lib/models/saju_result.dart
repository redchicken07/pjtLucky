class SajuResult {
  const SajuResult({
    required this.animal,
    required this.element,
    required this.dominantElement,
    required this.yinYang,
    required this.lifeNumber,
    required this.energyScore,
    required this.luckyColor,
    required this.yearPillar,
    required this.monthFlow,
    required this.timeBranch,
    required this.dayMaster,
    required this.strengthLabel,
    required this.dominantTenGod,
    required this.monthTenGod,
    required this.timeTenGod,
    required this.supportElement,
    required this.headline,
    required this.surfaceReading,
    required this.innerReading,
    required this.workReading,
    required this.relationshipReading,
    required this.balanceAdvice,
    required this.summary,
  });

  final String animal;
  final String element;
  final String dominantElement;
  final String yinYang;
  final int lifeNumber;
  final int energyScore;
  final String luckyColor;
  final String yearPillar;
  final String monthFlow;
  final String timeBranch;
  final String dayMaster;
  final String strengthLabel;
  final String dominantTenGod;
  final String monthTenGod;
  final String timeTenGod;
  final String supportElement;
  final String headline;
  final String surfaceReading;
  final String innerReading;
  final String workReading;
  final String relationshipReading;
  final String balanceAdvice;
  final String summary;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'animal': animal,
      'element': element,
      'dominantElement': dominantElement,
      'yinYang': yinYang,
      'lifeNumber': lifeNumber,
      'energyScore': energyScore,
      'luckyColor': luckyColor,
      'yearPillar': yearPillar,
      'monthFlow': monthFlow,
      'timeBranch': timeBranch,
      'dayMaster': dayMaster,
      'strengthLabel': strengthLabel,
      'dominantTenGod': dominantTenGod,
      'monthTenGod': monthTenGod,
      'timeTenGod': timeTenGod,
      'supportElement': supportElement,
      'headline': headline,
      'surfaceReading': surfaceReading,
      'innerReading': innerReading,
      'workReading': workReading,
      'relationshipReading': relationshipReading,
      'balanceAdvice': balanceAdvice,
      'summary': summary,
    };
  }

  factory SajuResult.fromMap(Map<String, dynamic> map) {
    return SajuResult(
      animal: (map['animal'] as String?) ?? '',
      element: (map['element'] as String?) ?? '',
      dominantElement: (map['dominantElement'] as String?) ?? '',
      yinYang: (map['yinYang'] as String?) ?? '',
      lifeNumber: _asInt(map['lifeNumber']),
      energyScore: _asInt(map['energyScore']),
      luckyColor: (map['luckyColor'] as String?) ?? '',
      yearPillar: (map['yearPillar'] as String?) ?? '',
      monthFlow: (map['monthFlow'] as String?) ?? '',
      timeBranch: (map['timeBranch'] as String?) ?? '',
      dayMaster: (map['dayMaster'] as String?) ?? '',
      strengthLabel: (map['strengthLabel'] as String?) ?? '',
      dominantTenGod: (map['dominantTenGod'] as String?) ?? '',
      monthTenGod: (map['monthTenGod'] as String?) ?? '',
      timeTenGod: (map['timeTenGod'] as String?) ?? '',
      supportElement: (map['supportElement'] as String?) ?? '',
      headline: (map['headline'] as String?) ?? '',
      surfaceReading: (map['surfaceReading'] as String?) ?? '',
      innerReading: (map['innerReading'] as String?) ?? '',
      workReading: (map['workReading'] as String?) ?? '',
      relationshipReading: (map['relationshipReading'] as String?) ?? '',
      balanceAdvice: (map['balanceAdvice'] as String?) ?? '',
      summary: (map['summary'] as String?) ?? '',
    );
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
