import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/app/contact.dart';
import 'package:silent_signal/app/group_chat.dart';
import 'package:silent_signal/app/private_chat.dart';
import 'package:silent_signal/app/profile.dart';
import 'package:silent_signal/app/settings.dart';
import 'package:silent_signal/main.dart';
import 'package:silent_signal/providers/providers.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int index = 0;
  final controller = PageController();

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('hash');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Auth(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, value, child) {
        final user = value.user;
        if (user == null) {
          return const LoadScreen();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Silent Signal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              toolbarHeight: 65,
              backgroundColor: const Color.fromARGB(255, 0, 15, 83),
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
            endDrawer: Drawer(
              child: ListView(
                // padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 15, 83),
                    ),
                    child: Text(
                      'Settings Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.account_circle,
                      size: 30,
                    ),
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      size: 30,
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(user: user),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      size: 30,
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      logout();
                    },
                  ),
                ],
              ),
            ),
            body: PageView(
              controller: controller,
              onPageChanged: (value) {
                setState(() {
                  index = value;
                });
              },
              children: const [
                PrivateChatListScreen(),
                GroupChatListScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: index,
              onTap: (index) => controller.jumpToPage(index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups),
                  label: 'groups',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ContactScreen(),
                ),
              ),
              child: const Icon(Icons.contacts),
            ),
          );
        }
      },
    );
  }
}
