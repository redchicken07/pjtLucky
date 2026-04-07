import 'package:flutter/material.dart';

import '../models/saju_result.dart';

class QuickSajuBox extends StatelessWidget {
  const QuickSajuBox({super.key, required this.result});

  final SajuResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> signals = <String>[
      '${result.dayMaster} 일간',
      result.strengthLabel,
      '${result.dominantElement} 강',
      '${result.supportElement} 보완',
      '${result.dominantTenGod} 결',
      result.yinYang,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('빠른 사주 요약', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              '일간, 월령, 시주 흐름을 압축해 읽은 무료 사주입니다. 먼저 구조를 보고, 그 다음 해석을 읽는 흐름으로 구성했습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(result.headline, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: signals
                  .map((String item) => _SignalChip(label: item))
                  .toList(),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int columns = constraints.maxWidth >= 720 ? 3 : 2;
                final double spacing = 10;
                final double itemWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                    columns;

                final List<_QuickFact> facts = <_QuickFact>[
                  _QuickFact('일간', '${result.dayMaster} · ${result.element}'),
                  _QuickFact('연주', result.yearPillar),
                  _QuickFact('월령', result.monthFlow),
                  _QuickFact('시주', result.timeBranch),
                  _QuickFact('강한 기운', result.dominantElement),
                  _QuickFact('보완 기운', result.supportElement),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: facts
                      .map(
                        (_QuickFact fact) => SizedBox(
                          width: itemWidth,
                          child: _QuickFactCard(fact: fact),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 18),
            _ReadingSection(title: '겉으로 읽히는 결', body: result.surfaceReading),
            const SizedBox(height: 14),
            _ReadingSection(title: '안쪽에서 움직이는 힘', body: result.innerReading),
            const SizedBox(height: 14),
            _ReadingSection(title: '일의 흐름', body: result.workReading),
            const SizedBox(height: 14),
            _ReadingSection(title: '관계의 흐름', body: result.relationshipReading),
            const SizedBox(height: 14),
            _ReadingSection(title: '균형 포인트', body: result.balanceAdvice),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('한 번에 보는 핵심', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(result.summary, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  Text(
                    '우세 십신 ${result.dominantTenGod} · 월간 ${result.monthTenGod} · 시주 ${result.timeTenGod} · 행운색 ${result.luckyColor} · 기운 점수 ${result.energyScore}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFact {
  const _QuickFact(this.label, this.value);

  final String label;
  final String value;
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.primaryContainer,
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuickFactCard extends StatelessWidget {
  const _QuickFactCard({required this.fact});

  final _QuickFact fact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            fact.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(fact.value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ReadingSection extends StatelessWidget {
  const _ReadingSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
