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
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white), // AppBar title color to white
        ),
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $username',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF930000), // Text color to match company theme
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF930000), // Button color to match company theme
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(color: Colors.white), // Button text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
