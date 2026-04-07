import 'profile_options.dart';

class BirthInput {
  const BirthInput({
    required this.year,
    required this.month,
    required this.day,
    required this.gender,
    this.name = '',
    this.calendarType = CalendarType.solar,
    this.timePrecision = TimePrecision.unknown,
    this.timeBranchSlot,
    this.isLeapMonth,
    this.hour,
    this.minute,
  });

  final int year;
  final int month;
  final int day;
  final int? hour;
  final int? minute;
  final String gender;
  final String name;
  final CalendarType calendarType;
  final TimePrecision timePrecision;
  final TimeBranchSlot? timeBranchSlot;
  final bool? isLeapMonth;

  bool get hasKnownTime => hour != null && minute != null;
  bool get hasName => name.trim().isNotEmpty;
  bool get isLunar => calendarType == CalendarType.lunar;
  bool get hasBranchTime =>
      timePrecision == TimePrecision.branch && timeBranchSlot != null;
  bool get hasPreciseProfile =>
      hasName ||
      calendarType == CalendarType.lunar ||
      timePrecision != TimePrecision.unknown ||
      timeBranchSlot != null;

  int get resolvedHour {
    if (hasKnownTime) {
      return hour!;
    }
    if (timePrecision == TimePrecision.branch && timeBranchSlot != null) {
      return timeBranchSlot!.resolvedHour;
    }
    return 12;
  }

  int get resolvedMinute {
    if (hasKnownTime) {
      return minute!;
    }
    if (timePrecision == TimePrecision.branch && timeBranchSlot != null) {
      return timeBranchSlot!.resolvedMinute;
    }
    return 0;
  }

  String get signature =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'
      '-$gender-${hour?.toString().padLeft(2, '0') ?? 'xx'}'
      '-${minute?.toString().padLeft(2, '0') ?? 'xx'}'
      '-${calendarType.key}-${timePrecision.key}-${timeBranchSlot?.key ?? 'none'}-${isLeapMonth == true ? 'leap' : 'plain'}';

  DateTime get birthDateTime =>
      DateTime(year, month, day, resolvedHour, resolvedMinute);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'gender': gender,
      'name': name,
      'calendarType': calendarType.key,
      'timePrecision': timePrecision.key,
      'timeBranchSlot': timeBranchSlot?.key,
      'isLeapMonth': isLeapMonth,
    };
  }

  factory BirthInput.fromMap(Map<String, dynamic> map) {
    final int? hour = _asNullableInt(map['hour']);
    final int? minute = _asNullableInt(map['minute']);
    final TimePrecision timePrecision = map['timePrecision'] == null
        ? (hour != null && minute != null
              ? TimePrecision.exact
              : TimePrecision.unknown)
        : TimePrecision.fromKey(map['timePrecision'] as String?);
    return BirthInput(
      year: _asInt(map['year']),
      month: _asInt(map['month']),
      day: _asInt(map['day']),
      hour: hour,
      minute: minute,
      gender: (map['gender'] as String?) ?? '미선택',
      name: (map['name'] as String?) ?? '',
      calendarType: CalendarType.fromKey(map['calendarType'] as String?),
      timePrecision: timePrecision,
      timeBranchSlot: map['timeBranchSlot'] == null
          ? null
          : TimeBranchSlot.fromKey(map['timeBranchSlot'] as String?),
      isLeapMonth: map['isLeapMonth'] as bool?,
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
