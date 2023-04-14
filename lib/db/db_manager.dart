import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'garden_planting_dao.dart';
import 'plants_dao.dart';
import '../models/plant.dart';
import '../util/logger.dart';

// todo use some database framework plugin
class DbManager {
  static const _version = 1;
  static const _dbName = "sun_flower.db";

  static Database? _database;

  static init() async {
    final String path = join(await getDatabasesPath(), _dbName);

    _database = await openDatabase(
      path,
      version: _version,
      onCreate: (Database db, int version) async {
        VLog.d('onCreate db $_version');
        final batch = db.batch();
        batch.execute(PlantsDao().createTableSql());
        batch.execute(GardenPlantingDao().createTableSql());
        await batch.commit();
      },
    );
  }

  static check2InsertMockData() async {
    final dao = PlantsDao();
    final exist = await dao.hasPlants();
    if (exist) return;
    final src = await rootBundle.loadString('assets/data/plants.json');
    final parsed = jsonDecode(src).cast<Map<String, dynamic>>();
    final plants = parsed.map<Plant>((json) => Plant.fromJson(json)).toList();
    dao.insert(plants);
  }

  static isTableExist(String tableName) async {
    var db = await currentDb();
    var res = await db?.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.isNotEmpty;
  }

  static Future<Database?> currentDb() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  static close() {
    _database?.close();
    _database = null;
  }
}
