enum CalendarType {
  solar('solar', '양력'),
  lunar('lunar', '음력');

  const CalendarType(this.key, this.label);

  final String key;
  final String label;

  static CalendarType fromKey(String? key) {
    return values.firstWhere(
      (CalendarType value) => value.key == key,
      orElse: () => CalendarType.solar,
    );
  }
}

enum TimePrecision {
  exact('exact', '정확한 시각'),
  branch('branch', '시지 단위'),
  unknown('unknown', '모름');

  const TimePrecision(this.key, this.label);

  final String key;
  final String label;

  static TimePrecision fromKey(String? key) {
    return values.firstWhere(
      (TimePrecision value) => value.key == key,
      orElse: () => TimePrecision.unknown,
    );
  }
}

enum TimeBranchSlot {
  zi('zi', '자시', '子', '23:00~00:59', 0, 30),
  chou('chou', '축시', '丑', '01:00~02:59', 2, 0),
  yin('yin', '인시', '寅', '03:00~04:59', 4, 0),
  mao('mao', '묘시', '卯', '05:00~06:59', 6, 0),
  chen('chen', '진시', '辰', '07:00~08:59', 8, 0),
  si('si', '사시', '巳', '09:00~10:59', 10, 0),
  wu('wu', '오시', '午', '11:00~12:59', 12, 0),
  wei('wei', '미시', '未', '13:00~14:59', 14, 0),
  shen('shen', '신시', '申', '15:00~16:59', 16, 0),
  you('you', '유시', '酉', '17:00~18:59', 18, 0),
  xu('xu', '술시', '戌', '19:00~20:59', 20, 0),
  hai('hai', '해시', '亥', '21:00~22:59', 22, 0);

  const TimeBranchSlot(
    this.key,
    this.label,
    this.hanja,
    this.rangeLabel,
    this.resolvedHour,
    this.resolvedMinute,
  );

  final String key;
  final String label;
  final String hanja;
  final String rangeLabel;
  final int resolvedHour;
  final int resolvedMinute;

  String get displayLabel => '$label $hanja $rangeLabel';

  static TimeBranchSlot fromKey(String? key) {
    return values.firstWhere(
      (TimeBranchSlot value) => value.key == key,
      orElse: () => TimeBranchSlot.wu,
    );
  }

  static TimeBranchSlot fromHour(int? hour) {
    if (hour == null) {
      return TimeBranchSlot.wu;
    }
    if (hour == 23 || hour == 0) {
      return TimeBranchSlot.zi;
    }
    return values[(hour + 1) ~/ 2];
  }
}
