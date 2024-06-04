import 'package:flutter/material.dart';
import 'package:refactoring/widgets/auth/auth_form_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.formKey,
  });

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            AuthFormField(
              controller: usernameController,
              validator: (value) => validate(value),
              label: 'Username',
              hint: 'Enter your username..',
              icon: Icons.person,
              obscureText: false,
            ),
            const SizedBox(height: 30),
            AuthFormField(
              controller: passwordController,
              validator: (value) => validate(value),
              label: 'Password',
              hint: 'Enter your password..',
              icon: Icons.person,
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
