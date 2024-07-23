import 'package:flutter/material.dart';
import '../database/dao/employee_dao.dart';
import '../database/dao/location_dao.dart';
import '../models/employee.dart';
import 'dart:convert'; // For base64 decoding
import 'add_user_screen.dart' as add_user_screen; // Import the Add User screen
import 'users_list_screen.dart'; // Import the Users List screen

class HomeScreen extends StatelessWidget {
  final String email;
  final EmployeeDao employeeDao = EmployeeDao();
  final LocationDao locationDao = LocationDao();

  HomeScreen({required this.email});

  Future<Employee> _fetchEmployeeData() async {
    final employees = await employeeDao.getAllEmployees();
    return employees.firstWhere((employee) => employee.email == email);
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
        actions: [
          _buildAppBarButton(context, 'Sign In', () {
            // Navigate to Sign In screen
          }),
          _buildAppBarButton(context, 'History', () {
            // Navigate to History screen
          }),
          _buildAppBarButton(context, 'Vacations', () {
            // Navigate to Vacations screen
          }),
          _buildAppBarButton(context, 'Create User', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => add_user_screen.AddUserScreen()),
            );
          }),
          _buildAppBarButton(context, 'View Users', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UsersListScreen()),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/company_logo.jpg', // Ensure you have your company's logo in assets folder
              height: kToolbarHeight - 5, // Adjust height to match AppBar height
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Set the Scaffold background color to white
      body: FutureBuilder<Employee>(
        future: _fetchEmployeeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData) {
            return Center(child: Text('User not found', style: TextStyle(color: Colors.black)));
          } else {
            final employee = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Side profile on the left
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(base64Decode(employee.personalPhoto)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Welcome, ${employee.name}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF930000), // Text color to match company theme
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildInfoColumn(employee),
                    ],
                  ),
                  // Vertical divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: VerticalDivider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                  ),
                  // Main content area
                  Expanded(
                    child: Center(
                      child: Text(
                        'Main Content Area', // Placeholder for main content
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAppBarButton(BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(Employee employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Employee ID:', employee.companyId),
        SizedBox(height: 10),
        _buildInfoRow('Job Title:', employee.jobTitle),
        SizedBox(height: 10),
        _buildInfoRow('Role:', employee.isAdmin ? 'Admin' : 'Employee'),
        SizedBox(height: 10),
        _buildInfoRow('Email:', employee.email),
        SizedBox(height: 10),
        _buildInfoRow('Director ID:', employee.directorId),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ],
    );
  }
}
