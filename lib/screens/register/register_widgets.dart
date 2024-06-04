import 'dart:io';

import 'package:flutter/material.dart';
import 'package:refactoring/consts/terms_and_conditions.dart';
import 'package:refactoring/widgets/auth/auth_form_field.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;

  const RegisterForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
  });

  String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? confirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    } else if (value != passwordController.text) {
      return 'Passwords are not the same';
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
            const SizedBox(height: 30),
            AuthFormField(
              controller: confirmPasswordController,
              validator: (value) => confirmPassword(value),
              label: 'Confirm Password',
              hint: 'Confirm your password..',
              icon: Icons.person,
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterCheckBox extends StatelessWidget {
  final bool isAccept;
  final Function(bool? value) onChanged;
  final void Function() onPressed;

  const RegisterCheckBox({
    super.key,
    required this.isAccept,
    required this.onChanged,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: CheckboxListTile(
        value: isAccept,
        onChanged: onChanged,
        title: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  content: const SingleChildScrollView(
                    child: Text(
                      TERMS_AND_CONDITIONS,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        onPressed();
                        Navigator.pop(context);
                      },
                      child: const Text('Accept'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.info,
              ),
              Text(
                'Terms and Conditions',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterUploadButton extends StatelessWidget {
  final void Function() onPressed;
  final File? file;
  final bool isLoading;

  const RegisterUploadButton({
    super.key,
    required this.onPressed,
    required this.file,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 22, 48, 196),
        ),
        iconSize: WidgetStatePropertyAll(35),
        fixedSize: WidgetStatePropertyAll(
          Size(
            100,
            100,
          ),
        ),
      ),
      onPressed: onPressed,
      icon: !isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  file == null ? Icons.upload : Icons.verified,
                  color: Colors.white,
                ),
                Text(
                  file == null ? 'Upload' : 'Uploaded',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
