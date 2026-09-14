class UserModel {
  final String id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  final String boundDeviceId;

  UserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.boundDeviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'bound_device_id': boundDeviceId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      boundDeviceId: (map['bound_device_id'] as String?) ?? (map['id'] as String? ?? ''),
    );
  }
}
