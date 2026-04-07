import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  static String dayKey(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  static String dateLabel(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  static String slashDateLabel(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String timeLabel(int? hour, int? minute) {
    if (hour == null || minute == null) {
      return '시간 미상';
    }
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String compactTimeLabel(int? hour, int? minute) {
    if (hour == null || minute == null) {
      return '';
    }
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static DateTime? parseSlashDate(String input) {
    final String normalized = input.trim();
    if (!RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(normalized)) {
      return null;
    }
    final List<String> parts = normalized.split('/');
    final int year = int.parse(parts[0]);
    final int month = int.parse(parts[1]);
    final int day = int.parse(parts[2]);
    final DateTime date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    if (date.isAfter(DateTime.now())) {
      return null;
    }
    return date;
  }

  static TimeOfDay? parseClockTime(String input) {
    final String normalized = input.trim();
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(normalized)) {
      return null;
    }
    final List<String> parts = normalized.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }
}
