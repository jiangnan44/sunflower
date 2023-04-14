
import '../models/plant.dart';
import 'db_base_dao.dart';
import 'db_manager.dart';

class PlantsDao extends BaseDbDao {
  static const String tableName = "plants";
  final String _cId = "_id";
  final String _cName = "name";
  final String _cDescription = "description";
  final String _cGrowZoneNumber = "growZoneNumber";
  final String _cWateringInterval = "wateringInterval";
  final String _cImageUrl = "imageUrl";

  @override
  String createColumns() {
    return '''
    $_cId TEXT PRIMARY KEY NOT NULL,
    $_cName TEXT NOT NULL,
    $_cDescription TEXT,
    $_cGrowZoneNumber INT,
    $_cWateringInterval INTEGER,
    $_cImageUrl TEXT
   ''';
  }

  @override
  String innerTableName() {
    return tableName;
  }

  Map<String, dynamic> toMap(Plant p) {
    return {
      _cId: p.plantId,
      _cName: p.name,
      _cDescription: p.description,
      _cGrowZoneNumber: p.growZoneNumber,
      _cWateringInterval: p.wateringInterval,
      _cImageUrl: p.imageUrl,
    };
  }

  Plant toEntity(Map<String, dynamic> map) {
    return Plant(
      map[_cId],
      map[_cName],
      description: map[_cDescription],
      growZoneNumber: map[_cWateringInterval],
      wateringInterval: map[_cWateringInterval],
      imageUrl: map[_cImageUrl],
    );
  }

  Future<int> insert(List<Plant>? plants) async {
    if (plants == null || plants.isEmpty) return 0;
    final db = await DbManager.currentDb();
    if (db == null) return 0;
    var batch = db.batch();
    for (var p in plants) {
      batch.insert(tableName, toMap(p));
    }

    return (await batch.commit()).length;
  }

  Future<int> insertSingle(Plant? plant) async {
    if (plant == null) return 0;
    final db = await DbManager.currentDb();
    if (db == null) return 0;

    return db.insert(tableName, toMap(plant));
  }

  Future<bool> hasPlants() async {
    final db = await DbManager.currentDb();
    if (db == null) return false;

    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return maps.isNotEmpty;
  }

  Future<List<Plant>?> queryPlants() async {
    final db = await DbManager.currentDb();
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(tableName);

    if (maps.isEmpty) return null;

    return List.generate(
      maps.length,
      (index) => toEntity(maps[index]),
    );
  }

  Future<Plant?> queryPlantById(String plantId) async {
    final db = await DbManager.currentDb();
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$_cId = ? ',
      whereArgs: [plantId],
    );
    if (maps.isEmpty) return null;
    return toEntity(maps[0]);
  }

  Future<List<Plant>?> queryPlantWithGrowZoneNumber(int growZoneNumber) async {
    final db = await DbManager.currentDb();
    if (null == db) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: ' $_cGrowZoneNumber = ? ',
      whereArgs: [growZoneNumber],
    );

    if (maps.isEmpty) return null;
    return List.generate(maps.length, (index) => toEntity(maps[index]));
  }
}
