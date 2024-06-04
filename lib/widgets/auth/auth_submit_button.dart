import 'package:flutter/material.dart';

class AuthSubmitButton extends StatelessWidget {
  final String value;
  final void Function() onPressed;

  const AuthSubmitButton({
    super.key,
    required this.onPressed,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 0, 26, 143),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
