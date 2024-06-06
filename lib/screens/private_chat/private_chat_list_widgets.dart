import 'package:flutter/material.dart';
import 'package:refactoring/models/private_message_model.dart';
import 'package:refactoring/models/sensitive_user_model.dart';
import 'package:refactoring/screens/private_chat/private_chat_screen.dart';
import 'package:refactoring/widgets/shared/custom_list_tile.dart';

class PrivateChatListTileLeading extends StatelessWidget {
  final PrivateMessageModel message;
  final SensitiveUserModel user;

  const PrivateChatListTileLeading({
    super.key,
    required this.user,
    required this.message,
  });

  String formatMessage() {
    if (message.type == 'text') {
      return message.sender.name == user.name
          ? 'You sent: ${message.content}'
          : 'Sent you: ${message.content}';
    } else {
      return message.sender.name == user.name
          ? 'You sent: ${message.type.substring(0, message.type.indexOf('/'))} file'
          : 'Sent you: ${message.type.substring(0, message.type.indexOf('/'))} file';
    }
  }

  String formatTime() {
    return '${message.createdAt.month}/${message.createdAt.day}/${message.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return message.sender.name == user.name
        ? message.recipient.picture != null
            ? CustomListTile(
                isLeadingImage: true,
                leading: message.recipient.picture!,
                title: message.recipient.name,
                subtitle: formatMessage(),
                trailing: formatTime(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrivateChatScreen(
                      contact: message.sender.name != user.name
                          ? message.sender
                          : message.recipient,
                    ),
                  ),
                ),
              )
            : CustomListTile(
                isLeadingImage: false,
                leading: message.recipient.name.substring(0, 1),
                title: message.sender.name,
                subtitle: formatMessage(),
                trailing: formatTime(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrivateChatScreen(
                      contact: message.sender.name != user.name
                          ? message.sender
                          : message.recipient,
                    ),
                  ),
                ),
              )
        : message.sender.picture != null
            ? CustomListTile(
                isLeadingImage: true,
                leading: message.sender.picture!,
                title: message.recipient.name,
                subtitle: formatMessage(),
                trailing: formatTime(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrivateChatScreen(
                      contact: message.sender.name != user.name
                          ? message.sender
                          : message.recipient,
                    ),
                  ),
                ),
              )
            : CustomListTile(
                isLeadingImage: false,
                leading: message.sender.name.substring(0, 1),
                title: message.sender.name,
                subtitle: formatMessage(),
                trailing: formatTime(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrivateChatScreen(
                      contact: message.sender.name != user.name
                          ? message.sender
                          : message.recipient,
                    ),
                  ),
                ),
              );
  }
}
