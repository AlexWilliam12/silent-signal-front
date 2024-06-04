import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:refactoring/consts/chat_mode.dart';
import 'package:refactoring/models/group_message_model.dart';
import 'package:refactoring/models/private_message_model.dart';
import 'package:refactoring/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateChatViewModel extends _ChatViewModel {
  List<PrivateMessageModel> wrapList() {
    return super.messages.map((e) => PrivateMessageModel.fromJson(e)).toList();
  }

  List<PrivateMessageModel> filterLastMessages(
    List<PrivateMessageModel> messages,
    String user,
  ) {
    final lastMessages = <String, PrivateMessageModel>{};
    for (var message in messages) {
      UserModel otherUser;
      if (message.sender.name == user) {
        otherUser = message.recipient;
      } else if (message.recipient.name == user) {
        otherUser = message.sender;
      } else {
        continue;
      }

      if (!lastMessages.containsKey(otherUser.name) ||
          lastMessages[otherUser.name]!.createdAt.isBefore(message.createdAt)) {
        lastMessages[otherUser.name] = message;
      }
    }
    return lastMessages.values.toList();
  }

  List<PrivateMessageModel> filterByUsers(
    String user,
    String contact,
    List<PrivateMessageModel> messages,
  ) =>
      messages
          .where(
            (message) =>
                (message.sender.name == user &&
                    message.recipient.name == contact) ||
                (message.recipient.name == user &&
                    message.sender.name == contact),
          )
          .toList();
}

class GroupChatViewModel extends _ChatViewModel {
  List<GroupMessageModel> wrapList() {
    return super.messages.map((e) => GroupMessageModel.fromJson(e)).toList();
  }
}

class _ChatViewModel with ChangeNotifier {
  final _controller = StreamController.broadcast();
  WebSocket? _socket;
  final List _messages = [];

  Stream get stream => _controller.stream;
  List get messages => _messages;

  Future<void> connect(ChatMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.get('token') as String;
    final host = prefs.get('host') as String;
    _socket = await WebSocket.connect(
        'ws://$host/chat/${mode.name.toLowerCase()}',
        headers: {
          'Authorization': 'Bearer $token',
        });
    _socket!.listen((content) {
      final decodedContent = jsonDecode(content);
      if (decodedContent is List) {
        _messages.addAll(decodedContent);
        _controller.add(messages.length);
      } else {
        _messages.add(decodedContent);
        _controller.add(messages.length);
      }
      notifyListeners();
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    _socket!.add(json.encode(message));
  }

  @override
  void dispose() {
    _socket!.close();
    _controller.close();
    super.dispose();
  }
}
