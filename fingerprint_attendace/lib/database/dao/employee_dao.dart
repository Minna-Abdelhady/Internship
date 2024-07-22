import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../../models/employee.dart';

class EmployeeDao {
  static const String _employeeBoxName = 'employeeBox';

  Future<void> createEmployee(Employee employee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    print('Adding employee: ${employee.toMap()}');
    await box.add(employee); // Use add to let Hive manage the key
    print('Employee added');
  }

  Future<List<Employee>> getAllEmployees() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.toList();
  }

  Future<void> updateEmployee(int id, Employee updatedEmployee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).id == id);
    await box.put(key, updatedEmployee);
  }

  Future<void> deleteEmployee(int id) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).id == id);
    await box.delete(key);
  }

  Future<bool> authenticateUser(String name, String password) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final hashedPassword = _hashPassword(password);
    try {
      final employee = box.values.firstWhere(
        (employee) => employee.name == name.toLowerCase() && employee.password == hashedPassword,
      );
      return employee != null;
    } catch (e) {
      return false;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> insertDummyData() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);

    // Load the image from assets and convert it to base64
    final byteData = await rootBundle.load('assets/Apartments.PNG');
    final imageBytes = byteData.buffer.asUint8List();
    final base64Image = base64Encode(imageBytes);

    final dummyEmployees = [
      Employee(
        id: 1,
        companyId: '123456',
        name: 'nouna',
        email: 'nouna@example.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'Software Engineer',
        directorId: '456',
      ),
      Employee(
        id: 2,
        companyId: '654321',
        name: 'minna',
        email: 'minna@example.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'Product Manager',
        directorId: '123',
      ),
      Employee(
        id: 3,
        companyId: '789012',
        name: 'mike johnson',
        email: 'mike.johnson@example.com',
        password: _hashPassword('password3'),
        personalPhoto: base64Image,
        jobTitle: 'UX Designer',
        directorId: '789',
      ),
    ];

    for (var employee in dummyEmployees) {
      await box.add(employee); // Use add to let Hive manage the key
      print('Dummy employee added: ${employee.name}');
    }
  }
}
