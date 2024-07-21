import 'package:hive/hive.dart';
import '../../models/location.dart';

class LocationDao {
  static const String _locationBoxName = 'locationBox';

  Future<void> createLocation(Location location) async {
    var box = await Hive.openBox<Location>(_locationBoxName);
    await box.add(location);
  }

  Future<List<Location>> getAllLocations() async {
    var box = await Hive.openBox<Location>(_locationBoxName);
    return box.values.toList();
  }

  Future<void> updateLocation(int id, Location updatedLocation) async {
    var box = await Hive.openBox<Location>(_locationBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Location).id == id);
    await box.put(key, updatedLocation);
  }

  Future<void> deleteLocation(int id) async {
    var box = await Hive.openBox<Location>(_locationBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Location).id == id);
    await box.delete(key);
  }
}
