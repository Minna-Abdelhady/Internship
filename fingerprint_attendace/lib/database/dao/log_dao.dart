import 'package:hive/hive.dart';
import '../../models/log.dart';

class LogDao {
  static const String _logBoxName = 'logBox';

  Future<void> createLog(Log log) async {
    var box = await Hive.openBox<Log>(_logBoxName);
    await box.add(log);
  }

  Future<List<Log>> getAllLogs() async {
    var box = await Hive.openBox<Log>(_logBoxName);
    return box.values.toList();
  }

  Future<void> updateLog(int employeeId, DateTime timestamp, Log updatedLog) async {
    var box = await Hive.openBox<Log>(_logBoxName);
    final key = box.keys.firstWhere((k) => 
      (box.get(k) as Log).employeeId == employeeId && 
      (box.get(k) as Log).timestamp == timestamp
    );
    await box.put(key, updatedLog);
  }

  Future<void> deleteLog(int employeeId, DateTime timestamp) async {
    var box = await Hive.openBox<Log>(_logBoxName);
    final key = box.keys.firstWhere((k) => 
      (box.get(k) as Log).employeeId == employeeId && 
      (box.get(k) as Log).timestamp == timestamp
    );
    await box.delete(key);
  }
}
