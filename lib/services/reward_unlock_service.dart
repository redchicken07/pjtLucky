abstract interface class RewardUnlockService {
  Future<bool> isUnlocked(String signature);

  Future<bool> requestUnlock(String signature);

  Future<void> clear(String signature);
}

class AlwaysUnlockedRewardUnlockService implements RewardUnlockService {
  const AlwaysUnlockedRewardUnlockService();

  @override
  Future<bool> isUnlocked(String signature) async => true;

  @override
  Future<bool> requestUnlock(String signature) async => true;

  @override
  Future<void> clear(String signature) async {}
}

class RewardUnlockRegistry {
  static RewardUnlockService instance =
      const AlwaysUnlockedRewardUnlockService();
}
