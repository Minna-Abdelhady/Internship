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
        title: Text('Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _macAddressController,
                decoration: InputDecoration(labelText: 'MAC Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a MAC address';
                  }
                  return null;
                },
              ),
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
                    );
                    await _employeeDao.createEmployee(employee);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User added successfully')),
                    );

                    _nameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _macAddressController.clear();
                  }
                },
                child: Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
