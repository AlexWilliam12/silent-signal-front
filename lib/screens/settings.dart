import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TimeUnit _selectedUnit = TimeUnit.minutes;
  double _timeValue = 0;

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
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
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
            const SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            const SizedBox(height: 30),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton<TimeUnit>(
                    value: _selectedUnit,
                    items: unitLabels.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                  SizedBox(
                    width: 200,
                    child: Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _timeValue = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
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

enum TimeUnit { minutes, hours, days }

const Map<TimeUnit, String> unitLabels = {
  TimeUnit.minutes: 'Minutes',
  TimeUnit.hours: 'Hours',
  TimeUnit.days: 'Days',
};
