import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  WebSocket? _socket;
  final StreamController<dynamic> _streamController = StreamController.broadcast();

  Stream<dynamic> get messages => _streamController.stream;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  Future<void> connect(String url, String token) async {
    _socket = await WebSocket.connect(url, headers: {
      'Authorization': 'Bearer $token',
    });
    _socket!.listen((message) {
      _streamController.add(message);
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    _socket!.add(json.encode(message));
  }

  void dispose() {
    _socket!.close();
    _streamController.close();
  }
}
