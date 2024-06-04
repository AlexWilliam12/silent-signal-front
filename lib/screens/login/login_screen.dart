import 'package:flutter/material.dart';
import 'package:refactoring/main.dart';
import 'package:refactoring/models/auth_model.dart';
import 'package:refactoring/screens/login/login_widgets.dart';
import 'package:refactoring/screens/register/register_screen.dart';
import 'package:refactoring/view_models/auth_view_model.dart';
import 'package:refactoring/widgets/auth/auth_base.dart';
import 'package:refactoring/widgets/auth/auth_header_image.dart';
import 'package:refactoring/widgets/auth/auth_header_title.dart';
import 'package:refactoring/widgets/auth/auth_submit_button.dart';
import 'package:refactoring/widgets/auth/auth_text_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final message = await AuthViewModel().login(
      AuthModel(
        username: usernameController.text,
        password: passwordController.text,
      ),
    );
    if (message.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User logged successfully!')),
      );
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).replace(
          oldRoute: ModalRoute.of(context)!,
          newRoute: MaterialPageRoute(
            builder: (_) => const InitialScreenBuilder(),
          ),
        );
      }
    } else if (message.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBase(
      widgets: [
        const AuthHeaderImage(asset: 'assets/images/woman-layed.png'),
        const SizedBox(height: 15),
        const AuthHeaderTitle(title: 'Welcome back to Silent Signal'),
        const SizedBox(height: 35),
        LoginForm(
          formKey: formKey,
          usernameController: usernameController,
          passwordController: passwordController,
        ),
        const SizedBox(height: 35),
        AuthSubmitButton(
          onPressed: () async => await submit(),
          value: 'Sign In',
        ),
        const SizedBox(height: 25),
        const AuthTextButton(
          value: "Don't have an account? Register now!",
          route: RegisterScreen(),
        ),
        const SizedBox(height: 10),
        const AuthTextButton(
          value: 'Forgot your password? Click here!',
          route: Placeholder(),
        ),
      ],
    );
  }
}
