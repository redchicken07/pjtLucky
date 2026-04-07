import 'package:flutter/material.dart';

import '../logic/cards_logic.dart';
import '../models/card_draw_result.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
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
    final CardDrawResult? result = await FirestoreService.instance.getCardDraw(
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
    await FirestoreService.instance.saveCardDraw(uid, result);

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
                    ? '오늘 카드가 아직 없습니다. 아래 버튼으로 한 번 뽑아보세요.'
                    : '오늘 카드는 이미 생성되었습니다. 같은 날짜에는 같은 카드 결과를 보여줍니다.',
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
                '좋고 나쁨을 단정하기보다 애매한 흐름과 신호를 읽는 톤으로 설계했습니다. '
                '같은 사용자와 같은 날짜에는 항상 같은 번호가 나옵니다.',
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
