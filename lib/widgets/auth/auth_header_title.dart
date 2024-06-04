import 'package:flutter/widgets.dart';

class AuthHeaderTitle extends StatelessWidget {
  final String title;
  const AuthHeaderTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
