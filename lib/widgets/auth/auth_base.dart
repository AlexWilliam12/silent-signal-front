import 'package:flutter/material.dart';

class AuthBase extends StatelessWidget {
  final List<Widget> widgets;
  const AuthBase({super.key, required this.widgets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: widgets,
          ),
        ),
      ),
    );
  }
}
