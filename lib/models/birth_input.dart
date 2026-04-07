class BirthInput {
  const BirthInput({
    required this.year,
    required this.month,
    required this.day,
    required this.gender,
    this.hour,
    this.minute,
  });

  final int year;
  final int month;
  final int day;
  final int? hour;
  final int? minute;
  final String gender;

  bool get hasKnownTime => hour != null && minute != null;

  String get signature =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'
      '-$gender-${hour?.toString().padLeft(2, '0') ?? 'xx'}'
      '-${minute?.toString().padLeft(2, '0') ?? 'xx'}';

  DateTime get birthDateTime =>
      DateTime(year, month, day, hour ?? 12, minute ?? 0);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'gender': gender,
    };
  }

  factory BirthInput.fromMap(Map<String, dynamic> map) {
    return BirthInput(
      year: _asInt(map['year']),
      month: _asInt(map['month']),
      day: _asInt(map['day']),
      hour: _asNullableInt(map['hour']),
      minute: _asNullableInt(map['minute']),
      gender: (map['gender'] as String?) ?? '미선택',
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

  static int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return _asInt(value);
  }
}
