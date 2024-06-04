import 'package:flutter/material.dart';

class LoadScreen extends StatelessWidget {
  const LoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/silent-signal-logo.png'),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
