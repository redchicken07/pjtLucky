import 'package:flutter/material.dart';

class LuckyNumbersBox extends StatelessWidget {
  const LuckyNumbersBox({
    super.key,
    required this.numbers,
    required this.headline,
    required this.message,
  });

  final List<int> numbers;
  final String headline;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('오늘 럭키번호', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(headline, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: numbers
                  .map((int number) => _LuckyNumberChip(number: number))
                  .toList(),
            ),
            const SizedBox(height: 14),
            Text(message, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _LuckyNumberChip extends StatelessWidget {
  const _LuckyNumberChip({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
