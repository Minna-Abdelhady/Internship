import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 3)
class Attendance {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int employeeId;

  @HiveField(2)
  final int locationId;

  @HiveField(3)
  final String checkInTime;

  Attendance({required this.id, required this.employeeId, required this.locationId, required this.checkInTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'locationId': locationId,
      'checkInTime': checkInTime,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      employeeId: map['employeeId'],
      locationId: map['locationId'],
      checkInTime: map['checkInTime'],
    );
  }
}
