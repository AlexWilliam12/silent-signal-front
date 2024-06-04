import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?) validator;
  final TextEditingController controller;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.validator,
    required this.label,
    required this.hint,
    required this.icon,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.text,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        labelText: label,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
