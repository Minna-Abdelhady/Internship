import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee {

  @HiveField(0)
  final String companyId; // Added companyId field

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String macAddress;


  Employee({
    required this.companyId, 
    required this.name,
    required this.email,
    required this.password,
    required this.macAddress
  });
}
