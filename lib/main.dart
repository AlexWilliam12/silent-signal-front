import 'package:flutter/material.dart';
import 'package:refactoring/consts/chat_mode.dart';
import 'package:refactoring/screens/login/login_screen.dart';
import 'package:refactoring/screens/main/main_screen.dart';
import 'package:refactoring/view_models/auth_view_model.dart';
import 'package:refactoring/view_models/chat_view_model.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/shared/load_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  preferences.setString('host', '192.168.0.141:8080');
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
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color.fromARGB(255, 5, 0, 64),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  Future<void> awaitBuilder() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const InitialScreenBuilder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: awaitBuilder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Image.asset('assets/images/silent-signal-logo.png'),
            );
          } else {
            return const Placeholder();
          }
        },
      ),
    );
  }
}

class InitialScreenBuilder extends StatelessWidget {
  const InitialScreenBuilder({super.key});

  Future<String> checkToken() async {
    final preferences = await SharedPreferences.getInstance();
    final model = AuthViewModel();

    final token = preferences.get('token') as String?;
    if (token != null) {
      final isValid = await model.validateToken(token);
      if (isValid) {
        return '';
      }
    }
    final hash = preferences.get('credentials_hash') as String?;
    if (hash != null) {
      final response = await model.validateHash(hash);
      if (response.isNotEmpty) {
        return response;
      }
    }
    return 'No valid form of authentication detected';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadScreen();
        } else {
          final data = snapshot.data!;
          if (data.isEmpty) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider<UserViewModel>(
                  create: (_) => UserViewModel()..fetchUser(),
                ),
                ChangeNotifierProvider<PrivateChatViewModel>(
                  create: (_) =>
                      PrivateChatViewModel()..connect(ChatMode.PRIVATE),
                ),
                ChangeNotifierProvider<GroupChatViewModel>(
                  create: (_) => GroupChatViewModel()..connect(ChatMode.GROUP),
                ),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primaryColor: const Color.fromARGB(255, 20, 122, 195),
                  brightness: Brightness.light,
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  primaryColor: const Color.fromARGB(255, 5, 0, 64),
                  brightness: Brightness.dark,
                  useMaterial3: true,
                ),
                themeMode: ThemeMode.system,
                home: const MainScreen(),
              ),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: const Color.fromARGB(255, 20, 122, 195),
                brightness: Brightness.light,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                primaryColor: const Color.fromARGB(255, 5, 0, 64),
                brightness: Brightness.dark,
                useMaterial3: true,
              ),
              themeMode: ThemeMode.system,
              home: const LoginScreen(),
            );
          }
        }
      },
    );
  }
}
