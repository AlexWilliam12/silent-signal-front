import 'package:flutter/material.dart';

class AuthTextButton extends StatelessWidget {
  final String value;
  final Widget route;

  const AuthTextButton({
    super.key,
    required this.value,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => route),
      ),
      child: Text(
        value,
        style: const TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Color.fromARGB(255, 67, 170, 255),
          color: Color.fromARGB(255, 67, 170, 255),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
