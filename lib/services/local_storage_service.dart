import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/birth_input.dart';
import '../models/card_draw_result.dart';
import '../models/fortune_result.dart';
import '../models/precise_saju_result.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  static const String _birthKey = 'profile.birth';
  static const String _fortunePrefix = 'fortune.';
  static const String _cardPrefix = 'card.';
  static const String _precisePrefix = 'precise.';

  Future<void> saveBirthInput(BirthInput input) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthKey, jsonEncode(input.toMap()));
  }

  Future<BirthInput?> getBirthInput() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_birthKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return BirthInput.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>),
    );
  }

  Future<void> saveFortune(FortuneResult result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_fortunePrefix${result.dateKey}',
      jsonEncode(result.toMap()),
    );
  }

  Future<FortuneResult?> getFortune(String dateKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('$_fortunePrefix$dateKey');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return FortuneResult.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>),
    );
  }

  Future<void> saveCardDraw(CardDrawResult result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_cardPrefix${result.dateKey}',
      jsonEncode(result.toMap()),
    );
  }

  Future<CardDrawResult?> getCardDraw(String dateKey) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('$_cardPrefix$dateKey');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return CardDrawResult.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>),
    );
  }

  Future<void> savePreciseSaju(PreciseSajuResult result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_precisePrefix${_docKey(result.unlockSignature)}',
      jsonEncode(result.toMap()),
    );
  }

  Future<PreciseSajuResult?> getPreciseSaju(String unlockSignature) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(
      '$_precisePrefix${_docKey(unlockSignature)}',
    );
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return PreciseSajuResult.fromMap(
      Map<String, dynamic>.from(jsonDecode(raw) as Map<dynamic, dynamic>),
    );
  }

  String _docKey(String raw) {
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }
}
