import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/add_user_screen.dart';
import 'screens/users_list_screen.dart';
import 'models/employee.dart';
import 'models/location.dart';
import 'models/attendance.dart';
import 'models/log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registering adapters for all the models
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(LocationAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(LogAdapter());

  var box = await Hive.openBox<Employee>('employeeBox');

  // Insert 5 rows of data if the box is empty
  if (box.isEmpty) {
    var employees = [
      Employee(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
        password: 'encryptedPassword1',
        personalPhoto: 'assets/photos/photo1.jpg',
        jobTitle: 'Developer',
        directorId: 0,
        userType: false,
      ),
      Employee(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        password: 'encryptedPassword2',
        personalPhoto: 'assets/photos/photo2.jpg',
        jobTitle: 'Manager',
        directorId: 1,
        userType: true,
      ),
      Employee(
        id: 3,
        name: 'Alice Johnson',
        email: 'alice.johnson@example.com',
        password: 'encryptedPassword3',
        personalPhoto: 'assets/photos/photo3.jpg',
        jobTitle: 'Designer',
        directorId: 2,
        userType: false,
      ),
      Employee(
        id: 4,
        name: 'Bob Brown',
        email: 'bob.brown@example.com',
        password: 'encryptedPassword4',
        personalPhoto: 'assets/photos/photo4.jpg',
        jobTitle: 'Analyst',
        directorId: 2,
        userType: false,
      ),
      Employee(
        id: 5,
        name: 'Charlie Davis',
        email: 'charlie.davis@example.com',
        password: 'encryptedPassword5',
        personalPhoto: 'assets/photos/photo5.jpg',
        jobTitle: 'CEO',
        directorId: 0,
        userType: true,
      ),
    ];

    for (var employee in employees) {
      await box.put(employee.id, employee);
    }
  }

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
                    MaterialPageRoute(builder: (context) => AddUserScreen()),
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
