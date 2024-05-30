import 'package:silent_signal/models/user.dart';

class PrivateMessage {
  final int id;
  final String type;
  final String content;
  final User sender;
  final User recipient;
  final DateTime createdAt;

  PrivateMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.sender,
    required this.recipient,
    required this.createdAt,
  });

  factory PrivateMessage.fromJson(Map<String, dynamic> json) {
    return PrivateMessage(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      sender: json['sender'],
      recipient: json['recipient'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'sender': sender,
      'recipient': recipient,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
