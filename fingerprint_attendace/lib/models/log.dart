import 'package:hive/hive.dart';

part 'log.g.dart';

@HiveType(typeId: 1)
class Log {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String action;

  @HiveField(2)
  final String timestamp;

  Log({required this.id, required this.action, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'timestamp': timestamp,
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'],
      action: map['action'],
      timestamp: map['timestamp'],
    );
  }
}
