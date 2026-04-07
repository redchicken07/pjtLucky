import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/fortune_logic.dart';
import '../logic/saju_logic.dart';
import '../models/birth_input.dart';
import '../models/fortune_result.dart';
import '../models/saju_result.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/fortune_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  BirthInput? _birthInput;
  SajuResult? _sajuResult;
  FortuneResult? _fortuneResult;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
    });

    await FirebaseInit.initialize();
    final String? uid = await AuthService.ensureSignedIn();
    final BirthInput? birthInput = await FirestoreService.instance
        .getBirthInput(uid);

    SajuResult? sajuResult;
    FortuneResult? fortuneResult;
    if (birthInput != null) {
      sajuResult = SajuLogic.calculate(birthInput);
      final String todayKey = AppDateUtils.dayKey(DateTime.now());
      fortuneResult = await FirestoreService.instance.getFortune(uid, todayKey);
      fortuneResult ??= await FortuneLogic.buildTodayFortuneFromBirth(
        birthInput,
        DateTime.now(),
      );
      await FirestoreService.instance.saveFortune(uid, fortuneResult);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _uid = uid;
      _birthInput = birthInput;
      _sajuResult = sajuResult;
      _fortuneResult = fortuneResult;
      _loading = false;
    });
  }

  Future<void> _openBirth() async {
    await context.push('/birth');
    await _loadDashboard();
  }

  Future<void> _openCards() async {
    await context.push('/cards');
    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fortune App')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '오늘의 시작',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '빠른 해석과 정밀 사주를 한 흐름에서 이어 볼 수 있게 2단 구조로 잡았습니다.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(FirebaseInit.statusMessage),
                      const SizedBox(height: 4),
                      Text('현재 UID: ${_uid ?? 'guest-mode'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...<Widget>[
                if (_birthInput != null) ...<Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '등록된 생년 정보',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppDateUtils.dateLabel(_birthInput!.birthDateTime)} '
                            '${AppDateUtils.timeLabel(_birthInput!.hour, _birthInput!.minute)}',
                          ),
                          Text('성별: ${_birthInput!.gender}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_fortuneResult != null)
                  FortuneBox(fortune: _fortuneResult!)
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _birthInput == null
                            ? '먼저 생년월일을 입력하면 오늘 운세가 생성됩니다.'
                            : '운세를 불러오는 중입니다.',
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                AppButton(
                  label: _birthInput == null ? '빠른 사주 입력하기' : '생년월일 다시 입력하기',
                  icon: Icons.edit_calendar,
                  onPressed: _openBirth,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: '사주 결과 보기',
                  icon: Icons.auto_awesome,
                  onPressed: _sajuResult == null
                      ? null
                      : () => context.push('/saju', extra: _sajuResult),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: '오늘 카드 뽑기',
                  icon: Icons.style_outlined,
                  onPressed: _openCards,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
