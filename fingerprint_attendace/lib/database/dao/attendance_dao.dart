import 'package:hive/hive.dart';
import '../../models/attendance.dart';

class AttendanceDao {
  final Box<Attendance> _attendanceBox = Hive.box<Attendance>('attendance');

  Future<void> createOrUpdateAttendance(Attendance attendance) async {
    final key =
        '${attendance.userId}_${attendance.date.toIso8601String()}_${attendance.signInTime.toIso8601String()}';
    await _attendanceBox.put(key, attendance);
  }

  Future<List<Attendance>> getAttendanceByUserId(int userId) async {
    return _attendanceBox.values
        .where((attendance) => attendance.userId == userId)
        .toList();
  }

  Future<List<Attendance>> getAttendanceForWeek(int userId) async {
    DateTime now = DateTime.now();
    DateTime startOfRange = _getLastWorkingDay(now, 5);
    DateTime endOfRange = now;

    print('Querying for userId: $userId between $startOfRange and $endOfRange');

    return _attendanceBox.values
        .where((attendance) =>
            attendance.userId == userId &&
            attendance.date.isAfter(startOfRange.subtract(Duration(days: 1))) &&
            attendance.date.isBefore(endOfRange.add(Duration(days: 1))))
        .toList();
  }

  DateTime _getLastWorkingDay(DateTime date, int daysBack) {
    int workingDaysCount = 0;
    DateTime currentDate = date;

    while (workingDaysCount < daysBack) {
      currentDate = currentDate.subtract(Duration(days: 1));
      if (currentDate.weekday >= DateTime.monday &&
          currentDate.weekday <= DateTime.friday) {
        workingDaysCount++;
      }
    }

    return currentDate;
  }

  Future<void> insertDummyAttendanceData() async {
    final box = Hive.box<Attendance>('attendance');
    if (box.isNotEmpty) {
      print('Dummy data already exists');
      return;
    }

    DateTime today = DateTime.now();
    DateTime lastWorkingDay1 = _getLastWorkingDay(today, 1);
    DateTime lastWorkingDay2 = _getLastWorkingDay(today, 2);
    DateTime lastWorkingDay3 = _getLastWorkingDay(today, 3);
    DateTime lastWorkingDay4 = _getLastWorkingDay(today, 4);
    DateTime lastWorkingDay5 = _getLastWorkingDay(today, 5);

    final dummyAttendances = [
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay1,
        signInTime: lastWorkingDay1.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay1.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay1,
        signInTime: lastWorkingDay1.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay1.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay2,
        signInTime: lastWorkingDay2.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay2.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay2,
        signInTime: lastWorkingDay2.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay2.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay3,
        signInTime: lastWorkingDay3.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay3.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay3,
        signInTime: lastWorkingDay3.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay3.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay4,
        signInTime: lastWorkingDay4.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay4.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay4,
        signInTime: lastWorkingDay4.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay4.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay5,
        signInTime: lastWorkingDay5.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay5.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 3,
        transactionType: 'Sign In',
        date: lastWorkingDay5,
        signInTime: lastWorkingDay5.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay5.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay1,
        signInTime: lastWorkingDay1.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay1.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay1,
        signInTime: lastWorkingDay1.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay1.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay2,
        signInTime: lastWorkingDay2.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay2.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay2,
        signInTime: lastWorkingDay2.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay2.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay3,
        signInTime: lastWorkingDay3.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay3.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay3,
        signInTime: lastWorkingDay3.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay3.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay4,
        signInTime: lastWorkingDay4.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay4.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay4,
        signInTime: lastWorkingDay4.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay4.add(Duration(hours: 17)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay5,
        signInTime: lastWorkingDay5.add(Duration(hours: 9)),
        signOutTime: lastWorkingDay5.add(Duration(hours: 12)),
      ),
      Attendance(
        userId: 1,
        transactionType: 'Sign In',
        date: lastWorkingDay5,
        signInTime: lastWorkingDay5.add(Duration(hours: 12)),
        signOutTime: lastWorkingDay5.add(Duration(hours: 17)),
      ),
    ];

    await box.addAll(dummyAttendances);
  }
}
