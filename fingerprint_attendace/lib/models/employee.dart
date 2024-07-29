import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 1)
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
  final String directorId;

  @HiveField(8)
  final bool isAdmin;

  Employee({
    required this.id,
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
      'id': id,
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
      id: map['id'],
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
