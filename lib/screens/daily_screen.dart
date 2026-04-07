import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/birth_input.dart';
import '../models/fortune_result.dart';
import '../services/app_repository.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../widgets/app_button.dart';
import '../widgets/fortune_box.dart';
import '../widgets/lucky_numbers_box.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  bool _loading = true;
  BirthInput? _profile;
  FortuneResult? _fortune;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    await FirebaseInit.initialize();
    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    final BirthInput? profile = await AppRepository.instance.getBirthInput(uid);

    FortuneResult? fortune;
    if (profile != null) {
      fortune = await AppRepository.instance.ensureTodayFortune(
        uid: uid,
        birthInput: profile,
        now: DateTime.now(),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _profile = profile;
      _fortune = fortune;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘 운세')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_profile == null) ...<Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '먼저 프로필을 저장하면 오늘 운세와 럭키번호를 자동으로 불러옵니다.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: '프로필 입력하기',
                icon: Icons.badge_outlined,
                onPressed: () => context.push('/profile'),
              ),
            ] else if (_fortune != null) ...<Widget>[
              FortuneBox(fortune: _fortune!),
              const SizedBox(height: 16),
              LuckyNumbersBox(
                numbers: _fortune!.luckyNumbers,
                headline: _fortune!.luckyNumbersHeadline,
                message: _fortune!.luckyNumbersMessage,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: '사주 결과 보기',
                icon: Icons.auto_awesome,
                onPressed: () => context.push('/saju'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
