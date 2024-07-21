import 'package:flutter/material.dart';
import '../database/dao/attendance_dao.dart';
import '../database/dao/employee_dao.dart';
import '../database/dao/location_dao.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../models/location.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final AttendanceDao attendanceDao = AttendanceDao();
  final EmployeeDao employeeDao = EmployeeDao();
  final LocationDao locationDao = LocationDao();

  HomeScreen({required this.username});

  Future<void> _signIn() async {
    final employees = await employeeDao.getAllEmployees();
    final locations = await locationDao.getAllLocations();
    
    // Assuming only one location and one employee for simplicity
    final employee = employees.firstWhere((employee) => employee.name == username);
    final location = locations.first; // Replace with actual location logic
    
    final attendance = Attendance(
      id: DateTime.now().millisecondsSinceEpoch,
      employeeId: employee.id,
      employeeName: employee.name,
      branch: location.branch,
      timestamp: DateTime.now(),
      transaction: 'sign in',
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
