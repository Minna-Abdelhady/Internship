import 'package:flutter/material.dart';
import '../database/dao/employee_dao.dart';
import '../models/employee.dart';
import 'dart:convert';

class UsersListScreen extends StatelessWidget {
  final EmployeeDao employeeDao = EmployeeDao();

  Future<List<Employee>> _fetchEmployees() async {
    return await employeeDao.getAllEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/arrow_mm.png',
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Users List',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
      ),
      backgroundColor: Colors.white, // Set the background color to white
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
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Company ID', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Name', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Email', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Password (Hidden)', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Personal Photo', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Job Title', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Director ID', style: TextStyle(color: Colors.black))),
                  DataColumn(label: Text('Is Admin', style: TextStyle(color: Colors.black))),
                ],
                rows: employees.map((employee) {
                  return DataRow(
                    cells: [
                      DataCell(Text(employee.companyId, style: TextStyle(color: Colors.black))),
                      DataCell(Text(employee.name, style: TextStyle(color: Colors.black))),
                      DataCell(Text(employee.email, style: TextStyle(color: Colors.black))),
                      DataCell(Text('********', style: TextStyle(color: Colors.black))), // Hides password
                      DataCell(
                        employee.personalPhoto.isEmpty
                            ? Text('No Photo', style: TextStyle(color: Colors.black))
                            : Image.memory(
                                base64Decode(employee.personalPhoto),
                                height: 50,
                                width: 50,
                              ),
                      ),
                      DataCell(Text(employee.jobTitle, style: TextStyle(color: Colors.black))),
                      DataCell(Text(employee.directorId.toString(), style: TextStyle(color: Colors.black))),
                      DataCell(Text(employee.isAdmin ? 'Admin' : 'Employee'.toString(), style: TextStyle(color: Colors.black))),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}
