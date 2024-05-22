import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/consts/enchecao_de_linguica.dart';
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
              content: Text(response['error']),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);
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
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
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
                            autofocus: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Enter your username..',
                              labelText: 'Username',
                              floatingLabelStyle: TextStyle(
                                color: Colors.blue,
                              ),
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
                              floatingLabelStyle: TextStyle(
                                color: Colors.blue,
                              ),
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
                              floatingLabelStyle: TextStyle(
                                color: Colors.blue,
                              ),
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
                      width: 300,
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
                                  title: const Text('Termos e Condições'),
                                  content: const SingleChildScrollView(
                                    child: Text(blabla),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.info),
                              Text('Terms and Conditions'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    IconButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromARGB(255, 22, 48, 196),
                        ),
                        iconSize: MaterialStatePropertyAll(35),
                        fixedSize: MaterialStatePropertyAll(
                          Size(
                            100,
                            100,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _file = File(pickedFile.path);
                          });
                        }
                      },
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_file == null ? Icons.upload : Icons.verified),
                          Text(_file == null ? 'Upload' : 'Uploaded'),
                        ],
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
                                      'Accept the terms and conditions'),
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
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 0, 15, 83)),
                      ),
                      child: const Text(
                        'Submit',
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
