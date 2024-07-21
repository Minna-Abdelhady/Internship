import 'package:hive/hive.dart';

part 'location.g.dart';

@HiveType(typeId: 1)
class Location {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String branch;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  Location({required this.id, required this.branch, required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch': branch,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      branch: map['branch'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
