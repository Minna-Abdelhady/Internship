import 'package:flutter/material.dart';
import '../database/dao/attendance_dao.dart';
import '../models/attendance.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final AttendanceDao attendanceDao = AttendanceDao();

  HomeScreen({required this.username});

  Future<void> _signIn() async {
    final attendance = Attendance(
      id: DateTime.now().millisecondsSinceEpoch,
      employeeId: 1, // This should be fetched based on the username.
      locationId: 1, // This can be fetched or set based on the actual location.
      checkInTime: DateTime.now().toIso8601String(),
    );
    await attendanceDao.createAttendance(attendance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $username', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
