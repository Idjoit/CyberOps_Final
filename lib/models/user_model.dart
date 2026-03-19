class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'user_id': id,
        'username': username,
        'password': password,
        'role': role,
        'created_at': createdAt,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['user_id'],
        username: map['username'],
        password: map['password'],
        role: map['role'],
        createdAt: map['created_at'],
      );
}
