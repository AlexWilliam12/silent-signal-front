import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/app/chats.dart';
import 'package:silent_signal/app/profile.dart';
import 'package:silent_signal/app/settings.dart';
import 'package:silent_signal/auth/login.dart';
import 'package:silent_signal/consts/chat_mode.dart';
import 'package:silent_signal/providers/providers.dart';
import 'package:silent_signal/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('host', '192.168.0.141:8080');
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) {
            final provider = UserProvider();
            provider.provide();
            return provider;
          },
        ),
        ChangeNotifierProvider<PrivateChatProvider>(
          create: (_) {
            final service = PrivateChatProvider();
            service.connect(ChatMode.PRIVATE);
            return service;
          },
        ),
        ChangeNotifierProvider<GroupChatProvider>(
          create: (_) {
            final service = GroupChatProvider();
            service.connect(ChatMode.GROUP);
            return service;
          },
        ),
      ],
      child: MaterialApp(
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
        home: const ChatListScreen(),
      ),
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
      home: const LoginScreen(),
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
  final isValid = await service.validateToken(token);
  if (!isValid) {
    final hash = pref.get('credentials_hash') as String?;
    if (hash == null) {
      return false;
    }
    final response = await service.validateHash(hash);
    if (response['error'] != null) {
      debugPrint(response['error']);
      return false;
    }
    await pref.setString('token', response['token']);
  }
  return true;
}
