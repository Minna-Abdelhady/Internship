import 'package:hive/hive.dart';
import '../../models/attendance.dart';

class AttendanceDao {
  static const String _attendanceBoxName = 'attendanceBox';

  Future<void> createAttendance(Attendance attendance) async {
    var box = await Hive.openBox<Attendance>(_attendanceBoxName);
    await box.add(attendance);
  }

  Future<List<Attendance>> getAllAttendance() async {
    var box = await Hive.openBox<Attendance>(_attendanceBoxName);
    return box.values.toList();
  }

  Future<void> updateAttendance(int id, Attendance updatedAttendance) async {
    var box = await Hive.openBox<Attendance>(_attendanceBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Attendance).employeeId == id);
    await box.put(key, updatedAttendance);
  }

  Future<void> deleteAttendance(int id) async {
    var box = await Hive.openBox<Attendance>(_attendanceBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Attendance).employeeId == id);
    await box.delete(key);
  }
}
