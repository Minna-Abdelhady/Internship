import 'package:hive/hive.dart';
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
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).id == id);
    await box.put(key, updatedEmployee);
  }

  Future<void> deleteEmployee(int id) async {
    var box = await Hive.openBox<Employee>(_employeeBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Employee).id == id);
    await box.delete(key);
  }
}
