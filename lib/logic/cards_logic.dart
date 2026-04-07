import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/card_draw_result.dart';
import '../utils/date_utils.dart';

class CardsLogic {
  static const int slotCount = 5;
  static const int slotItemCount = 10;
  static const int totalCombinations = 100000;

  static List<List<String>>? _slots;

  static Future<CardDrawResult> drawForDay(
    String userSeed,
    DateTime now,
  ) async {
    final List<List<String>> slots = await _loadSlots();
    final int drawNumber = drawNumberForDay(userSeed, now);
    final List<int> slotIndexes = slotIndexesFromDrawNumber(drawNumber);
    final List<String> selectedTexts = List<String>.generate(
      slotCount,
      (int index) => slots[index][slotIndexes[index]],
    );

    return CardDrawResult(
      dateKey: AppDateUtils.dayKey(now),
      cardNumber: drawNumber.toString().padLeft(5, '0'),
      slotIndexes: slotIndexes,
      selectedTexts: selectedTexts,
      headline: '${selectedTexts[0]} ${selectedTexts[1]}',
      message: <String>[
        selectedTexts[2],
        selectedTexts[3],
        selectedTexts[4],
      ].join('\n\n'),
    );
  }

  static int drawNumberForDay(String userSeed, DateTime now) {
    final String source = '$userSeed-${AppDateUtils.dayKey(now)}';
    return (_stableHash(source) % totalCombinations) + 1;
  }

  static List<int> slotIndexesFromDrawNumber(int drawNumber) {
    if (drawNumber < 1 || drawNumber > totalCombinations) {
      throw RangeError.range(drawNumber, 1, totalCombinations, 'drawNumber');
    }

    int value = drawNumber - 1;
    final List<int> indexes = List<int>.filled(slotCount, 0);

    // 10^5 조합을 그대로 쓰기 위해 1~100000 번호를 5자리 base-10 슬롯으로 풀어낸다.
    for (int index = slotCount - 1; index >= 0; index--) {
      indexes[index] = value % slotItemCount;
      value ~/= slotItemCount;
    }

    return indexes;
  }

  static Future<List<List<String>>> _loadSlots() async {
    if (_slots != null) {
      return _slots!;
    }

    final List<List<String>> loaded = <List<String>>[];
    for (int slot = 1; slot <= slotCount; slot++) {
      final String raw = await rootBundle.loadString(
        'assets/content/cards/slot$slot.json',
      );
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      if (decoded.length != slotItemCount) {
        throw StateError(
          'slot$slot must contain exactly $slotItemCount entries.',
        );
      }
      loaded.add(decoded.map((dynamic value) => value.toString()).toList());
    }

    _slots = loaded;
    return loaded;
  }

  static int _stableHash(String source) {
    const int mod = 2147483647;
    int hash = 17;
    for (final int unit in source.codeUnits) {
      hash = (hash * 131 + unit) % mod;
    }
    return hash;
  }
}
