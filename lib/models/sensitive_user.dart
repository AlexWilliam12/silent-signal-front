import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class SensitiveUser {
  final int id;
  final String name;
  final String hash;
  final String? picture;
  final DateTime createdAt;
  final createdGroups = <Group>[];
  final participateGroups = <Group>[];
  final contacts = <User>[];

  SensitiveUser({
    required this.id,
    required this.name,
    required this.hash,
    required this.picture,
    required this.createdAt,
  });

  factory SensitiveUser.fromJson(Map<String, dynamic> json) {
    return SensitiveUser(
      id: json['id'],
      name: json['name'],
      hash: json['credentials_hash'],
      picture: json['picture'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'credentials_hash': hash,
      'picture': picture,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
