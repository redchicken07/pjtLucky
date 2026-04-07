import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../logic/saju_logic.dart';
import '../models/birth_input.dart';
import '../models/profile_options.dart';
import '../models/saju_result.dart';
import '../services/app_repository.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../utils/date_utils.dart';
import '../utils/profile_input_formatters.dart';
import '../widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _gender = '남성';
  CalendarType _calendarType = CalendarType.solar;
  TimePrecision _timePrecision = TimePrecision.unknown;
  TimeBranchSlot _timeBranchSlot = TimeBranchSlot.wu;
  bool _isLeapMonth = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await FirebaseInit.initialize();
    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    final BirthInput? profile = await AppRepository.instance.getBirthInput(uid);

    if (!mounted) {
      return;
    }

    if (profile != null) {
      _nameController.text = profile.name;
      _dateController.text = AppDateUtils.slashDateLabel(
        DateTime(profile.year, profile.month, profile.day),
      );
      _timeController.text = AppDateUtils.compactTimeLabel(
        profile.hour,
        profile.minute,
      );
      _gender = profile.gender;
      _calendarType = profile.calendarType;
      _timePrecision = profile.hasKnownTime
          ? TimePrecision.exact
          : profile.timePrecision;
      _timeBranchSlot = profile.timeBranchSlot ?? TimeBranchSlot.fromHour(null);
      _isLeapMonth = profile.isLeapMonth ?? false;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime initialDate =
        AppDateUtils.parseSlashDate(_dateController.text) ??
        DateTime(1990, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: initialDate,
    );
    if (picked == null) {
      return;
    }
    _dateController.text = AppDateUtils.slashDateLabel(picked);
    setState(() {});
  }

  Future<void> _pickTime() async {
    final TimeOfDay initialTime =
        AppDateUtils.parseClockTime(_timeController.text) ??
        const TimeOfDay(hour: 12, minute: 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) {
      return;
    }
    _timeController.text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {});
  }

  Future<void> _save() async {
    final DateTime? birthDate = AppDateUtils.parseSlashDate(
      _dateController.text,
    );
    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 yyyy/MM/dd 형식으로 입력해 주세요.')),
      );
      return;
    }

    TimeOfDay? time;
    if (_timePrecision == TimePrecision.exact) {
      time = AppDateUtils.parseClockTime(_timeController.text);
      if (time == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출생 시간을 HH:mm 형식으로 입력해 주세요.')),
        );
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    final BirthInput input = BirthInput(
      year: birthDate.year,
      month: birthDate.month,
      day: birthDate.day,
      hour: _timePrecision == TimePrecision.exact ? time!.hour : null,
      minute: _timePrecision == TimePrecision.exact ? time!.minute : null,
      gender: _gender,
      name: _nameController.text.trim(),
      calendarType: _calendarType,
      timePrecision: _timePrecision,
      timeBranchSlot: _timePrecision == TimePrecision.branch
          ? _timeBranchSlot
          : null,
      isLeapMonth: _calendarType == CalendarType.lunar ? _isLeapMonth : null,
    );

    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    await AppRepository.instance.saveBirthInput(uid, input);
    final SajuResult result = SajuLogic.calculate(input);

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });
    await context.push('/saju', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사주 프로필')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '프로필 입력',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '여기서 저장한 정보는 다음에 앱을 열어도 자동으로 불러옵니다. 날짜는 yyyy/MM/dd, 시간은 HH:mm 형식으로 바로 입력할 수 있습니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        hintText: '홍길동',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              SlashDateTextInputFormatter(),
                            ],
                            decoration: const InputDecoration(
                              labelText: '생년월일',
                              hintText: '1992/10/07',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: '성별'),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: '남성',
                          child: Text('남성'),
                        ),
                        DropdownMenuItem<String>(
                          value: '여성',
                          child: Text('여성'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _gender = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '달력 기준',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<CalendarType>(
                      segments: CalendarType.values
                          .map(
                            (CalendarType value) => ButtonSegment<CalendarType>(
                              value: value,
                              label: Text(value.label),
                            ),
                          )
                          .toList(),
                      selected: <CalendarType>{_calendarType},
                      onSelectionChanged: (Set<CalendarType> selection) {
                        setState(() {
                          _calendarType = selection.first;
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
                    const SizedBox(height: 18),
                    Text(
                      '출생 시간 정밀도',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TimePrecision>(
                      segments: TimePrecision.values
                          .map(
                            (TimePrecision value) =>
                                ButtonSegment<TimePrecision>(
                                  value: value,
                                  label: Text(value.label),
                                ),
                          )
                          .toList(),
                      selected: <TimePrecision>{_timePrecision},
                      onSelectionChanged: (Set<TimePrecision> selection) {
                        setState(() {
                          _timePrecision = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    if (_timePrecision == TimePrecision.exact)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _timeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                ClockTextInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                labelText: '출생 시간',
                                hintText: '16:00',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.schedule),
                          ),
                        ],
                      )
                    else if (_timePrecision == TimePrecision.branch)
                      DropdownButtonFormField<TimeBranchSlot>(
                        initialValue: _timeBranchSlot,
                        decoration: const InputDecoration(labelText: '시지 단위'),
                        items: TimeBranchSlot.values
                            .map(
                              (TimeBranchSlot value) =>
                                  DropdownMenuItem<TimeBranchSlot>(
                                    value: value,
                                    child: Text(value.displayLabel),
                                  ),
                            )
                            .toList(),
                        onChanged: (TimeBranchSlot? value) {
                          if (value != null) {
                            setState(() {
                              _timeBranchSlot = value;
                            });
                          }
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '출생 시간을 모르면 비워 두고 저장해도 됩니다. 무료 사주와 오늘 운세는 계속 볼 수 있고, 시간 정보를 나중에 추가하면 정밀도가 올라갑니다.',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _saving ? '저장 중...' : '프로필 저장하고 사주 보기',
              icon: Icons.auto_awesome,
              onPressed: _saving ? null : _save,
            ),
          ],
        ],
      ),
    );
  }
}
