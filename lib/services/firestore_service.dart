import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/birth_input.dart';
import '../models/card_draw_result.dart';
import '../models/fortune_result.dart';
import '../models/precise_saju_result.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  BirthInput? _birthCache;
  final Map<String, FortuneResult> _memoryFortunes = <String, FortuneResult>{};
  final Map<String, CardDrawResult> _memoryCardDraws =
      <String, CardDrawResult>{};
  final Map<String, PreciseSajuResult> _memoryPreciseResults =
      <String, PreciseSajuResult>{};

  bool get _useFirebase => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _birthDoc(String uid) {
    return _db.collection('users').doc(uid).collection('profile').doc('birth');
  }

  DocumentReference<Map<String, dynamic>> _fortuneDoc(
    String uid,
    String dateKey,
  ) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('fortuneHistory')
        .doc(dateKey);
  }

  DocumentReference<Map<String, dynamic>> _cardDoc(String uid, String dateKey) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cardDraws')
        .doc(dateKey);
  }

  DocumentReference<Map<String, dynamic>> _preciseDoc(
    String uid,
    String unlockSignature,
  ) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('preciseSaju')
        .doc(_docKey(unlockSignature));
  }

  Future<void> saveBirthInput(String? uid, BirthInput input) async {
    _birthCache = input;
    if (!_useFirebase || uid == null) {
      return;
    }
    await _birthDoc(uid).set(<String, dynamic>{
      ...input.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<BirthInput?> getBirthInput(String? uid) async {
    if (!_useFirebase || uid == null) {
      return _birthCache;
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _birthDoc(
      uid,
    ).get();
    if (!snapshot.exists) {
      return _birthCache;
    }
    final BirthInput input = BirthInput.fromMap(snapshot.data()!);
    _birthCache = input;
    return input;
  }

  Future<void> saveFortune(String? uid, FortuneResult result) async {
    _memoryFortunes[result.dateKey] = result;
    if (!_useFirebase || uid == null) {
      return;
    }
    await _fortuneDoc(uid, result.dateKey).set(<String, dynamic>{
      ...result.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<FortuneResult?> getFortune(String? uid, String dateKey) async {
    if (!_useFirebase || uid == null) {
      return _memoryFortunes[dateKey];
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _fortuneDoc(
      uid,
      dateKey,
    ).get();
    if (!snapshot.exists) {
      return _memoryFortunes[dateKey];
    }
    final FortuneResult result = FortuneResult.fromMap(snapshot.data()!);
    _memoryFortunes[dateKey] = result;
    return result;
  }

  Future<void> saveCardDraw(String? uid, CardDrawResult result) async {
    _memoryCardDraws[result.dateKey] = result;
    if (!_useFirebase || uid == null) {
      return;
    }
    await _cardDoc(uid, result.dateKey).set(<String, dynamic>{
      ...result.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<CardDrawResult?> getCardDraw(String? uid, String dateKey) async {
    if (!_useFirebase || uid == null) {
      return _memoryCardDraws[dateKey];
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _cardDoc(
      uid,
      dateKey,
    ).get();
    if (!snapshot.exists) {
      return _memoryCardDraws[dateKey];
    }
    final CardDrawResult result = CardDrawResult.fromMap(snapshot.data()!);
    _memoryCardDraws[dateKey] = result;
    return result;
  }

  Future<void> savePreciseSaju(String? uid, PreciseSajuResult result) async {
    _memoryPreciseResults[result.unlockSignature] = result;
    if (!_useFirebase || uid == null) {
      return;
    }
    await _preciseDoc(uid, result.unlockSignature).set(<String, dynamic>{
      ...result.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<PreciseSajuResult?> getPreciseSaju(
    String? uid,
    String unlockSignature,
  ) async {
    if (!_useFirebase || uid == null) {
      return _memoryPreciseResults[unlockSignature];
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _preciseDoc(
      uid,
      unlockSignature,
    ).get();
    if (!snapshot.exists) {
      return _memoryPreciseResults[unlockSignature];
    }
    final PreciseSajuResult result = PreciseSajuResult.fromMap(
      snapshot.data()!,
    );
    _memoryPreciseResults[unlockSignature] = result;
    return result;
  }

  String _docKey(String raw) {
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }
}
