import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refactoring/main.dart';
import 'package:refactoring/models/auth_model.dart';
import 'package:refactoring/screens/register/register_widgets.dart';
import 'package:refactoring/view_models/auth_view_model.dart';
import 'package:refactoring/view_models/upload_view_model.dart';
import 'package:refactoring/widgets/auth/auth_base.dart';
import 'package:refactoring/widgets/auth/auth_header_image.dart';
import 'package:refactoring/widgets/auth/auth_header_title.dart';
import 'package:refactoring/widgets/auth/auth_submit_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isAccept = false;
  bool isLoading = false;
  File? file;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (!isAccept) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                'Accept the terms and conditions',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isAccept = true;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Accept'),
                ),
              ],
            );
          });
      return;
    }
    final message = await AuthViewModel().register(
      AuthModel(
        username: usernameController.text,
        password: passwordController.text,
      ),
    );
    if (file != null) {
      await UploadViewModel().uploadUserPicture(file!);
    }
    if (message.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
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

  Future<void> upload() async {
    setState(() {
      isLoading = true;
    });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthBase(
      widgets: [
        const AuthHeaderImage(
          asset: 'assets/images/people-talking.png',
        ),
        const SizedBox(height: 15),
        const AuthHeaderTitle(
          title: "Let's connect to the network",
        ),
        const SizedBox(height: 35),
        RegisterForm(
          formKey: formKey,
          usernameController: usernameController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
        ),
        const SizedBox(height: 25),
        RegisterCheckBox(
          isAccept: isAccept,
          onChanged: (value) {
            setState(() {
              isAccept = value!;
            });
          },
          onPressed: () {
            setState(() {
              isAccept = true;
            });
          },
        ),
        const SizedBox(height: 25),
        RegisterUploadButton(
          onPressed: () async => await upload(),
          file: file,
          isLoading: isLoading,
        ),
        const SizedBox(height: 30),
        AuthSubmitButton(
          onPressed: () => submit(),
          value: 'Sign Up',
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
