import 'package:flutter/material.dart';

import '../logic/cards_logic.dart';
import '../models/card_draw_result.dart';
import '../services/app_repository.dart';
import '../services/auth_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/card_box.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  CardDrawResult? _result;
  bool _loading = true;
  bool _drawing = false;

  @override
  void initState() {
    super.initState();
    _loadTodayCard();
  }

  Future<void> _loadTodayCard() async {
    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    final String todayKey = AppDateUtils.dayKey(DateTime.now());
    final CardDrawResult? result = await AppRepository.instance.getCardDraw(
      uid,
      todayKey,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _drawCard() async {
    setState(() {
      _drawing = true;
    });

    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    final CardDrawResult result = await CardsLogic.drawForDay(
      uid ?? 'guest',
      DateTime.now(),
    );
    await AppRepository.instance.saveCardDraw(uid, result);

    if (!mounted) {
      return;
    }

    setState(() {
      _result = result;
      _drawing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘 카드')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _result == null
                    ? '오늘 카드는 아직 없습니다. 오늘 운세와 별개로, 감정 결이나 애매한 흐름을 한 번 더 읽고 싶을 때 보는 카드입니다.'
                    : '오늘 카드는 이미 생성되었습니다. 같은 날짜에는 같은 카드 결과를 보여주고, 오늘 운세와는 별개로 감성적인 흐름 읽기에 가깝습니다.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '카드 시스템은 5개 슬롯 x 각 10개 표현을 조합해 총 100,000가지 결과를 만듭니다. '
                '오늘 운세가 명리 기반의 방향을 보여준다면, 오늘 카드는 그날의 분위기와 여운을 읽는 감성 카드에 가깝습니다. '
                '같은 사용자와 같은 날짜에는 항상 같은 카드가 나옵니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...<Widget>[
            if (_result != null) ...<Widget>[
              CardBox(result: _result!),
              const SizedBox(height: 16),
            ],
            AppButton(
              label: _drawing
                  ? '카드 생성 중...'
                  : _result == null
                  ? '오늘 10만 카드 뽑기'
                  : '오늘 카드 다시 보기',
              icon: Icons.style_outlined,
              onPressed: _drawing ? null : _drawCard,
            ),
          ],
        ],
      ),
    );
  }
}
