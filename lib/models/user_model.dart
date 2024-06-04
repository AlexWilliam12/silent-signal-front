class UserModel {
  final String name;
  final String? picture;

  UserModel({
    required this.name,
    required this.picture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'picture': picture,
    };
  }
}
