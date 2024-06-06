import 'package:refactoring/models/group_message_model.dart';
import 'package:refactoring/models/user_model.dart';

class GroupModel {
  final String name;
  final String? description;
  final String? picture;
  final UserModel? creator;
  final DateTime createdAt;
  final List<UserModel>? members;
  final List<GroupMessageModel>? messages;

  GroupModel({
    required this.name,
    required this.description,
    required this.picture,
    required this.creator,
    required this.createdAt,
    required this.members,
    required this.messages,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final members = json['members'] as List?;
    final messages = json['messages'] as List?;
    return GroupModel(
      name: json['name'],
      description: json['description'],
      picture: json['picture'],
      creator: json['creator'] != null
          ? UserModel.fromJson(
              json['creator'],
            )
          : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      members: members?.map((e) => UserModel.fromJson(e)).toList(),
      messages: messages?.map((e) => GroupMessageModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'picture': picture,
      'creator': creator,
      'created_at': createdAt.toIso8601String(),
      'members': members,
      'messages': messages,
    };
  }
}
