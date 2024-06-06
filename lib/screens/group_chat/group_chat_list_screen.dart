import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/models/group_message_model.dart';
import 'package:refactoring/models/sensitive_user_model.dart';
import 'package:refactoring/screens/group_chat/group_chat_screen.dart';
import 'package:refactoring/view_models/chat_view_model.dart';
import 'package:refactoring/widgets/shared/custom_list_tile.dart';

class GroupChatListScreen extends StatelessWidget {
  final SensitiveUserModel user;
  const GroupChatListScreen({super.key, required this.user});

  String formatMessage(GroupMessageModel message) {
    if (message.type == 'text') {
      return message.sender.name == user.name
          ? 'You sent: ${message.content}'
          : '${message.sender.name}: ${message.content}';
    } else {
      return message.sender.name == user.name
          ? 'You sent: ${message.type.substring(0, message.type.indexOf('/'))} file'
          : '${message.sender.name}: ${message.type.substring(0, message.type.indexOf('/'))} file';
    }
  }

  String formatTime(GroupMessageModel message) {
    return '${message.createdAt.month}/${message.createdAt.day}/${message.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final groupModel = Provider.of<GroupChatViewModel>(context);

    if (groupModel.messages.isEmpty) {
      return const Center(child: Text('No group messages available yet'));
    }
    return StreamBuilder(
      stream: groupModel.stream,
      builder: (context, snapshot) {
        final messages = groupModel.filterLastMessages(groupModel.wrapList());
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return message.group.picture != null
                ? CustomListTile(
                    isLeadingImage: true,
                    leading: message.group.picture!,
                    title: message.group.name,
                    subtitle: formatMessage(message),
                    trailing: formatTime(message),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          group: message.group,
                        ),
                      ),
                    ),
                  )
                : CustomListTile(
                    isLeadingImage: false,
                    leading: message.group.name.substring(0, 1),
                    title: message.group.name,
                    subtitle: formatMessage(message),
                    trailing: formatTime(message),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                          group: message.group,
                        ),
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}
