import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_tracker/objects/todo.dart';
import 'package:time_tracker/objects/type.dart';

class DatabaseHelper {
  
  static final dataBaseName = "TodoDatabase.db";
  static final todoTable = 'todoTable';
  static final typeTable = 'typeTable';

  static final _databaseVersion = 1;



  Database _database;

  static DatabaseHelper _databaseHelper;
  static Future<DatabaseHelper> getDatabase()async {
    if(_databaseHelper==null){
      _databaseHelper = DatabaseHelper();
    }
    if (_databaseHelper._database != null) return _databaseHelper;
    _databaseHelper._database = await _databaseHelper._initDatabase();
    return _databaseHelper;
  }
  
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dataBaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $todoTable (
            id INTEGER PRIMARY KEY,
            typeId INTEGER,
            name TEXT NOT NULL,
            value INTEGER NOT NULL,
            lastChecked TEXT,
            startTime TEXT,
            endTime TEXT,
            childs TEXT,
            timeEstimated INTEGER,
            repeatEvery INTEGER
          )
          ''');
    await db.execute('''
          CREATE TABLE $typeTable (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            color INTEGER NOT NULL,
            repeatEvery INTEGER
          )
          ''');
  }
  


  Future<int> insertTodo(Todo todo) async {
    return await _database.insert(todoTable, todo.toMap());
  }



  Future<List<Todo>> queryAllTodos() async {
    List<Map> items =  await _database.query(todoTable);
    return List.generate(items.length, (index){
      return Todo.fromMap(items[index]);
    });
  }


  Future<int> updateTodo(Todo todo) async {
    return await _database.update(todoTable, todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async {
    return await _database.delete(todoTable, where: 'id = ?', whereArgs: [id]);
  }






  Future<int> insertType(TodoType todo) async {
    return await _database.insert(typeTable, todo.toMap());
  }

  Future<List<TodoType>> queryAllTypes() async {
    List<Map> items =  await _database.query(typeTable);
    return List.generate(items.length, (index){
      return TodoType.fromMap(items[index]);
    });
  }


  Future<int> updateType(TodoType todo) async {
    return await _database.update(typeTable, todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteType(int id) async {
    return await _database.delete(typeTable, where: 'id = ?', whereArgs: [id]);
  }
  
}