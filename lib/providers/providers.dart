import 'package:flutter/material.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/services/user_service.dart';
import 'package:silent_signal/services/websocket_service.dart';

class PrivateChatProvider extends WebsocketService {}

class GroupChatProvider extends WebsocketService {}

class UserProvider with ChangeNotifier {
  SensitiveUser? _user;

  SensitiveUser? get user => _user;

  Future<void> provide() async {
    _user = await UserService().fetchUser();
    notifyListeners();
  }
}
