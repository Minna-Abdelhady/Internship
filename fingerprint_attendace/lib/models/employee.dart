import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 2)
class Employee {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  Employee({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}
