import 'birth_input.dart';
import 'profile_options.dart';

export 'profile_options.dart';

class PreciseSajuInput {
  const PreciseSajuInput({
    required this.calendarType,
    required this.timePrecision,
    this.isLeapMonth,
    this.exactHour,
    this.exactMinute,
    this.timeBranchSlot,
  });

  final CalendarType calendarType;
  final bool? isLeapMonth;
  final TimePrecision timePrecision;
  final int? exactHour;
  final int? exactMinute;
  final TimeBranchSlot? timeBranchSlot;

  bool get isLunar => calendarType == CalendarType.lunar;

  int get resolvedHour => timePrecision == TimePrecision.exact
      ? (exactHour ?? 12)
      : timePrecision == TimePrecision.branch
      ? (timeBranchSlot ?? TimeBranchSlot.wu).resolvedHour
      : 12;

  int get resolvedMinute => timePrecision == TimePrecision.exact
      ? (exactMinute ?? 0)
      : timePrecision == TimePrecision.branch
      ? (timeBranchSlot ?? TimeBranchSlot.wu).resolvedMinute
      : 0;

  String get basisLabel {
    final String calendarLabel = calendarType.label;
    if (timePrecision == TimePrecision.exact) {
      return '$calendarLabel · 정확한 시각 기준';
    }
    if (timePrecision == TimePrecision.unknown) {
      return '$calendarLabel · 출생 시간 미상 기준';
    }
    final TimeBranchSlot slot = timeBranchSlot ?? TimeBranchSlot.wu;
    return '$calendarLabel · ${slot.label} 기준 간이 판독';
  }

  String get timeDisplayLabel {
    if (timePrecision == TimePrecision.exact) {
      final String hourLabel = (exactHour ?? 12).toString().padLeft(2, '0');
      final String minuteLabel = (exactMinute ?? 0).toString().padLeft(2, '0');
      return '$hourLabel:$minuteLabel';
    }
    if (timePrecision == TimePrecision.unknown) {
      return '시간 미상';
    }
    final TimeBranchSlot slot = timeBranchSlot ?? TimeBranchSlot.wu;
    return '${slot.label} ${slot.rangeLabel}';
  }

  String get signature =>
      '${calendarType.key}-${isLeapMonth == true ? 'leap' : 'plain'}'
      '-${timePrecision.key}-${timePrecision == TimePrecision.exact
          ? timeDisplayLabel
          : timePrecision == TimePrecision.branch
          ? (timeBranchSlot ?? TimeBranchSlot.wu).key
          : 'unknown'}';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'calendarType': calendarType.key,
      'isLeapMonth': isLeapMonth,
      'timePrecision': timePrecision.key,
      'exactHour': exactHour,
      'exactMinute': exactMinute,
      'timeBranchSlot': timeBranchSlot?.key,
    };
  }

  factory PreciseSajuInput.fromMap(Map<String, dynamic> map) {
    return PreciseSajuInput(
      calendarType: CalendarType.fromKey(map['calendarType'] as String?),
      isLeapMonth: map['isLeapMonth'] as bool?,
      timePrecision: TimePrecision.fromKey(map['timePrecision'] as String?),
      exactHour: _asNullableInt(map['exactHour']),
      exactMinute: _asNullableInt(map['exactMinute']),
      timeBranchSlot: map['timeBranchSlot'] == null
          ? null
          : TimeBranchSlot.fromKey(map['timeBranchSlot'] as String?),
    );
  }

  factory PreciseSajuInput.defaultForBirth(BirthInput input) {
    return PreciseSajuInput(
      calendarType: input.calendarType,
      isLeapMonth: input.isLunar ? input.isLeapMonth : null,
      timePrecision: input.hasKnownTime
          ? TimePrecision.exact
          : input.timePrecision == TimePrecision.branch
          ? TimePrecision.branch
          : TimePrecision.unknown,
      exactHour: input.hour,
      exactMinute: input.minute,
      timeBranchSlot:
          input.timeBranchSlot ?? TimeBranchSlot.fromHour(input.hour),
    );
  }

  static int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}
