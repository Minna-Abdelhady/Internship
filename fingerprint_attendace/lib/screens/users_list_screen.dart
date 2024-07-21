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
        title: Text('Users List'),
      ),
      body: FutureBuilder<List<Employee>>(
        future: _fetchEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            final employees = snapshot.data!;
            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return ListTile(
                  title: Text(employee.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Company ID: ${employee.companyId}'),
                      Text('Email: ${employee.email}'),
                      Text('Password (hashed): ${employee.password}'),
                      Text('MAC Address: ${employee.macAddress}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
