import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;

class DatabaseHelper {
  static final _databaseName = "localStore.db";
  static final _databaseVersion = 1;

  static final readData = 'ReadData';

  static final isSynced = 'isSynced';
  static final flatID = 'flatID';
  static final type = 'type';
  static final lastSeen = 'lastSeen';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $readData (
            $type TEXT NOT NULL,
            $flatID TEXT NOT NULL,
            $lastSeen INTEGER NOT NULL,
            PRIMARY KEY ($type, $flatID)
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(readData, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryRows(t) async {
    Database db = await instance.database;
    return await db.query(readData, where: '$type = ?', whereArgs: [t]);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(readData);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $readData'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  // Future<int> update(Map<String, dynamic> row) async {
  //   Database db = await instance.database;
  //   String id = row['type'];
  //   return await db.update(readData, row, where: '$type = ?', whereArgs: [id]);
  // }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  // Future<int> delete(String id) async {
  //   Database db = await instance.database;
  //   return await db.delete(readData, where: '$type = ?', whereArgs: [id]);
  // }

  // Future<int> deleteAll(String id) async {
  //   Database db = await instance.database;
  //   return await db.delete(readData);
  // }
}
