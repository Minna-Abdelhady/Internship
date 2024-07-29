import 'package:hive/hive.dart';
import '../../models/attendance.dart';

class AttendanceDao {
  final Box<Attendance> _attendanceBox = Hive.box<Attendance>('attendance');

  Future<void> createOrUpdateAttendance(Attendance attendance) async {
    // Use userId and date as a unique identifier
    final key = '${attendance.userId}_${attendance.date.toIso8601String()}';
    await _attendanceBox.put(key, attendance);
  }

  Future<List<Attendance>> getAttendanceByUserId(String userId) async {
    return _attendanceBox.values.where((attendance) => attendance.userId == userId).toList();
  }
}

