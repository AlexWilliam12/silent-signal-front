import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/main.dart';
import 'package:silent_signal/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitForm() async {
    final service = AuthService();
    final response = await service.login(
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
              content: Text(response['error']!),
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
      await prefs.setString('token', response['token']!);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Message'),
              content: const Text('User logged successfully'),
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
                  image: AssetImage('assets/images/woman-layed.png'),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 35),
              Form(
                key: _formKey,
                child: Container(
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitForm();
                  }
                },
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Color.fromARGB(255, 0, 15, 83)),
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
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/register'),
                child: const Text(
                  'Do not have an account? Register now!',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 67, 170, 255),
                    color: Color.fromARGB(255, 67, 170, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Forgot your password? Click here!',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromARGB(255, 67, 170, 255),
                    color: Color.fromARGB(255, 67, 170, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
