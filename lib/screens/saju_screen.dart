import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/precise_saju_logic.dart';
import '../models/precise_saju_input.dart';
import '../logic/saju_logic.dart';
import '../models/birth_input.dart';
import '../models/precise_saju_result.dart';
import '../models/saju_result.dart';
import '../services/app_repository.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../services/reward_unlock_service.dart';
import '../widgets/app_button.dart';
import '../widgets/precise_saju_box.dart';
import '../widgets/quick_saju_box.dart';

class SajuScreen extends StatefulWidget {
  const SajuScreen({super.key, this.initialResult});

  final SajuResult? initialResult;

  @override
  State<SajuScreen> createState() => _SajuScreenState();
}

class _SajuScreenState extends State<SajuScreen> {
  SajuResult? _result;
  BirthInput? _birthInput;
  PreciseSajuResult? _preciseResult;
  bool _loading = true;
  bool _preciseLoading = false;
  String? _uid;
  String? _preciseError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await FirebaseInit.initialize();
    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    final BirthInput? input = await AppRepository.instance.getBirthInput(uid);

    if (!mounted) {
      return;
    }

    setState(() {
      _uid = uid;
      _birthInput = input;
      _result = input == null
          ? widget.initialResult
          : SajuLogic.calculate(input);
      if (_preciseResult?.birthSignature != input?.signature) {
        _preciseResult = null;
      }
      _loading = false;
    });
  }

  Future<void> _openPreciseSaju() async {
    final BirthInput? birthInput = _birthInput;
    if (birthInput == null) {
      return;
    }

    final PreciseSajuInput preciseInput = PreciseSajuInput.defaultForBirth(
      birthInput,
    );

    final String unlockSignature =
        '${birthInput.signature}|${preciseInput.signature}';
    setState(() {
      _preciseLoading = true;
      _preciseError = null;
    });

    try {
      final RewardUnlockService unlockService = RewardUnlockRegistry.instance;
      final bool alreadyUnlocked = await unlockService.isUnlocked(
        unlockSignature,
      );
      final bool unlocked =
          alreadyUnlocked || await unlockService.requestUnlock(unlockSignature);
      if (!unlocked) {
        throw const FormatException('정밀 사주를 여는 과정이 완료되지 않았습니다.');
      }

      final PreciseSajuResult? cached = await AppRepository.instance
          .getPreciseSaju(_uid, unlockSignature);
      final PreciseSajuResult result =
          cached ?? PreciseSajuLogic.calculate(birthInput, preciseInput);
      if (cached == null) {
        await AppRepository.instance.savePreciseSaju(_uid, result);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _preciseResult = result;
        _preciseLoading = false;
      });
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preciseLoading = false;
        _preciseError = error.message;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preciseLoading = false;
        _preciseError = '정밀 사주를 불러오지 못했습니다. 입력값을 다시 확인해 주세요.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('정밀 사주를 불러오지 못했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사주 결과')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_result == null) ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '저장된 생년 정보가 없습니다. 먼저 생년월일을 입력하세요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: '사주 프로필 입력으로 이동',
              icon: Icons.edit_calendar,
              onPressed: () => context.push('/profile'),
            ),
          ] else ...<Widget>[
            QuickSajuBox(result: _result!),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '정밀 사주 확장',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '프로필에 저장된 양력/음력, 윤달 여부, 출생 시간 정밀도를 기준으로 '
                      '연주·월주·일주·시주와 오행 균형을 더 깊게 읽습니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_preciseError != null)
                      Text(
                        _preciseError!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (_preciseLoading) ...<Widget>[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 12),
                    AppButton(
                      label: _preciseResult == null
                          ? '저장된 프로필로 정밀 사주 보기'
                          : '정밀 사주 다시 계산',
                      icon: Icons.tune,
                      onPressed: _preciseLoading ? null : _openPreciseSaju,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        await context.push('/profile');
                        await _load();
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('프로필 정밀도 수정하기'),
                    ),
                  ],
                ),
              ),
            ),
            if (_preciseResult != null) ...<Widget>[
              const SizedBox(height: 16),
              PreciseSajuBox(result: _preciseResult!),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: '홈으로 돌아가기',
              icon: Icons.home_outlined,
              onPressed: () => context.go('/'),
            ),
          ],
        ],
      ),
    );
  }
}
