import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/consts/terms_conditions.dart';
import 'package:silent_signal/main.dart';
import 'package:silent_signal/screens/register/register_context.dart';
import 'package:silent_signal/services/auth_service.dart';
import 'package:silent_signal/services/upload_service.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const _ContentHeader(),
              const SizedBox(height: 35),
              ChangeNotifierProvider(
                create: (context) => RegisterContext(),
                child: const _ContentBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentHeader extends StatelessWidget {
  const _ContentHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}

class _ContentBody extends StatelessWidget {
  const _ContentBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: Provider.of<RegisterContext>(context).key,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: const Column(
                  children: [
                    _UserTextFormField(),
                    SizedBox(height: 30),
                    _PasswordTextFormField(),
                    SizedBox(height: 30),
                    _CPasswordTextFormField(),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const _TermsAndConditions(),
              const SizedBox(height: 25),
              const _UploadButton(),
              const SizedBox(height: 30),
              const _SubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserTextFormField extends StatefulWidget {
  const _UserTextFormField();

  @override
  State<_UserTextFormField> createState() => __UserTextFormFieldState();
}

class __UserTextFormFieldState extends State<_UserTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      onChanged: (value) {
        setState(() {
          Provider.of<RegisterContext>(context).user = value;
        });
      },
    );
  }
}

class _PasswordTextFormField extends StatefulWidget {
  const _PasswordTextFormField();

  @override
  State<_PasswordTextFormField> createState() => __PasswordTextFormFieldState();
}

class __PasswordTextFormFieldState extends State<_PasswordTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      onChanged: (value) {
        setState(() {
          Provider.of<RegisterContext>(context).password = value;
        });
      },
    );
  }
}

class _CPasswordTextFormField extends StatefulWidget {
  const _CPasswordTextFormField();

  @override
  State<_CPasswordTextFormField> createState() =>
      __CPasswordTextFormFieldState();
}

class __CPasswordTextFormFieldState extends State<_CPasswordTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        } else if (value != Provider.of<RegisterContext>(context).password) {
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
    );
  }
}

class _TermsAndConditions extends StatefulWidget {
  const _TermsAndConditions();

  @override
  State<_TermsAndConditions> createState() => __TermsAndConditionsState();
}

class __TermsAndConditionsState extends State<_TermsAndConditions> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: CheckboxListTile(
        value: Provider.of<RegisterContext>(context).isTermsAccepted,
        onChanged: (value) {
          setState(() {
            Provider.of<RegisterContext>(context).isTermsAccepted = value!;
          });
        },
        title: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Terms and Conditions'),
                  content: const SingleChildScrollView(
                    child: Text(TERMS_CONDITIONS),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          Provider.of<RegisterContext>(context)
                              .isTermsAccepted = true;
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
    );
  }
}

class _UploadButton extends StatefulWidget {
  const _UploadButton();

  @override
  State<_UploadButton> createState() => __UploadButtonState();
}

class __UploadButtonState extends State<_UploadButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          Color.fromARGB(255, 22, 48, 196),
        ),
        iconSize: MaterialStatePropertyAll(35),
        fixedSize: MaterialStatePropertyAll(Size(100, 100)),
      ),
      onPressed: () async {
        final picker = ImagePicker();
        final picture = await picker.pickImage(source: ImageSource.gallery);
        if (picture != null) {
          setState(() {
            Provider.of<RegisterContext>(context).picture = File(picture.path);
          });
        }
      },
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Provider.of<RegisterContext>(context).picture == null
              ? Icons.upload
              : Icons.verified),
          Text(Provider.of<RegisterContext>(context).picture == null
              ? 'Upload'
              : 'Uploaded'),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton();

  @override
  State<_SubmitButton> createState() => __SubmitButtonState();
}

class __SubmitButtonState extends State<_SubmitButton> {
  void _submitForm() async {
    final service = AuthService();
    final response = await service.register(
      Provider.of<RegisterContext>(context).user,
      Provider.of<RegisterContext>(context).password,
    );
    if (response['token'] == null && mounted) {
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', response['token']);
    if (Provider.of<RegisterContext>(context).picture != null) {
      await UploadService()
          .uploadPicture(Provider.of<RegisterContext>(context).picture!);
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (Provider.of<RegisterContext>(context)
            .key
            .currentState!
            .validate()) {
          if (!Provider.of<RegisterContext>(context).isTermsAccepted) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Do you accept the terms and conditions?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          Provider.of<RegisterContext>(context)
                              .isTermsAccepted = true;
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
    );
  }
}
