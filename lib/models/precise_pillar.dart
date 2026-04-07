class PrecisePillar {
  const PrecisePillar({
    required this.label,
    required this.ganZhi,
    required this.reading,
    required this.wuXing,
    required this.naYin,
    required this.hideGan,
    required this.shiShenGan,
    required this.shiShenZhi,
    required this.diShi,
  });

  final String label;
  final String ganZhi;
  final String reading;
  final String wuXing;
  final String naYin;
  final List<String> hideGan;
  final String shiShenGan;
  final List<String> shiShenZhi;
  final String diShi;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'ganZhi': ganZhi,
      'reading': reading,
      'wuXing': wuXing,
      'naYin': naYin,
      'hideGan': hideGan,
      'shiShenGan': shiShenGan,
      'shiShenZhi': shiShenZhi,
      'diShi': diShi,
    };
  }

  factory PrecisePillar.fromMap(Map<String, dynamic> map) {
    return PrecisePillar(
      label: (map['label'] as String?) ?? '',
      ganZhi: (map['ganZhi'] as String?) ?? '',
      reading: (map['reading'] as String?) ?? '',
      wuXing: (map['wuXing'] as String?) ?? '',
      naYin: (map['naYin'] as String?) ?? '',
      hideGan: ((map['hideGan'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList()),
      shiShenGan: (map['shiShenGan'] as String?) ?? '',
      shiShenZhi: ((map['shiShenZhi'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList()),
      diShi: (map['diShi'] as String?) ?? '',
    );
  }
}
