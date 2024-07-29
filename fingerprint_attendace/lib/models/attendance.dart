// models/attendance.dart


import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 3)
class Attendance extends HiveObject {
  @HiveField(0)
  final int userId;
  
  @HiveField(1)
  final String transactionType;
  
  @HiveField(2)
  final DateTime date;
  
  @HiveField(3)
  final DateTime signInTime;
  
  @HiveField(4)
  final DateTime signOutTime;

  Attendance({
    required this.userId,
    required this.transactionType,
    required this.date,
    required this.signInTime,
    required this.signOutTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'transactionType': transactionType,
      'date': date.toIso8601String(),
      'signInTime': signInTime.toIso8601String(),
      'signOutTime': signOutTime.toIso8601String(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      userId: map['userId'],
      transactionType: map['transactionType'],
      date: DateTime.parse(map['date']),
      signInTime: DateTime.parse(map['signInTime']),
      signOutTime: DateTime.parse(map['signOutTime']),
    );
  }
}
