import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../models/user.dart';

class UserDao {
  static const String _userBoxName = 'userBox';

  Future<void> createUser(User user) async {
    var box = await Hive.openBox<User>(_userBoxName);
    await box.add(user);
  }

  Future<void> createTestUser() async {
    var box = await Hive.openBox<User>(_userBoxName);
    final testUsername = 'testuser';
    final testPassword = 'password';
    
    final existingUser = box.values.firstWhere(
      (user) => user.username == testUsername,
      orElse: () => User(username: "", passwordHash: ""), // Placeholder user
    );

    if (existingUser.username.isEmpty) {
      print('Creating test user');
      final hashedPassword = hashPassword(testPassword);
      await box.add(User(username: testUsername, passwordHash: hashedPassword));
    } else {
      print('Test user already exists');
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> authenticateUser(String username, String password) async {
    var box = await Hive.openBox<User>(_userBoxName);
    final user = box.values.firstWhere(
      (user) => user.username == username,
      orElse: () => User(username: "", passwordHash: ""), // Placeholder user
    );

    if (user.username.isEmpty) return false;

    final hashedPassword = hashPassword(password);
    return user.passwordHash == hashedPassword;
  }

  Future<List<User>> getAllUsers() async {
    var box = await Hive.openBox<User>(_userBoxName);
    return box.values.toList();
  }
}
