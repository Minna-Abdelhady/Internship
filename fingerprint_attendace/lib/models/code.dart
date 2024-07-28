import 'package:hive/hive.dart';

part 'code.g.dart';

@HiveType(typeId: 4)
class Code {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final int code;

  @HiveField(2)
  final DateTime timestamp;

  Code({
    required this.userId,
    required this.code,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'code': code,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Code.fromMap(Map<String, dynamic> map) {
    return Code(
      userId: map['userId'],
      code: map['code'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
