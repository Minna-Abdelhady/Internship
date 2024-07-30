// location.dart
import 'package:hive/hive.dart';

part 'location.g.dart';

@HiveType(typeId: 2)
class Location {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final double companyLatitude;

  @HiveField(2)
  final double companyLongitude;

  @HiveField(3)
  final double userLatitude;

  @HiveField(4)
  final double userLongitude;

  Location({
    required this.userId,
    required this.companyLatitude,
    required this.companyLongitude,
    required this.userLatitude,
    required this.userLongitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'companyLatitude': companyLatitude,
      'companyLongitude': companyLongitude,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      userId: map['userId'],
      companyLatitude: map['companyLatitude'],
      companyLongitude: map['companyLongitude'],
      userLatitude: map['userLatitude'],
      userLongitude: map['userLongitude'],
    );
  }
}
