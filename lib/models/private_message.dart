import 'package:silent_signal/models/user.dart';

class PrivateMessage {
  final String type;
  final String content;
  final User sender;
  final User recipient;
  final DateTime createdAt;

  PrivateMessage({
    required this.type,
    required this.content,
    required this.sender,
    required this.recipient,
    required this.createdAt,
  });

  factory PrivateMessage.fromJson(Map<String, dynamic> json) {
    return PrivateMessage(
      type: json['type'],
      content: json['content'],
      sender: User.fromJson(json['sender']),
      recipient: User.fromJson(json['recipient']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'sender': sender,
      'recipient': recipient,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
