import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/precise_saju_logic.dart';
import '../logic/saju_logic.dart';
import '../models/birth_input.dart';
import '../models/precise_saju_input.dart';
import '../models/precise_saju_result.dart';
import '../models/saju_result.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../services/firestore_service.dart';
import '../services/reward_unlock_service.dart';
import '../widgets/app_button.dart';
import '../widgets/precise_saju_box.dart';
import '../widgets/precise_saju_input_sheet.dart';
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
    final BirthInput? input = await FirestoreService.instance.getBirthInput(
      uid,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _uid = uid;
      _birthInput = input;
      _result =
          widget.initialResult ??
          (input == null ? null : SajuLogic.calculate(input));
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

    final PreciseSajuInput? preciseInput = await showPreciseSajuInputSheet(
      context: context,
      birthInput: birthInput,
      initialValue: _preciseResult?.input,
    );
    if (preciseInput == null) {
      return;
    }

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

      final PreciseSajuResult? cached = await FirestoreService.instance
          .getPreciseSaju(_uid, unlockSignature);
      final PreciseSajuResult result =
          cached ?? PreciseSajuLogic.calculate(birthInput, preciseInput);
      if (cached == null) {
        await FirestoreService.instance.savePreciseSaju(_uid, result);
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
              label: '생년월일 입력으로 이동',
              icon: Icons.edit_calendar,
              onPressed: () => context.push('/birth'),
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
                      '여기서는 연주·월주·일주·시주와 오행 균형을 더 깊게 읽습니다. '
                      '양력/음력 여부와 시각 정밀도만 추가로 받으면 현재 입력값 기준으로 바로 계산할 수 있습니다.',
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
                          ? '정밀 사주 보기'
                          : '정밀 입력 다시 설정',
                      icon: Icons.tune,
                      onPressed: _preciseLoading ? null : _openPreciseSaju,
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
