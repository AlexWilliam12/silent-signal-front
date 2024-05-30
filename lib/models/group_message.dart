import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class GroupMessage {
  final int id;
  final String type;
  final String content;
  final User sender;
  final Group group;
  final DateTime createdAt;

  GroupMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.sender,
    required this.group,
    required this.createdAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      sender: json['sender'],
      group: json['group'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'sender': sender,
      'group': group,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
