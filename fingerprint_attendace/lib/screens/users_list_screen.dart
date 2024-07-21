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
                        DataColumn(label: Text('Company ID', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Name', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Password (Encrypted)', style: TextStyle(color: Colors.black))),
                        DataColumn(label: Text('Email', style: TextStyle(color: Colors.black))),
                      ],
                      rows: employees.map((employee) {
                        return DataRow(
                          cells: [
                            DataCell(Text(employee.companyId, style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.name, style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.password, style: TextStyle(color: Colors.black))),
                            DataCell(Text(employee.email, style: TextStyle(color: Colors.black))),
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
