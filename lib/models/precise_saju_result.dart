import 'precise_pillar.dart';
import 'precise_saju_input.dart';

class PreciseSajuResult {
  const PreciseSajuResult({
    required this.birthSignature,
    required this.unlockSignature,
    required this.input,
    required this.basisLabel,
    required this.solarLabel,
    required this.lunarLabel,
    required this.dayMaster,
    required this.dayMasterElement,
    required this.strengthLabel,
    required this.dominantElement,
    required this.weakestElement,
    required this.dominantTenGod,
    required this.monthTenGod,
    required this.timeTenGod,
    required this.chartSummary,
    required this.taiYuanLabel,
    required this.taiXiLabel,
    required this.mingGongLabel,
    required this.shenGongLabel,
    required this.fourPillars,
    required this.elementBalance,
    required this.coreNarrative,
    required this.workNarrative,
    required this.relationshipNarrative,
    required this.riskNarrative,
    required this.timingNote,
  });

  final String birthSignature;
  final String unlockSignature;
  final PreciseSajuInput input;
  final String basisLabel;
  final String solarLabel;
  final String lunarLabel;
  final String dayMaster;
  final String dayMasterElement;
  final String strengthLabel;
  final String dominantElement;
  final String weakestElement;
  final String dominantTenGod;
  final String monthTenGod;
  final String timeTenGod;
  final String chartSummary;
  final String taiYuanLabel;
  final String taiXiLabel;
  final String mingGongLabel;
  final String shenGongLabel;
  final List<PrecisePillar> fourPillars;
  final Map<String, int> elementBalance;
  final String coreNarrative;
  final String workNarrative;
  final String relationshipNarrative;
  final String riskNarrative;
  final String timingNote;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'birthSignature': birthSignature,
      'unlockSignature': unlockSignature,
      'input': input.toMap(),
      'basisLabel': basisLabel,
      'solarLabel': solarLabel,
      'lunarLabel': lunarLabel,
      'dayMaster': dayMaster,
      'dayMasterElement': dayMasterElement,
      'strengthLabel': strengthLabel,
      'dominantElement': dominantElement,
      'weakestElement': weakestElement,
      'dominantTenGod': dominantTenGod,
      'monthTenGod': monthTenGod,
      'timeTenGod': timeTenGod,
      'chartSummary': chartSummary,
      'taiYuanLabel': taiYuanLabel,
      'taiXiLabel': taiXiLabel,
      'mingGongLabel': mingGongLabel,
      'shenGongLabel': shenGongLabel,
      'fourPillars': fourPillars
          .map((PrecisePillar item) => item.toMap())
          .toList(),
      'elementBalance': elementBalance,
      'coreNarrative': coreNarrative,
      'workNarrative': workNarrative,
      'relationshipNarrative': relationshipNarrative,
      'riskNarrative': riskNarrative,
      'timingNote': timingNote,
    };
  }

  factory PreciseSajuResult.fromMap(Map<String, dynamic> map) {
    return PreciseSajuResult(
      birthSignature: (map['birthSignature'] as String?) ?? '',
      unlockSignature: (map['unlockSignature'] as String?) ?? '',
      input: PreciseSajuInput.fromMap(
        Map<String, dynamic>.from(map['input'] as Map? ?? <String, dynamic>{}),
      ),
      basisLabel: (map['basisLabel'] as String?) ?? '',
      solarLabel: (map['solarLabel'] as String?) ?? '',
      lunarLabel: (map['lunarLabel'] as String?) ?? '',
      dayMaster: (map['dayMaster'] as String?) ?? '',
      dayMasterElement: (map['dayMasterElement'] as String?) ?? '',
      strengthLabel: (map['strengthLabel'] as String?) ?? '',
      dominantElement: (map['dominantElement'] as String?) ?? '',
      weakestElement: (map['weakestElement'] as String?) ?? '',
      dominantTenGod: (map['dominantTenGod'] as String?) ?? '',
      monthTenGod: (map['monthTenGod'] as String?) ?? '',
      timeTenGod: (map['timeTenGod'] as String?) ?? '',
      chartSummary: (map['chartSummary'] as String?) ?? '',
      taiYuanLabel: (map['taiYuanLabel'] as String?) ?? '',
      taiXiLabel: (map['taiXiLabel'] as String?) ?? '',
      mingGongLabel: (map['mingGongLabel'] as String?) ?? '',
      shenGongLabel: (map['shenGongLabel'] as String?) ?? '',
      fourPillars: ((map['fourPillars'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                PrecisePillar.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList()),
      elementBalance: _asScoreMap(map['elementBalance']),
      coreNarrative: (map['coreNarrative'] as String?) ?? '',
      workNarrative: (map['workNarrative'] as String?) ?? '',
      relationshipNarrative: (map['relationshipNarrative'] as String?) ?? '',
      riskNarrative: (map['riskNarrative'] as String?) ?? '',
      timingNote: (map['timingNote'] as String?) ?? '',
    );
  }

  static Map<String, int> _asScoreMap(Object? value) {
    if (value is! Map) {
      return <String, int>{};
    }
    return value.map<String, int>((Object? key, Object? rawValue) {
      final int parsed = rawValue is num ? rawValue.toInt() : 0;
      return MapEntry<String, int>(key.toString(), parsed);
    });
  }
}
