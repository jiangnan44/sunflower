import '../models/garden_planting.dart';
import '../models/planting_plants.dart';
import 'db_base_dao.dart';
import 'db_manager.dart';
import 'plants_dao.dart';

class GardenPlantingDao extends BaseDbDao {
  static const String tableName = "garden_plantings";
  final String _cId = "_id";
  final String _cPlantId = "plant_id";
  final String _cPlantTime = "plant_time";
  final String _cLastWateringTime = "last_watering_time";

  @override
  String createColumns() {
    return '''
   $_cId integer primary key autoincrement,
   $_cPlantId TEXT,
   $_cPlantTime integer,
   $_cLastWateringTime integer
   ''';
  }

  @override
  String innerTableName() {
    return tableName;
  }

  Map<String, dynamic> toMap(GardenPlanting planting) {
    return {
      _cPlantId: planting.plantId,
      _cPlantTime: planting.plantTime,
      _cLastWateringTime: planting.lastWateringTime,
    };
  }

  GardenPlanting toEntity(Map<String, dynamic> map) {
    return GardenPlanting(
      plantId: map[_cPlantId],
      plantTime: map[_cPlantTime],
      lastWateringTime: map[_cLastWateringTime],
    );
  }

  Future<List<GardenPlanting>?> queryGardenPlantings() async {
    final db = await DbManager.currentDb();
    if (null == db) return null;

    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if (maps.isEmpty) return null;

    return List.generate(maps.length, (index) => toEntity(maps[index]));
  }

  Future<bool> isPlanted(String plantId) async {
    final db = await DbManager.currentDb();
    if (null == db) return false;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: ' $_cPlantId = ? ',
      whereArgs: [plantId],
    );

    return maps.isNotEmpty;
  }

  Future<bool> updateWateringTime(String plantId, int time) async {
    final db = await DbManager.currentDb();
    if (null == db) return false;

    final ret = await db.update(
      tableName,
      {_cLastWateringTime: time},
      where: ' $_cPlantId = ? ',
      whereArgs: [plantId],
    );

    return ret > 0;
  }

  /// this is bad,only for demo
  Future<List<PlantingPlant>?> queryPlantingPlants() async {
    final db = await DbManager.currentDb();
    if (null == db) return null;

    final List<Map<String, dynamic>> maps = await db.query(tableName);
    if (maps.isEmpty) return null;

    final plantings =
        List.generate(maps.length, (index) => toEntity(maps[index]));

    var ret = List<PlantingPlant>.empty(growable: true);
    final plantDao = PlantsDao();
    for (var p in plantings) {
      final e = await plantDao.queryPlantById(p.plantId);
      if (e != null) {
        ret.add(PlantingPlant(e, p));
      }
    }
    return ret;
  }

  Future<int> insertGardenPlanting(GardenPlanting? gardenPlanting) async {
    if (gardenPlanting == null) return 0;
    final db = await DbManager.currentDb();
    if (null == db) return 0;

    return db.insert(tableName, toMap(gardenPlanting));
  }

  Future<int> deleteGardenPlanting(String plantId) async {
    final db = await DbManager.currentDb();
    if (db == null) return 0;
    return db.delete(
      tableName,
      where: " $_cPlantId = ? ",
      whereArgs: [plantId],
    );
  }
}
