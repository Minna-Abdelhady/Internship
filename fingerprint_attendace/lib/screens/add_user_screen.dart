import 'package:flutter/material.dart';
import '../database/dao/employee_dao.dart';
import '../models/employee.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();
  final _companyIdController = TextEditingController(); // Added for company ID
  final EmployeeDao _employeeDao = EmployeeDao();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add User',
          style: TextStyle(color: Colors.white), // AppBar title color to white
        ),
        backgroundColor: Color(0xFF930000), // AppBar color to match company theme
        iconTheme: IconThemeData(
          color: Colors.white, // Back arrow color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              _buildTextField(_macAddressController, 'MAC Address'),
              _buildTextField(_companyIdController, 'Company ID'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final hashedPassword = _hashPassword(_passwordController.text);
                    final employee = Employee(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: _nameController.text,
                      email: _emailController.text,
                      password: hashedPassword,
                      macAddress: _macAddressController.text,
                      companyId: _companyIdController.text, // Include company ID
                    );
                    await _employeeDao.createEmployee(employee);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User added successfully')),
                    );

                    _nameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _macAddressController.clear();
                    _companyIdController.clear(); // Clear company ID field
                  }
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
                  'Add User',
                  style: TextStyle(color: Colors.white), // Button text color to white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF930000)), // Label color to match company theme
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
