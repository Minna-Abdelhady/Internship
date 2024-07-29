import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import '../../models/employee.dart';
import '../../models/code.dart';
import '../../models/attendance.dart';

class EmployeeDao {
  static const String _employeeBoxName = 'employeeBox';
  static const String _codeBoxName = 'codeBox';

  Future<List<Attendance>> getAttendanceByUserId(String userId) async {
    var box = await Hive.openBox<Attendance>('attendanceBox');
    return box.values.where((attendance) => attendance.userId == userId).toList();
  }

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

  Future<void> updateEmployee(int companyId, Employee updatedEmployee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as Employee).companyId == companyId,
      orElse: () => throw Exception('Employee not found'),
    );
    await box.put(key, updatedEmployee);
  }

  Future<void> deleteEmployee(int companyId) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as Employee).companyId == companyId,
      orElse: () => throw Exception('Employee not found'),
    );
    await box.delete(key);
  }

  Future<bool> authenticateUser(String email, String password) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final hashedPassword = _hashPassword(password);

    final employee = box.values.firstWhere(
      (employee) =>
          employee.email == email.toLowerCase() &&
          employee.password == hashedPassword,
      orElse: () => Employee(
          companyId: 0,
          name: '',
          email: '',
          password: '',
          personalPhoto: '',
          jobTitle: '',
          directorId: 0,
          isAdmin: false),
    );

    return employee.companyId != 0;
  }

  Future<bool> emailExists(String email) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);

    try {
      final employee = box.values.firstWhere(
        (employee) => employee.email == email.toLowerCase(),
        orElse: () => Employee(
            companyId: 0,
            name: '',
            email: '',
            password: '',
            personalPhoto: '',
            jobTitle: '',
            directorId: 0,
            isAdmin: false),
      );
      return employee.companyId != 0;
    } catch (e) {
      // Handle the exception if needed
      return false;
    }
  }

  Future<bool> employeeIdExists(int employeeId) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.any((employee) => employee.companyId == employeeId);
  }

  Future<bool> doesDirectorExist(int directorId) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final director = box.values.firstWhere(
      (employee) => employee.companyId == directorId && employee.isAdmin,
      orElse: () => Employee(
        companyId: 0,
        name: 'Unknown',
        email: '',
        password: '',
        personalPhoto: '',
        jobTitle: '',
        directorId: 0,
        isAdmin: false,
      ),
    );

    return director.companyId != 0;
  }

  Future<List<Employee>> getAllDirectors() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.where((employee) => employee.isAdmin).toList();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> insertDummyData() async {
    if (await employeeIdExists(1) && await employeeIdExists(2) && await employeeIdExists(3)) {
      print('Dummy data already exists');
      return;
    }

    final byteData = await rootBundle.load('assets/Apartments.PNG');
    final imageBytes = byteData.buffer.asUint8List();
    final base64Image = base64Encode(imageBytes);

    final byteData1 = await rootBundle.load('assets/Nouna.jpg');
    final imageBytes1 = byteData1.buffer.asUint8List();
    final base64Image1 = base64Encode(imageBytes1);

    final dummyEmployees = [
      Employee(
        companyId: 1,
        name: 'Dina Aref',
        email: 'dinaref@gmail.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image1,
        jobTitle: 'Software Engineer Intern',
        directorId: 3,
        isAdmin: true,
      ),
      Employee(
        companyId: 2,
        name: 'Minna Hany',
        email: 'minnaabdelhady@gmail.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'Software Engineer Intern',
        directorId: 3,
        isAdmin: true,
      ),
      Employee(
        companyId: 3,
        name: 'mike johnson',
        email: 'mike@example.com',
        password: _hashPassword('123'),
        personalPhoto: base64Image,
        jobTitle: 'UX Designer',
        directorId: 3,
        isAdmin: false,
      ),
    ];

    for (var employee in dummyEmployees) {
      await createEmployee(employee);
    }
  }

  Future<void> saveVerificationCode(String email, String code) async {
    var box = await Hive.openBox<Code>(_codeBoxName);
    var employeeBox = await Hive.openBox<Employee>(_employeeBoxName);
    final employee = employeeBox.values.firstWhere(
      (employee) => employee.email == email.toLowerCase(),
      orElse: () => throw Exception('Employee not found'),
    );

    final verificationCode = Code(
      userId: employee.companyId,
      code: int.parse(code),
      timestamp: DateTime.now(),
    );

    try {
      print('Saving verification code: ${verificationCode.toMap()}');
      await box.put(employee.companyId, verificationCode);
      print('Verification code saved successfully');
    } catch (e) {
      print('Error saving verification code: $e');
    }
  }

  Future<Code?> getVerificationCode(String email) async {
    var box = await Hive.openBox<Code>(_codeBoxName);
    var employeeBox = await Hive.openBox<Employee>(_employeeBoxName);
    final employee = employeeBox.values.firstWhere(
      (employee) => employee.email == email.toLowerCase(),
      orElse: () => throw Exception('Employee not found'),
    );
    return box.get(employee.companyId);
  }

  Future<Employee> getEmployeeByCompanyId(int companyId) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    try {
      final employee = box.values.firstWhere(
        (employee) => employee.companyId == companyId,
        orElse: () => Employee(
          companyId: 0,
          name: 'Unknown',
          email: '',
          password: '',
          personalPhoto: '',
          jobTitle: '',
          directorId: 0,
          isAdmin: false,
        ),
      );

      if (employee.companyId == 0) {
        // Employee with company ID not found
      } else {
        // Employee found
      }
      return employee;
    } catch (e) {
      // Handle the error
      return Employee(
        companyId: 0,
        name: 'Unknown',
        email: '',
        password: '',
        personalPhoto: '',
        jobTitle: '',
        directorId: 0,
        isAdmin: false,
      );
    }
  }
}
