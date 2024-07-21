import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 2)
class Attendance {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int employeeId;

  @HiveField(2)
  final String employeeName;

  @HiveField(3)
  final String branch;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String transaction;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.branch,
    required this.timestamp,
    required this.transaction,
  });
}
