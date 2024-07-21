import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../models/employee.dart';

class EmployeeDao {
  static const String _employeeBoxName = 'employeeBox';

  Future<void> createEmployee(Employee employee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    await box.add(employee);
  }

  Future<List<Employee>> getAllEmployees() async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    return box.values.toList();
  }

  Future<void> updateEmployee(int id, Employee updatedEmployee) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).companyId == id);
    await box.put(key, updatedEmployee);
  }

  Future<void> deleteEmployee(int id) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).companyId == id);
    await box.delete(key);
  }

  Future<bool> authenticateUser(String name, String password) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final hashedPassword = _hashPassword(password);
    try {
      final employee = box.values.firstWhere(
        (employee) => employee.name == name && employee.password == hashedPassword,
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
}
