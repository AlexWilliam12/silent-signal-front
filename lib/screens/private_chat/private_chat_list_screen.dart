import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/screens/private_chat/private_chat_list_widgets.dart';
import 'package:refactoring/view_models/chat_view_model.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/shared/load_screen.dart';

class PrivateChatListScreen extends StatelessWidget {
  const PrivateChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserViewModel>(context).user;
    final model = Provider.of<PrivateChatViewModel>(context);

    if (user == null) {
      return const LoadScreen();
    }
    return StreamBuilder(
      stream: model.stream,
      builder: (context, snapshot) {
        if (model.messages.isEmpty) {
          return const Center(
            child: Text('No contact messages available yet'),
          );
        } else {
          final messages = model.filterLastMessages(
            model.wrapList(),
            user.name,
          );
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return PrivateChatListTileLeading(
                user: user,
                message: message,
              );
            },
          );
        }
      },
    );
  }
}
