import 'package:refactoring/models/group_model.dart';
import 'package:refactoring/models/user_model.dart';

class SensitiveUserModel {
  final int id;
  final String name;
  final String hash;
  final String? picture;
  final DateTime createdAt;
  final String? temporaryMessageInterval;
  final List<GroupModel> createdGroups;
  final List<GroupModel> participateGroups;
  final List<UserModel> contacts;

  SensitiveUserModel({
    required this.id,
    required this.name,
    required this.hash,
    required this.picture,
    required this.createdAt,
    required this.temporaryMessageInterval,
    required this.createdGroups,
    required this.participateGroups,
    required this.contacts,
  });

  factory SensitiveUserModel.fromJson(Map<String, dynamic> json) {
    final createdGroups = json['created_groups'] as List;
    final participateGroups = json['participate_groups'] as List;
    final contacts = json['contacts'] as List;
    return SensitiveUserModel(
      id: json['id'],
      name: json['name'],
      hash: json['credentials_hash'],
      picture: json['picture'],
      createdAt: DateTime.parse(json['created_at']),
      temporaryMessageInterval: json['time'],
      createdGroups: createdGroups.map((e) => GroupModel.fromJson(e)).toList(),
      participateGroups:
          participateGroups.map((e) => GroupModel.fromJson(e)).toList(),
      contacts: contacts.map((e) => UserModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'credentials_hash': hash,
      'picture': picture,
      'created_at': createdAt.toIso8601String(),
      'time': temporaryMessageInterval,
      'created_groups': createdGroups,
      'participate_groups': participateGroups,
      'contacts': contacts,
    };
  }
}
