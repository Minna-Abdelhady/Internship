import 'package:hive/hive.dart';

part 'log.g.dart';

@HiveType(typeId: 4)
class Log {
  @HiveField(0)
  final int employeeId;

  @HiveField(1)
  final String employeeName;

  @HiveField(2)
  final String branch;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String transaction;

  Log({
    required this.employeeId,
    required this.employeeName,
    required this.branch,
    required this.timestamp,
    required this.transaction,
  });
}
