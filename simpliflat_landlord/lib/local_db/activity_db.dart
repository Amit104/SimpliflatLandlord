import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';


class ActivityDB {
  static final _databaseName = "localStore.db";
  static final _databaseVersion = 1;

  static final activities = 'ACTIVITIES';

  static final isSynced = 'isSynced';

  // make this a singleton class
  ActivityDB._privateConstructor();
  static final ActivityDB instance = ActivityDB._privateConstructor();

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
          CREATE TABLE ACTIVITIES (
            activityId TEXT NOT NULL,
            senderName TEXT,
            title TEXT,
            message TEXT,
            buildingName TEXT,
            ownerFlatName TEXT,
            ownerFlatId TEXT,
            tenantFlatId TEXT,
            ownerTenantFlatId TEXT,
            timestamp INT,
            documentId TEXT,
            PRIMARY KEY (activityId)
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(activities, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryRowsByDateRange(int from, int to) async {
    Database db = await instance.database;
    return await db.query(activities, where: 'timestamp >= ? and timestamp <= ?', whereArgs: [from, to]);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(activities);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $activities'));
  }
}