import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/employee.dart';
import 'models/location.dart';
import 'models/attendance.dart';
import 'models/log.dart';
import 'models/code.dart';
import 'screens/login_screen.dart';
import 'database/dao/employee_dao.dart';
import 'database/dao/attendance_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();

    // Registering adapters for all the models if not already registered
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EmployeeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LocationAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AttendanceAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(LogAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(CodeAdapter());
    }

    // Open the required Hive boxes
    await Hive.openBox<Employee>('employees');
    await Hive.openBox<Attendance>('attendance');

    // Insert dummy data for employees and attendance
    final employeeDao = EmployeeDao();
    await employeeDao.insertDummyData(); // Insert dummy employee data
    print('Employee dummy data inserted.');

    final attendanceDao = AttendanceDao();
    await attendanceDao.insertDummyAttendanceData(); // Insert dummy attendance data
    print('Attendance dummy data inserted.');

    // var box = Hive.box<Attendance>('attendance');
    // print('Box content: ${box.values.toList()}');

    // final attendances = await AttendanceDao().getAttendanceForWeek(3);
    // print('Fetched attendances: $attendances');

    // DateTime now = DateTime.now();
    // DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    // print('Start of week: $startOfWeek, End of week: $endOfWeek');

    runApp(MyApp());
  } catch (e) {
    print('Error initializing Hive: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Color(0xFF930000), // Button color to match company theme
            padding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 40), // Bigger buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            textStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold), // Bigger font
            foregroundColor: Colors.white, // Button text color to white
            minimumSize: Size(200, 50), // Consistent button size
          ),
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: LoginScreen(), // Set the initial page to be the login screen
    );
  }
}
