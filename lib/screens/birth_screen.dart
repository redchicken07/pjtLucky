import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/saju_logic.dart';
import '../models/birth_input.dart';
import '../models/saju_result.dart';
import '../services/auth_service.dart';
import '../services/firebase_init.dart';
import '../services/firestore_service.dart';
import '../utils/date_utils.dart';
import '../widgets/app_button.dart';

class BirthScreen extends StatefulWidget {
  const BirthScreen({super.key});

  @override
  State<BirthScreen> createState() => _BirthScreenState();
}

class _BirthScreenState extends State<BirthScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _gender = '남성';
  bool _saving = false;

  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime(1990, 1, 1);
    final DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: initialDate,
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('생년월일을 먼저 선택하세요.')));
      return;
    }

    setState(() {
      _saving = true;
    });

    await FirebaseInit.initialize();
    final BirthInput input = BirthInput(
      year: _selectedDate!.year,
      month: _selectedDate!.month,
      day: _selectedDate!.day,
      hour: _selectedTime?.hour,
      minute: _selectedTime?.minute,
      gender: _gender,
    );
    final String? uid =
        AuthService.currentUid ?? await AuthService.ensureSignedIn();
    await FirestoreService.instance.saveBirthInput(uid, input);
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
      appBar: AppBar(title: const Text('생년월일 입력')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '빠른 사주 입력',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '기본 해석은 생년월일, 성별, 출생 시간만으로 바로 볼 수 있습니다. 시간을 모르면 비워둬도 됩니다.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '정밀 명리 해석 안내',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '정밀 사주는 무료 결과를 본 뒤 같은 흐름 안에서 확장해 볼 수 있게 준비해 두었습니다. '
                          '양력/음력 여부와 시각 정밀도를 추가로 반영하므로, 음력이라면 윤달 여부까지 확인해 두면 좋습니다.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('생년월일'),
                    subtitle: Text(
                      _selectedDate == null
                          ? '아직 선택하지 않음'
                          : AppDateUtils.dateLabel(_selectedDate!),
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: _pickDate,
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('출생 시간'),
                    subtitle: Text(
                      _selectedTime == null
                          ? '시간 미상'
                          : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.schedule),
                    onTap: _pickTime,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTime = null;
                      });
                    },
                    child: const Text('출생 시간을 모름으로 설정'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(value: '남성', child: Text('남성')),
                      DropdownMenuItem<String>(value: '여성', child: Text('여성')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _gender = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: '성별'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: _saving ? '저장 중...' : '빠른 사주 해석 보기',
            icon: Icons.auto_awesome,
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
