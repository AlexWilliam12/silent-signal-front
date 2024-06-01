import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/providers/providers.dart';
import 'package:silent_signal/services/user_service.dart';

class SettingScreen extends StatefulWidget {
  final SensitiveUser user;
  const SettingScreen({super.key, required this.user});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _key = GlobalKey<FormState>();
  TimeUnit _timeUnit = TimeUnit.minutes;
  int _value = 1;
  late bool _isEnabled;
  bool _hasChange = false;

  @override
  void initState() {
    final interval = widget.user.temporaryMessageInterval;
    _isEnabled = interval != null;
    if (interval != null) {
      final values = interval.split(' ');
      _value = int.parse(values.first);
      for (final key in unitLabels.keys) {
        if (key.name.toLowerCase() == values.elementAt(1)) {
          _timeUnit = key;
        }
      }
    }
    super.initState();
  }

  Future<void> _updateTemporaryMessages() async {
    final service = UserService();
    if (!_hasChange) {
      await service.updateTemporaryMessages(null);
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).provide();
      }
    } else if (_isEnabled) {
      String interval =
          '$_value ${_value == 1 ? _timeUnit.name.substring(0, _timeUnit.name.length - 1).toLowerCase() : _timeUnit.name.toLowerCase()}';
      await service.updateTemporaryMessages(interval);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Temporary messages have been enabled'),
          ),
        );
        Provider.of<UserProvider>(context, listen: false).provide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: const Color.fromARGB(255, 0, 15, 83),
        title: const Text(
          'Temporary Messages',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Image(
                image: const AssetImage('assets/images/temporary-messages.png'),
                width: MediaQuery.of(context).size.width,
                height: 300,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: const Text(
                'When temporary messages are enabled, they will be deleted after the specified time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 30,
                          color: Colors.blue,
                        ),
                        Text(
                          'Timer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                      if (!_isEnabled) {
                        _updateTemporaryMessages();
                      }
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ...[
              if (_isEnabled)
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width - 100,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Form(
                              key: _key,
                              child: TextFormField(
                                initialValue: _value.toString(),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Value can't be empty";
                                  } else if (double.tryParse(value) == null) {
                                    return 'Value must be a number';
                                  } else if (double.parse(value) <= 0) {
                                    return "Value can't be zero or less";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                ),
                                onChanged: (value) {
                                  if (_key.currentState!.validate()) {
                                    setState(() {
                                      _value =
                                          (double.tryParse(value) ?? 0).ceil();
                                      _hasChange = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButton<TimeUnit>(
                            value: _timeUnit,
                            items: unitLabels.entries.map((e) {
                              return DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _timeUnit = value!;
                                _hasChange = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => _updateTemporaryMessages(),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 0, 26, 143),
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          Colors.white,
                        ),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

enum TimeUnit { minutes, hours, days, weeks, months }

const Map<TimeUnit, String> unitLabels = {
  TimeUnit.minutes: 'Minutes',
  TimeUnit.hours: 'Hours',
  TimeUnit.days: 'Days',
  TimeUnit.weeks: 'Weeks',
  TimeUnit.months: 'Months',
};
