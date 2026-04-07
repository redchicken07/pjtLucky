class FortuneResult {
  const FortuneResult({
    required this.dateKey,
    required this.score,
    required this.overallLabel,
    required this.title,
    required this.message,
    required this.detailMessage,
    required this.focus,
    required this.signals,
    required this.categoryScores,
    required this.categoryNarratives,
  });

  final String dateKey;
  final int score;
  final String overallLabel;
  final String title;
  final String message;
  final String detailMessage;
  final String focus;
  final List<String> signals;
  final Map<String, int> categoryScores;
  final Map<String, String> categoryNarratives;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'score': score,
      'overallLabel': overallLabel,
      'title': title,
      'message': message,
      'detailMessage': detailMessage,
      'focus': focus,
      'signals': signals,
      'categoryScores': categoryScores,
      'categoryNarratives': categoryNarratives,
    };
  }

  factory FortuneResult.fromMap(Map<String, dynamic> map) {
    return FortuneResult(
      dateKey: (map['dateKey'] as String?) ?? '',
      score: _asInt(map['score']),
      overallLabel: (map['overallLabel'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      detailMessage: (map['detailMessage'] as String?) ?? '',
      focus: (map['focus'] as String?) ?? '',
      signals: ((map['signals'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList()),
      categoryScores: _asScoreMap(map['categoryScores']),
      categoryNarratives: _asTextMap(map['categoryNarratives']),
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

  static Map<String, int> _asScoreMap(Object? value) {
    if (value is! Map) {
      return <String, int>{};
    }
    return value.map<String, int>((Object? key, Object? rawValue) {
      return MapEntry<String, int>(key.toString(), _asInt(rawValue));
    });
  }

  static Map<String, String> _asTextMap(Object? value) {
    if (value is! Map) {
      return <String, String>{};
    }
    return value.map<String, String>((Object? key, Object? rawValue) {
      return MapEntry<String, String>(
        key.toString(),
        rawValue?.toString() ?? '',
      );
    });
  }
}
