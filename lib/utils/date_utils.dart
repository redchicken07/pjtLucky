import 'package:intl/intl.dart';

class AppDateUtils {
  static String dayKey(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  static String dateLabel(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  static String timeLabel(int? hour, int? minute) {
    if (hour == null || minute == null) {
      return '시간 미상';
    }
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
