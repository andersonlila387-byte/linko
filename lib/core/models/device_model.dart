class DeviceModel {
  final String id;
  final String name;
  final String platform; // 'android', 'windows', etc.
  final String ipAddress;
  final int port;
  bool isOnline;
  bool isLocal;
  DateTime lastSeen;

  DeviceModel({
    required this.id,
    required this.name,
    required this.platform,
    required this.ipAddress,
    required this.port,
    this.isOnline = true,
    this.isLocal = true,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'ip_address': ipAddress,
      'port': port,
      'is_online': isOnline ? 1 : 0,
      'is_local': isLocal ? 1 : 0,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      platform: map['platform'] as String,
      ipAddress: map['ip_address'] as String,
      port: map['port'] as int,
      isOnline: (map['is_online'] as int) == 1,
      isLocal: (map['is_local'] as int) == 1,
      lastSeen: DateTime.parse(map['last_seen'] as String),
    );
  }
}
