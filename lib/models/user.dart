class User {
  final String name;
  final String? picture;

  User({
    required this.name,
    required this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
