import 'package:silent_signal/models/group_message.dart';
import 'package:silent_signal/models/user.dart';

class Group {
  final int id;
  final String name;
  final String? description;
  final User creator;
  final DateTime createdAt;
  final members = <User>[];
  final messages = <GroupMessage>[];

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creator,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creator: json['creator'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creator': creator,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
