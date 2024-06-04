import 'package:refactoring/models/group_model.dart';
import 'package:refactoring/models/user_model.dart';

class GroupMessageModel {
  final int id;
  final String type;
  final String content;
  final UserModel sender;
  final GroupModel group;
  final DateTime createdAt;

  GroupMessageModel({
    required this.id,
    required this.type,
    required this.content,
    required this.sender,
    required this.group,
    required this.createdAt,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
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
