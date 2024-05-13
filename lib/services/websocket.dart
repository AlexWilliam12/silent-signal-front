import 'dart:async';
import 'dart:io';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  WebSocket? socket;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  Future<void> connect(String url, String token) async {
    socket = await WebSocket.connect(url, headers: {
      'Authorization': 'Bearer $token',
    });
  }
}
