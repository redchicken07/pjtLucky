import 'package:flutter/material.dart';

import '../models/card_draw_result.dart';

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.result});

  final CardDrawResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('오늘의 카드', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(result.headline, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('카드 번호 ${result.cardNumber}'),
            const SizedBox(height: 12),
            Text(
              '좋다/나쁘다를 단정하기보다 오늘의 흐름을 읽는 카드입니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(result.message, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
