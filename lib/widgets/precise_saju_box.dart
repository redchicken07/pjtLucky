import 'package:flutter/material.dart';

import '../models/precise_pillar.dart';
import '../models/precise_saju_result.dart';

class PreciseSajuBox extends StatelessWidget {
  const PreciseSajuBox({super.key, required this.result});

  final PreciseSajuResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('정밀 사주', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              result.basisLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(result.solarLabel),
            Text(result.lunarLabel),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text('일간 ${result.dayMaster}')),
                Chip(label: Text('강약 ${result.strengthLabel}')),
                Chip(label: Text(result.mingGongLabel)),
                Chip(label: Text(result.shenGongLabel)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.taiYuanLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              result.taiXiLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.elementBalance.entries
                  .map(
                    (MapEntry<String, int> entry) =>
                        Chip(label: Text('${entry.key} ${entry.value}')),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            _NarrativeSection(title: '명식 포인트', body: result.chartSummary),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: result.fourPillars
                  .map((PrecisePillar pillar) => _PillarTile(pillar: pillar))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _NarrativeSection(title: '핵심 성향', body: result.coreNarrative),
            const SizedBox(height: 16),
            _NarrativeSection(title: '일의 패턴', body: result.workNarrative),
            const SizedBox(height: 16),
            _NarrativeSection(
              title: '관계의 패턴',
              body: result.relationshipNarrative,
            ),
            const SizedBox(height: 16),
            _NarrativeSection(title: '주의 포인트', body: result.riskNarrative),
            const SizedBox(height: 12),
            Text(
              result.timingNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillarTile extends StatelessWidget {
  const _PillarTile({required this.pillar});

  final PrecisePillar pillar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(pillar.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            '${pillar.ganZhi} · ${pillar.reading}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text('오행 ${pillar.wuXing}'),
          Text('납음 ${pillar.naYin}'),
          Text(
            '지장간 ${pillar.hideGan.isEmpty ? '-' : pillar.hideGan.join('·')}',
          ),
          Text('천간 십신 ${pillar.shiShenGan}'),
          Text(
            '지지 십신 ${pillar.shiShenZhi.isEmpty ? '-' : pillar.shiShenZhi.join('·')}',
          ),
          Text('12운성 ${pillar.diShi}'),
        ],
      ),
    );
  }
}

class _NarrativeSection extends StatelessWidget {
  const _NarrativeSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
