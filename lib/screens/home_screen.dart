import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/saju_logic.dart';
import '../models/birth_input.dart';
import '../models/card_draw_result.dart';
import '../models/fortune_result.dart';
import '../models/profile_options.dart';
import '../models/saju_result.dart';
import '../services/app_repository.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../utils/date_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/lucky_numbers_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  BirthInput? _profile;
  SajuResult? _sajuResult;
  FortuneResult? _fortuneResult;
  CardDrawResult? _cardResult;
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
    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    final BirthInput? profile = await AppRepository.instance.getBirthInput(uid);

    SajuResult? sajuResult;
    FortuneResult? fortuneResult;
    CardDrawResult? cardResult;
    if (profile != null) {
      sajuResult = _buildSaju(profile);
      fortuneResult = await AppRepository.instance.ensureTodayFortune(
        uid: uid,
        birthInput: profile,
        now: DateTime.now(),
      );
      cardResult = await AppRepository.instance.getCardDraw(
        uid,
        AppDateUtils.dayKey(DateTime.now()),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _uid = uid;
      _profile = profile;
      _sajuResult = sajuResult;
      _fortuneResult = fortuneResult;
      _cardResult = cardResult;
      _loading = false;
    });
  }

  SajuResult _buildSaju(BirthInput profile) {
    return SajuLogic.calculate(profile);
  }

  Future<void> _openProfile() async {
    await context.push('/profile');
    await _loadDashboard();
  }

  Future<void> _openCards() async {
    await context.push('/cards');
    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 사주')),
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
                        '대시보드',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _profile == null
                            ? '프로필을 저장하면 오늘 운세, 럭키번호, 사주 요약을 자동으로 불러옵니다.'
                            : '${_profile!.hasName ? '${_profile!.name}님, ' : ''}오늘의 사주 흐름과 감성 카드를 한 번에 볼 수 있도록 정리했습니다.',
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
              else if (_profile == null) ...<Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '사주 프로필이 아직 없습니다',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '이름, 생년월일, 달력 기준, 출생 시간 정밀도를 저장해 두면 다음부터 자동으로 불러옵니다.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: '사주 프로필 입력하기',
                  icon: Icons.badge_outlined,
                  onPressed: _openProfile,
                ),
              ] else ...<Widget>[
                _ProfileSummaryCard(
                  profile: _profile!,
                  sajuResult: _sajuResult,
                  onEdit: _openProfile,
                ),
                const SizedBox(height: 16),
                if (_fortuneResult != null)
                  _DailyOverviewCard(
                    fortune: _fortuneResult!,
                    onOpenDetail: () => context.push('/daily'),
                  ),
                const SizedBox(height: 16),
                if (_fortuneResult != null)
                  LuckyNumbersBox(
                    numbers: _fortuneResult!.luckyNumbers,
                    headline: _fortuneResult!.luckyNumbersHeadline,
                    message: _fortuneResult!.luckyNumbersMessage,
                  ),
                const SizedBox(height: 16),
                _CardPreviewCard(result: _cardResult, onOpenCards: _openCards),
                const SizedBox(height: 16),
                AppButton(
                  label: '빠른 사주 결과 보기',
                  icon: Icons.auto_awesome,
                  onPressed: _sajuResult == null
                      ? null
                      : () => context.push('/saju', extra: _sajuResult),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: '오늘 운세 자세히 보기',
                  icon: Icons.sunny_snowing,
                  onPressed: _fortuneResult == null
                      ? null
                      : () => context.push('/daily'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: '오늘 카드 보기',
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

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.profile,
    required this.sajuResult,
    required this.onEdit,
  });

  final BirthInput profile;
  final SajuResult? sajuResult;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('저장된 사주 프로필', style: theme.textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('수정'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              profile.hasName ? '${profile.name}님의 프로필' : '내 사주 프로필',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(
                  label: Text(
                    '${AppDateUtils.slashDateLabel(DateTime(profile.year, profile.month, profile.day))} · ${profile.gender}',
                  ),
                ),
                Chip(label: Text(profile.calendarType.label)),
                Chip(label: Text(profile.timePrecision.label)),
                if (profile.timePrecision == TimePrecision.branch &&
                    profile.timeBranchSlot != null)
                  Chip(label: Text(profile.timeBranchSlot!.label)),
                if (sajuResult != null)
                  Chip(label: Text(sajuResult!.dayMaster)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              sajuResult == null
                  ? '프로필이 저장되어 있습니다.'
                  : '${sajuResult!.strengthLabel} · ${sajuResult!.dominantElement} 강 · ${sajuResult!.supportElement} 보완',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyOverviewCard extends StatelessWidget {
  const _DailyOverviewCard({required this.fortune, required this.onOpenDetail});

  final FortuneResult fortune;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('오늘의 종합운', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(fortune.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: fortune.score / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 8),
            Text('종합 점수 ${fortune.score}점'),
            const SizedBox(height: 12),
            Text(fortune.message, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(
              fortune.focus,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: onOpenDetail,
                icon: const Icon(Icons.chevron_right),
                label: const Text('자세히 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPreviewCard extends StatelessWidget {
  const _CardPreviewCard({required this.result, required this.onOpenCards});

  final CardDrawResult? result;
  final VoidCallback onOpenCards;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('오늘 카드', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              result == null ? '오늘 카드를 아직 뽑지 않았습니다.' : result!.headline,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              result == null
                  ? '운세와 별개로, 오늘의 감정 결이나 흐름을 한 번 더 읽는 카드입니다.'
                  : result!.message.split('\n').first,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: onOpenCards,
                icon: const Icon(Icons.style_outlined),
                label: Text(result == null ? '오늘 카드 보러가기' : '전체 카드 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
