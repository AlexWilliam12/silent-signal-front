import 'package:refactoring/models/group_message_model.dart';
import 'package:refactoring/models/user_model.dart';

class GroupModel {
  final int id;
  final String name;
  final String? description;
  final UserModel creator;
  final DateTime createdAt;
  final List<UserModel> members;
  final List<GroupMessageModel> messages;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creator,
    required this.createdAt,
    required this.members,
    required this.messages,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final members = json['members'] as List;
    final messages = json['messages'] as List;
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creator: json['creator'],
      createdAt: DateTime.parse(json['created_at']),
      members: members.map((e) => UserModel.fromJson(e)).toList(),
      messages: messages.map((e) => GroupMessageModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creator': creator,
      'created_at': createdAt.toIso8601String(),
      'members': members,
      'messages': messages,
    };
  }
}
