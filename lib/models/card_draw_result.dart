class CardDrawResult {
  const CardDrawResult({
    required this.dateKey,
    required this.cardNumber,
    required this.slotIndexes,
    required this.selectedTexts,
    required this.headline,
    required this.message,
  });

  final String dateKey;
  final String cardNumber;
  final List<int> slotIndexes;
  final List<String> selectedTexts;
  final String headline;
  final String message;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'cardNumber': cardNumber,
      'slotIndexes': slotIndexes,
      'selectedTexts': selectedTexts,
      'headline': headline,
      'message': message,
    };
  }

  factory CardDrawResult.fromMap(Map<String, dynamic> map) {
    return CardDrawResult(
      dateKey: (map['dateKey'] as String?) ?? '',
      cardNumber: (map['cardNumber'] as String?) ?? '',
      slotIndexes: ((map['slotIndexes'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic value) => value is num ? value.toInt() : 0)
          .toList()),
      selectedTexts: ((map['selectedTexts'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic value) => value.toString())
          .toList()),
      headline: (map['headline'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
    );
  }
}
