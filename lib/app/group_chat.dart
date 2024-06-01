import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_signal/providers/providers.dart';

class GroupChatListScreen extends StatefulWidget {
  const GroupChatListScreen({super.key});

  @override
  State<GroupChatListScreen> createState() => _GroupChatListScreenState();
}

class _GroupChatListScreenState extends State<GroupChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<GroupChatProvider>(context);
    final user = Provider.of<UserProvider>(context).user;

    return StreamBuilder(
      stream: service.stream,
      builder: (context, snapshot) {
        if (service.messages.isEmpty) {
          return const Center(child: Text('No group messages available yet'));
        } else {
          return ListView.builder(
            // itemCount: messages.length,
            itemBuilder: (context, index) {
              // final message = messages[index];
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
                      // child: message!.sender.picture != null
                      //     ? Image.network(message.sender.picture!)
                      //     : Text(message.sender.name.substring(0, 1)),
                      child: Text('A'),
                    ),
                  ),
                  title: const Text(
                    'message.sender.name',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text(
                    'message.content',
                    overflow: TextOverflow.ellipsis,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  // onTap: () => Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PrivateChatScreen(
                  //       user: widget.user,
                  //     ),
                  //   ),
                  // ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
