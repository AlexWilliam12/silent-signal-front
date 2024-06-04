import 'package:refactoring/models/user_model.dart';

class PrivateMessageModel {
  final String type;
  final String content;
  final UserModel sender;
  final UserModel recipient;
  final DateTime createdAt;

  PrivateMessageModel({
    required this.type,
    required this.content,
    required this.sender,
    required this.recipient,
    required this.createdAt,
  });

  factory PrivateMessageModel.fromJson(Map<String, dynamic> json) {
    return PrivateMessageModel(
      type: json['type'],
      content: json['content'],
      sender: UserModel.fromJson(json['sender']),
      recipient: UserModel.fromJson(json['recipient']),
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
