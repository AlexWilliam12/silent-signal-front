import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/screens/group_chat/group_chat_list_screen.dart';
import 'package:refactoring/screens/login/login_screen.dart';
import 'package:refactoring/screens/main/main_widgets.dart';
import 'package:refactoring/screens/private_chat/private_chat_list_screen.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';
import 'package:refactoring/widgets/shared/load_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final controller = PageController();
  int index = 0;

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('hash');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserViewModel>(context).user;
    if (user == null) {
      return const LoadScreen();
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Silent Signal',
        isMainScreen: true,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      endDrawer: MainDrawer(onTap: () async => await logout(), user: user),
      body: MainBody(
        controller: controller,
        onPageChanged: (value) {
          setState(() {
            index = value;
          });
        },
        routes: [
          const PrivateChatListScreen(),
          GroupChatListScreen(user: user),
        ],
      ),
      bottomNavigationBar: MainBottomNavigator(
        index: index,
        onTap: (value) => controller.jumpToPage(value),
      ),
      floatingActionButton: MainFloatingActionButton(index: index),
    );
  }
}
