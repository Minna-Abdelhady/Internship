import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String macAddress;

  @HiveField(5)
  final String companyId; // Added companyId field

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.macAddress,
    required this.companyId, // Include companyId in the constructor
  });
}
