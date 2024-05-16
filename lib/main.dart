import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/app/chat.dart';
import 'package:silent_signal/app/profile.dart';
import 'package:silent_signal/app/settings.dart';
import 'package:silent_signal/auth/login.dart';
import 'package:silent_signal/auth/register.dart';

void main() {
  runApp(const AppRunner());
}

class AppRunner extends StatelessWidget {
  const AppRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 20, 122, 195),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color.fromARGB(255, 5, 0, 64),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: FutureBuilder(
        future: checkToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadScreen();
          } else {
            final result = snapshot.data!;
            if (result) {
              return const ChatApp();
            } else {
              return const Auth();
            }
          }
        },
      ),
    );
  }
}

class LoadScreen extends StatelessWidget {
  const LoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/silent-signal-logo.png'),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 20, 122, 195),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color.fromARGB(255, 5, 0, 64),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: "/chat",
      routes: {
        "/app": (context) => const MainScreen(),
        "/chat": (context) => const ChatRoom(),
        "/profile": (context) => const ProfileScreen(),
        "/settings": (context) => const SettingScreen(),
      },
    );
  }
}

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 20, 122, 195),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color.fromARGB(255, 5, 0, 64),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
      },
    );
  }
}

Future<bool> checkToken() async {
  final pref = await SharedPreferences.getInstance();
  final token = pref.get("token");
  return token == null;
}