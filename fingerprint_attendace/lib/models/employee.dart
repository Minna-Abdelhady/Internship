import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String companyId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String password;

  @HiveField(5)
  final String personalPhoto;

  @HiveField(6)
  final String jobTitle;

  @HiveField(7)
  final int directorId;

  Employee({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    required this.password,
    required this.personalPhoto,
    required this.jobTitle,
    required this.directorId,
  });
}
