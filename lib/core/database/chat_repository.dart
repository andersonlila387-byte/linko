import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message_model.dart';
import '../models/device_model.dart';
import '../models/user_model.dart';

class ChatRepository {
  static Database? _database;
  static final List<MessageModel> _webMessages = [];
  static final List<DeviceModel> _webDevices = [];
  static final List<UserModel> _webUsers = [];

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'linko_chat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            sender_device_id TEXT NOT NULL,
            receiver_device_id TEXT NOT NULL,
            type TEXT NOT NULL,
            content TEXT NOT NULL,
            file_name TEXT,
            file_size INTEGER,
            is_view_once INTEGER NOT NULL DEFAULT 0,
            transfer_state TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            is_consumed INTEGER NOT NULL DEFAULT 0,
            consumed_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE devices (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            platform TEXT NOT NULL,
            ip_address TEXT NOT NULL,
            port INTEGER NOT NULL,
            is_online INTEGER NOT NULL DEFAULT 1,
            is_local INTEGER NOT NULL DEFAULT 1,
            last_seen TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            created_at TEXT NOT NULL,
            bound_device_id TEXT NOT NULL DEFAULT ''
          )
        ''');
      },
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            created_at TEXT NOT NULL,
            bound_device_id TEXT NOT NULL DEFAULT ''
          )
        ''');
        try {
          await db.execute('ALTER TABLE users ADD COLUMN bound_device_id TEXT NOT NULL DEFAULT ""');
        } catch (_) {
          // Column may already exist
        }
      },
    );
  }

  // User Operations
  Future<UserModel?> getUserByUsername(String username) async {
    final cleanName = username.trim().toLowerCase();
    if (cleanName.isEmpty) return null;

    if (kIsWeb) {
      try {
        return _webUsers.firstWhere(
          (u) => u.username.toLowerCase() == cleanName,
        );
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [cleanName],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> createUser(UserModel user) async {
    if (kIsWeb) {
      _webUsers.add(user);
      return;
    }

    final db = await database;
    if (db != null) {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  // Message Operations
  Future<void> saveMessage(MessageModel message) async {
    if (kIsWeb) {
      final idx = _webMessages.indexWhere((m) => m.id == message.id);
      if (idx >= 0) {
        _webMessages[idx] = message;
      } else {
        _webMessages.add(message);
      }
      return;
    }

    final db = await database;
    await db!.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMessage(MessageModel message) async {
    if (kIsWeb) {
      final idx = _webMessages.indexWhere((m) => m.id == message.id);
      if (idx >= 0) {
        _webMessages[idx] = message;
      }
      return;
    }

    final db = await database;
    await db!.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> updateTransferState(String messageId, TransferState state) async {
    if (kIsWeb) {
      final idx = _webMessages.indexWhere((m) => m.id == messageId);
      if (idx >= 0) {
        _webMessages[idx].transferState = state;
      }
      return;
    }

    final db = await database;
    await db!.update(
      'messages',
      {'transfer_state': state.name},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<MessageModel>> getMessagesForDevice(String deviceId) async {
    if (kIsWeb) {
      return _webMessages
          .where((m) => m.senderDeviceId == deviceId || m.receiverDeviceId == deviceId)
          .toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'messages',
      where: 'sender_device_id = ? OR receiver_device_id = ?',
      whereArgs: [deviceId, deviceId],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) => MessageModel.fromMap(maps[i]));
  }

  // Device Operations
  Future<void> saveDevice(DeviceModel device) async {
    if (kIsWeb) {
      final idx = _webDevices.indexWhere((d) => d.id == device.id);
      if (idx >= 0) {
        _webDevices[idx] = device;
      } else {
        _webDevices.add(device);
      }
      return;
    }

    final db = await database;
    await db!.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeviceModel>> getDevices() async {
    if (kIsWeb) {
      return List.from(_webDevices);
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('devices');
    return List.generate(maps.length, (i) => DeviceModel.fromMap(maps[i]));
  }
}
