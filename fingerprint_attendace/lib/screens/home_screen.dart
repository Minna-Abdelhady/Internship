import 'package:flutter/material.dart';
import '../database/dao/employee_dao.dart';
import '../database/dao/location_dao.dart';
import '../models/employee.dart';
import 'dart:convert'; // For base64 decoding

class HomeScreen extends StatelessWidget {
  final String username;
  final EmployeeDao employeeDao = EmployeeDao();
  final LocationDao locationDao = LocationDao();

  HomeScreen({required this.username});

  Future<Employee> _fetchEmployeeData() async {
    final employees = await employeeDao.getAllEmployees();
    return employees.firstWhere((employee) => employee.name == username);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/company_logo.jpg', // Ensure you have your company's logo in assets folder
              height: kToolbarHeight - 5, // Adjust height to match AppBar height
            ),
          ),
        ],
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(base64Decode(employee.personalPhoto)),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Welcome, ${employee.name}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF930000), // Text color to match company theme
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  _buildInfoRow('Company ID:', employee.companyId),
                  SizedBox(height: 5),
                  _buildInfoRow('Email:', employee.email),
                  SizedBox(height: 5),
                  _buildInfoRow('Job Title:', employee.jobTitle),
                  SizedBox(height: 5),
                  _buildInfoRow('Director ID:', employee.directorId),
                  SizedBox(height: 5),
                  _buildInfoRow('Role:', employee.isAdmin ? 'Admin' : 'Employee'),
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Do nothing
                      },
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
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
