import 'package:sqflite/sqflite.dart';
import 'package:task_management/models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDb() async {
    print("initDb");
    if (_db != null) {
      print("db is not null =>" + _db.toString());
      return;
    }
    try {
      print("create db:getDatabasesPath");
      var databasesPath = await getDatabasesPath();
      print("create db" + databasesPath);
      String _path = databasesPath + 'tasks.db';
      print("create db" + _path);
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title STRING, note TEXT, date STRING, startTime STRING, endTime STRING, remind INTEGER, repeat STRING, color INTEGER, isCompleted INTEGER)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<int?> insert(Task task) async {
    print("insert function called" + _db.toString());
    return await _db!.insert(_tableName, task.toJson());
  }

  static Future<int> delete(Task task) async =>
      await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);

  static Future<List<Map<String, dynamic>>> query() async {
    print("query function called" + _db.toString());
    return _db!.query(_tableName);
  }

  static Future<int> update(int id) async {
    print("update function called");
    return await _db!.rawUpdate('''
    UPDATE tasks   
    SET isCompleted = ?
    WHERE id = ?
    ''', [1, id]);
  }
}
