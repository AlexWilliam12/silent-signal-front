import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/screens/chat.dart';
import 'package:silent_signal/screens/profile.dart';
import 'package:silent_signal/screens/settings.dart';
import 'package:silent_signal/screens/login/login.dart';
import 'package:silent_signal/screens/register/register.dart';
import 'package:silent_signal/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('host', '192.168.0.117:8080');
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
      initialRoute: "/app",
      routes: {
        "/app": (context) => const MainScreen(),
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
  final token = pref.get('token') as String?;
  final service = AuthService();
  if (token == null) {
    return false;
  }
  var response = await service.validateToken(token);
  if (response['error'] != null) {
    debugPrint(response['error']);
    final hash = pref.get('hash') as String?;
    if (hash == null) {
      return false;
    }
    response = await service.validateHash(hash);
    if (response['error'] != null) {
      return false;
    }
    await pref.setString('token', response['token']);
  }
  return true;
}
