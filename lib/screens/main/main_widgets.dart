import 'package:flutter/material.dart';
import 'package:refactoring/screens/contact/contact_screen.dart';
import 'package:refactoring/screens/group_explore/group_explore_screen.dart';
import 'package:refactoring/screens/profile/profile_screen.dart';
import 'package:refactoring/screens/settings/settings_screen.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Silent Signal',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: Colors.white,
        ),
      ),
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
    );
  }
}

class MainDrawer extends StatelessWidget {
  final Function() onTap;
  const MainDrawer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  builder: (context) => const SettingsScreen(),
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
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class MainBody extends StatelessWidget {
  final List<Widget> routes;
  final Function(int value) onPageChanged;
  final PageController controller;

  const MainBody({
    super.key,
    required this.routes,
    required this.onPageChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      onPageChanged: onPageChanged,
      children: routes,
    );
  }
}

class MainBottomNavigator extends StatelessWidget {
  final int index;
  final Function(int value) onTap;

  const MainBottomNavigator({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: onTap,
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
    );
  }
}

class MainFloatingActionButton extends StatelessWidget {
  final int index;
  const MainFloatingActionButton({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        (
          index == 0
              ? Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactScreen(),
                  ),
                )
              : Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GroupExploreScreen(),
                  ),
                ),
        );
      },
      child: Icon(index == 0 ? Icons.contacts : Icons.explore),
    );
  }
}
