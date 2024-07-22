import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/dao/employee_dao.dart';
import '../models/employee.dart';

class UsersListScreen extends StatelessWidget {
  final EmployeeDao employeeDao = EmployeeDao();

  Future<List<Employee>> _fetchEmployees() async {
    return await employeeDao.getAllEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
      ),
      body: FutureBuilder<List<Employee>>(
        future: _fetchEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found', style: TextStyle(color: Colors.black)));
          } else {
            final employees = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Email', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Password (Hidden)', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Personal Photo', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Job Title', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Is Director', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Director ID', style: TextStyle(color: Colors.black))),
                      ],
                      rows: employees.map((employee) {
                        return DataRow(
                          cells: [
                            DataCell(Text(employee.name, style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.email, style: TextStyle(color: Colors.black))),
                            DataCell(Text('********', style: TextStyle(color: Colors.black))), // Password hidden
                            DataCell(employee.personalPhoto.isNotEmpty
                                ? kIsWeb
                                    ? Image.network(
                                        employee.personalPhoto,
                                        height: 50,
                                        width: 50,
                                      )
                                    : Image.file(
                                        File(employee.personalPhoto),
                                        height: 50,
                                        width: 50,
                                      )
                                : Text('No photo', style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.jobTitle, style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.userType ? 'Yes' : 'No', style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.directorId.toString(), style: TextStyle(color: Colors.black))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      backgroundColor: Color(0xFFFFFFFF), // Set the background color to white
    );
  }
}
