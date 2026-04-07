import '../logic/fortune_logic.dart';
import '../models/birth_input.dart';
import '../models/card_draw_result.dart';
import '../models/fortune_result.dart';
import '../models/precise_saju_result.dart';
import '../utils/date_utils.dart';
import 'firestore_service.dart';
import 'local_storage_service.dart';

class AppRepository {
  AppRepository._();

  static final AppRepository instance = AppRepository._();

  final LocalStorageService _local = LocalStorageService.instance;
  final FirestoreService _remote = FirestoreService.instance;

  Future<BirthInput?> getBirthInput(String? uid) async {
    final BirthInput? local = await _local.getBirthInput();
    final BirthInput? remote = await _remote.getBirthInput(uid);
    if (remote != null) {
      await _local.saveBirthInput(remote);
      return remote;
    }
    return local;
  }

  Future<void> saveBirthInput(String? uid, BirthInput input) async {
    await _local.saveBirthInput(input);
    await _remote.saveBirthInput(uid, input);
  }

  Future<FortuneResult?> getFortune(String? uid, String dateKey) async {
    final FortuneResult? local = await _local.getFortune(dateKey);
    final FortuneResult? remote = await _remote.getFortune(uid, dateKey);
    if (remote != null) {
      await _local.saveFortune(remote);
      return remote;
    }
    return local;
  }

  Future<void> saveFortune(String? uid, FortuneResult result) async {
    await _local.saveFortune(result);
    await _remote.saveFortune(uid, result);
  }

  Future<CardDrawResult?> getCardDraw(String? uid, String dateKey) async {
    final CardDrawResult? local = await _local.getCardDraw(dateKey);
    final CardDrawResult? remote = await _remote.getCardDraw(uid, dateKey);
    if (remote != null) {
      await _local.saveCardDraw(remote);
      return remote;
    }
    return local;
  }

  Future<void> saveCardDraw(String? uid, CardDrawResult result) async {
    await _local.saveCardDraw(result);
    await _remote.saveCardDraw(uid, result);
  }

  Future<PreciseSajuResult?> getPreciseSaju(
    String? uid,
    String unlockSignature,
  ) async {
    final PreciseSajuResult? local = await _local.getPreciseSaju(
      unlockSignature,
    );
    final PreciseSajuResult? remote = await _remote.getPreciseSaju(
      uid,
      unlockSignature,
    );
    if (remote != null) {
      await _local.savePreciseSaju(remote);
      return remote;
    }
    return local;
  }

  Future<void> savePreciseSaju(String? uid, PreciseSajuResult result) async {
    await _local.savePreciseSaju(result);
    await _remote.savePreciseSaju(uid, result);
  }

  Future<FortuneResult> ensureTodayFortune({
    required String? uid,
    required BirthInput birthInput,
    required DateTime now,
  }) async {
    final String dateKey = AppDateUtils.dayKey(now);
    final FortuneResult? existing = await getFortune(uid, dateKey);
    if (existing != null && existing.luckyNumbers.length == 3) {
      return existing;
    }

    final FortuneResult rebuilt = await FortuneLogic.buildTodayFortuneFromBirth(
      birthInput,
      now,
    );
    await saveFortune(uid, rebuilt);
    return rebuilt;
  }
}
