import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class SensitiveUser {
  final int id;
  final String name;
  final String hash;
  final String? picture;
  final DateTime createdAt;
  final String? temporaryMessageInterval;
  final List<Group> createdGroups;
  final List<Group> participateGroups;
  final List<User> contacts;

  SensitiveUser({
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

  factory SensitiveUser.fromJson(Map<String, dynamic> json) {
    final createdGroups = json['created_groups'] as List;
    final participateGroups = json['participate_groups'] as List;
    final contacts = json['contacts'] as List;
    return SensitiveUser(
      id: json['id'],
      name: json['name'],
      hash: json['credentials_hash'],
      picture: json['picture'],
      createdAt: DateTime.parse(json['created_at']),
      temporaryMessageInterval: json['time'],
      createdGroups: createdGroups
          .map(
            (e) => Group.fromJson(e),
          )
          .toList(),
      participateGroups: participateGroups
          .map(
            (e) => Group.fromJson(e),
          )
          .toList(),
      contacts: contacts
          .map(
            (e) => User.fromJson(e),
          )
          .toList(),
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
