import 'package:flutter/material.dart';
import 'package:silent_signal/app/group_chat.dart';
import 'package:silent_signal/app/private_chat.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/services/user_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _index = 0;

  Future<SensitiveUser?> fetchUser() async {
    return await UserService().fetchUser();
  }

  Widget renderBody(SensitiveUser user) {
    if (_index == 0) {
      return PrivateChatListScreen(user: user);
    } else if (_index == 1) {
      return GroupChatListScreen(user: user);
    } else {
      return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
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
                Container(
                  margin: const EdgeInsets.only(
                    right: 15,
                  ),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green,
                    child: Text('U'),
                  ),
                ),
              ],
            ),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: BottomNavigationBar(
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
              onPressed: () => debugPrint('works'),
              child: const Icon(Icons.add),
            ),
          );
        } else {
          final user = snapshot.data!;
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
                Container(
                  margin: const EdgeInsets.only(
                    right: 15,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green,
                      child: user.picture != null
                          ? Image.network(user.picture!)
                          : Text(user.name.substring(0, 1)),
                    ),
                  ),
                ),
              ],
            ),
            body: renderBody(user),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _index,
              onTap: (index) {
                setState(() {
                  _index = index;
                });
              },
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
              onPressed: () => debugPrint('works'),
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
