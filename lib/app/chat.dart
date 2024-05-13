import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/services/websocket.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _channel = WebSocketService();

  @override
  void initState() {
    initChannel();
    super.initState();
  }

  Future<void> initChannel() async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.get('token') as String;
    await _channel.connect('', token);
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () => debugPrint('works'),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green,
                child: Text('A'),
              ),
            ),
          ),
        ],
      ),
      body: _channel.socket == null
          ? const Center(child: Text('No chats available'))
          : const ChatBody(),
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
  }
}

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final _channel = WebSocketService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _channel.socket!.asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => debugPrint('profile'),
                    child: const CircleAvatar(
                      radius: 25,
                      child: Text('U'),
                    ),
                  ),
                  title: const Text(
                    'User 1',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text(
                    'some text',
                    overflow: TextOverflow.ellipsis,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  onTap: () => debugPrint('works'),
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
