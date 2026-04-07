import 'package:flutter/material.dart';

import '../models/fortune_result.dart';

class FortuneBox extends StatelessWidget {
  const FortuneBox({super.key, required this.fortune});

  final FortuneResult fortune;
  static const List<_FortuneMetricMeta> _metricOrder = <_FortuneMetricMeta>[
    _FortuneMetricMeta('종합', Icons.pie_chart_outline),
    _FortuneMetricMeta('금전운', Icons.diamond_outlined),
    _FortuneMetricMeta('애정운', Icons.favorite_border),
    _FortuneMetricMeta('건강운', Icons.health_and_safety_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_FortuneMetric> metrics = _metricOrder
        .map(
          (_FortuneMetricMeta meta) => _FortuneMetric(
            meta.label,
            meta.icon,
            fortune.categoryScores[meta.label] ?? 0,
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('오늘의 운세', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(fortune.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              fortune.dateKey,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: fortune.score / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 8),
            Text('종합 점수 ${fortune.score}점'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metrics
                  .map(
                    (_FortuneMetric metric) =>
                        _FortuneMetricChip(metric: metric),
                  )
                  .toList(),
            ),
            if (fortune.signals.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fortune.signals
                    .map((String signal) => Chip(label: Text(signal)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(fortune.message, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(fortune.detailMessage, style: theme.textTheme.bodyLarge),
            if (fortune.categoryNarratives.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              ..._metricOrder.map(
                (_FortuneMetricMeta meta) => _FortuneNarrativeSection(
                  metric: _FortuneMetric(
                    meta.label,
                    meta.icon,
                    fortune.categoryScores[meta.label] ?? 0,
                  ),
                  narrative: fortune.categoryNarratives[meta.label] ?? '',
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              fortune.focus,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FortuneMetricMeta {
  const _FortuneMetricMeta(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _FortuneMetric {
  const _FortuneMetric(this.label, this.icon, this.score);

  final String label;
  final IconData icon;
  final int score;
}

class _FortuneNarrativeSection extends StatelessWidget {
  const _FortuneNarrativeSection({
    required this.metric,
    required this.narrative,
  });

  final _FortuneMetric metric;
  final String narrative;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(
                    metric.icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(metric.label, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  _scoreLabel(metric.score),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(narrative, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _FortuneMetricChip extends StatelessWidget {
  const _FortuneMetricChip({required this.metric});

  final _FortuneMetric metric;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 92,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 26,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Icon(metric.icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(metric.label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            _scoreLabel(metric.score),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _scoreLabel(int score) {
  if (score >= 80) {
    return '강세';
  }
  if (score >= 65) {
    return '상승';
  }
  if (score >= 45) {
    return '무난';
  }
  if (score >= 30) {
    return '유의';
  }
  return '주의';
}
