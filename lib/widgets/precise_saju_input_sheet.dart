import 'package:flutter/material.dart';

import '../models/birth_input.dart';
import '../models/precise_saju_input.dart';
import '../utils/date_utils.dart';

Future<PreciseSajuInput?> showPreciseSajuInputSheet({
  required BuildContext context,
  required BirthInput birthInput,
  PreciseSajuInput? initialValue,
}) {
  return showModalBottomSheet<PreciseSajuInput>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return PreciseSajuInputSheet(
        birthInput: birthInput,
        initialValue: initialValue,
      );
    },
  );
}

class PreciseSajuInputSheet extends StatefulWidget {
  const PreciseSajuInputSheet({
    super.key,
    required this.birthInput,
    this.initialValue,
  });

  final BirthInput birthInput;
  final PreciseSajuInput? initialValue;

  @override
  State<PreciseSajuInputSheet> createState() => _PreciseSajuInputSheetState();
}

class _PreciseSajuInputSheetState extends State<PreciseSajuInputSheet> {
  late CalendarType _calendarType;
  late TimePrecision _timePrecision;
  late bool _isLeapMonth;
  late int _exactHour;
  late int _exactMinute;
  late TimeBranchSlot _timeBranchSlot;

  @override
  void initState() {
    super.initState();
    final PreciseSajuInput? initial = widget.initialValue;
    _calendarType = initial?.calendarType ?? CalendarType.solar;
    _timePrecision =
        initial?.timePrecision ??
        (widget.birthInput.hasKnownTime
            ? TimePrecision.exact
            : widget.birthInput.timePrecision);
    _isLeapMonth = initial?.isLeapMonth ?? false;
    _exactHour = initial?.exactHour ?? widget.birthInput.hour ?? 12;
    _exactMinute = initial?.exactMinute ?? widget.birthInput.minute ?? 0;
    _timeBranchSlot =
        initial?.timeBranchSlot ??
        TimeBranchSlot.fromHour(widget.birthInput.hour);
  }

  Future<void> _pickExactTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _exactHour, minute: _exactMinute),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _exactHour = picked.hour;
      _exactMinute = picked.minute;
    });
  }

  void _submit() {
    Navigator.of(context).pop(
      PreciseSajuInput(
        calendarType: _calendarType,
        isLeapMonth: _calendarType == CalendarType.lunar ? _isLeapMonth : null,
        timePrecision: _timePrecision,
        exactHour: _timePrecision == TimePrecision.exact ? _exactHour : null,
        exactMinute: _timePrecision == TimePrecision.exact
            ? _exactMinute
            : null,
        timeBranchSlot: _timePrecision == TimePrecision.branch
            ? _timeBranchSlot
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets bottomInset = EdgeInsets.only(
      bottom: MediaQuery.viewInsetsOf(context).bottom,
    );

    return SafeArea(
      child: Padding(
        padding: bottomInset,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '정밀 사주 설정',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '기본 정보는 ${AppDateUtils.dateLabel(widget.birthInput.birthDateTime)} ${widget.birthInput.gender}로 고정됩니다. '
                  '여기서는 양력/음력과 시각 정밀도만 더 반영합니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<CalendarType>(
                  initialValue: _calendarType,
                  decoration: const InputDecoration(labelText: '달력 기준'),
                  items: CalendarType.values
                      .map(
                        (CalendarType value) => DropdownMenuItem<CalendarType>(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (CalendarType? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _calendarType = value;
                    });
                  },
                ),
                if (_calendarType == CalendarType.lunar) ...<Widget>[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('윤달 여부'),
                    subtitle: const Text('음력인 경우에만 확인하면 됩니다.'),
                    value: _isLeapMonth,
                    onChanged: (bool value) {
                      setState(() {
                        _isLeapMonth = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<TimePrecision>(
                  initialValue: _timePrecision,
                  decoration: const InputDecoration(labelText: '시각 정밀도'),
                  items: TimePrecision.values
                      .map(
                        (TimePrecision value) =>
                            DropdownMenuItem<TimePrecision>(
                              value: value,
                              child: Text(value.label),
                            ),
                      )
                      .toList(),
                  onChanged: (TimePrecision? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _timePrecision = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_timePrecision == TimePrecision.exact)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('정확한 출생 시각'),
                    subtitle: Text(
                      '${_exactHour.toString().padLeft(2, '0')}:${_exactMinute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.schedule),
                    onTap: _pickExactTime,
                  )
                else if (_timePrecision == TimePrecision.branch)
                  DropdownButtonFormField<TimeBranchSlot>(
                    initialValue: _timeBranchSlot,
                    decoration: const InputDecoration(labelText: '시지 구간'),
                    items: TimeBranchSlot.values
                        .map(
                          (
                            TimeBranchSlot value,
                          ) => DropdownMenuItem<TimeBranchSlot>(
                            value: value,
                            child: Text(
                              '${value.label} ${value.hanja} ${value.rangeLabel}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (TimeBranchSlot? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _timeBranchSlot = value;
                      });
                    },
                  ),
                if (_timePrecision == TimePrecision.unknown)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('출생 시간이 없으면 시주는 정오 기준의 간이 판독으로 읽습니다.'),
                  ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _calendarType == CalendarType.solar
                        ? '양력 입력이면 추가 정보 없이 바로 계산됩니다.'
                        : '음력 입력은 윤달 여부가 틀리면 월주와 시점 해석이 달라질 수 있습니다.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('이 설정으로 정밀 사주 보기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
