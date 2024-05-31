import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivateChatService with ChangeNotifier {
  final _controller = StreamController.broadcast();
  WebSocket? _socket;
  List _messages = [];

  Stream get stream => _controller.stream;
  List get messages => _messages;

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.get('token') as String;
    final host = prefs.get('host') as String;
    _socket = await WebSocket.connect('ws://$host/chat/private', headers: {
      'Authorization': 'Bearer $token',
    });
    _socket!.listen((content) {
      final decodedContent = jsonDecode(content);
      if (decodedContent is List) {
        _messages = decodedContent;
      } else {
        _messages.add(decodedContent);
      }
      _controller.add(decodedContent);
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
