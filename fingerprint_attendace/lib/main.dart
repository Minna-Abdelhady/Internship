import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/add_user_screen.dart' as add_user_screen; // Prefix the import
import 'screens/users_list_screen.dart';
import 'models/employee.dart';
import 'models/location.dart';
import 'models/attendance.dart';
import 'models/log.dart';
import 'database/dao/employee_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registering adapters for all the models
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(LocationAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(LogAdapter());

  final employeeDao = EmployeeDao();
  await employeeDao.insertDummyData(); // Insert dummy data

  runApp(MyApp());
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
            backgroundColor: Color(0xFF930000), // Button color to match company theme
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Bigger buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Bigger font
            foregroundColor: Colors.white, // Button text color to white
            minimumSize: Size(200, 50), // Consistent button size
          ),
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Main Page',
          style: TextStyle(color: Colors.white), // AppBar title color to white
        ),
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => add_user_screen.AddUserScreen()),
                  );
                },
                child: Text('Create User'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UsersListScreen()),
                  );
                },
                child: Text('View Users'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
