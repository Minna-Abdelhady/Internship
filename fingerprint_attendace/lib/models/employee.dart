import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 1)
class Employee {
  @HiveField(0)
  final int companyId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String personalPhoto;

  @HiveField(5)
  final String jobTitle;

  @HiveField(6)
  final int directorId;

  @HiveField(7)
  final bool isAdmin;

  Employee({
    required this.companyId,
    required this.name,
    required this.email,
    required this.password,
    required this.personalPhoto,
    required this.jobTitle,
    required this.directorId,
    required this.isAdmin,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'email': email,
      'password': password,
      'personalPhoto': personalPhoto,
      'jobTitle': jobTitle,
      'directorId': directorId,
      'isAdmin': isAdmin,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      companyId: map['companyId'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      personalPhoto: map['personalPhoto'],
      jobTitle: map['jobTitle'],
      directorId: map['directorId'],
      isAdmin: map['isAdmin'],
    );
  }
}
