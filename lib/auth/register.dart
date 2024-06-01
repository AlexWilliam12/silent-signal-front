import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/consts/terms_conditions.dart';
import 'package:silent_signal/services/auth_service.dart';
import 'package:silent_signal/services/upload_service.dart';

import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _terms = false;
  File? _file;
  bool _loadingFile = false;

  Future<void> _submitForm() async {
    final service = AuthService();
    final response = await service.register(
      _usernameController.text,
      _passwordController.text,
    );
    if (response['token'] == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(response['error'] as String),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('close'),
                ),
              ],
            );
          },
        );
      }
    } else {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('token', response['token'] as String);
      debugPrint(response['token']);
      if (_file != null) {
        await UploadService().uploadPicture(_file!);
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Message'),
              content: const Text('User registered successfully'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ok'),
                ),
              ],
            );
          },
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatApp()),
        );
      }
    }
  }

  void _uploadPicture() async {
    setState(() {
      _loadingFile = true;
    });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
      });
    }
    setState(() {
      _loadingFile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                color: const Color.fromARGB(255, 0, 15, 83),
                child: const Image(
                  image: AssetImage('assets/images/people-talking.png'),
                ),
              ),
              const SizedBox(height: 15),
              const SizedBox(
                width: 250,
                child: Text(
                  "Let's connect to the network",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 35),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Enter your username..',
                              labelText: 'Username',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Enter your password..',
                              labelText: 'Password',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _confirmController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              } else if (value != _passwordController.text) {
                                return 'Passwords are not the same';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: 'Confirm your password..',
                              labelText: 'Confirm Password',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 320,
                      child: CheckboxListTile(
                        value: _terms,
                        onChanged: (value) {
                          setState(() {
                            _terms = value!;
                          });
                        },
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
                                        setState(() {
                                          _terms = true;
                                        });
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
                    ),
                    const SizedBox(height: 25),
                    IconButton(
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
                      onPressed: () {
                        _uploadPicture();
                      },
                      icon: !_loadingFile
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _file == null ? Icons.upload : Icons.verified,
                                  color: Colors.white,
                                ),
                                Text(
                                  _file == null ? 'Upload' : 'Uploaded',
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
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (!_terms) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Accept the terms and conditions',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _terms = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Accept'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _submitForm();
                          }
                        }
                      },
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 0, 26, 143),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
