import 'package:hive/hive.dart';
import '../../models/log.dart';

class LogDao {
  static const String _logBoxName = 'logBox';

  Future<int> createLog(Log log) async {
    var box = await Hive.openBox<Log>(_logBoxName);
    await box.add(log);
    return log.id; // Assuming `id` is set correctly when the Log is created
  }

  Future<List<Log>> getAllLogs() async {
    var box = await Hive.openBox<Log>(_logBoxName);
    return box.values.toList();
  }

  Future<void> updateLog(int id, Log updatedLog) async {
    var box = await Hive.openBox<Log>(_logBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Log).id == id);
    await box.put(key, updatedLog);
  }

  Future<void> deleteLog(int id) async {
    var box = await Hive.openBox<Log>(_logBoxName);
    final key = box.keys.firstWhere((k) => (box.get(k) as Log).id == id);
    await box.delete(key);
  }
}
