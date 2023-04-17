import 'dart:collection';

import 'package:flutter/material.dart';

import '../db/db_manager.dart';
import '../db/garden_planting_dao.dart';
import '../db/plants_dao.dart';
import '../util/logger.dart';
import 'garden_planting.dart';
import 'plant.dart';
import 'planting_plants.dart';

// todo narrow the scopes who use this Model ,make it efficient
class PlantModel extends ChangeNotifier {
  PlantModel() {
    WidgetsFlutterBinding.ensureInitialized();

    setup() async {
      await DbManager.init();
      await DbManager.check2InsertMockData();
      await _loadPlantingPlants();
      await _loadPlants();
    }

    setup();
  }

  final List<PlantingPlants> _plantingPlants = [];

  List<PlantingPlants> get plantingPlants =>
      UnmodifiableListView(_plantingPlants);

  final List<Plant> _plants = [];

  List<Plant> get plants => UnmodifiableListView(_plants);



  _loadPlants() async {
    final dao = PlantsDao();
    final list = await dao.queryPlants();
    VLog.w('_loadPlants ${list?.length}');
    if (list != null && list.isNotEmpty) {
      _plants.addAll(list);
      notifyListeners();
    }
  }

  _loadPlantingPlants() async {
    final dao = GardenPlantingDao();
    final list = await dao.queryPlantingPlants();
    if (list != null && list.isNotEmpty) {
      _plantingPlants.addAll(list);
      notifyListeners();
    }
  }

  addPlant2Garden(Plant plant) {
    for (var pp in _plantingPlants) {
      if (pp.plant.plantId == plant.plantId) {
        return;
      }
    }
    final t = DateTime.now().millisecondsSinceEpoch;
    final gp = GardenPlanting(
        plantId: plant.plantId, plantTime: t, lastWateringTime: t);

    _plantingPlants.add(PlantingPlants(plant, gp));
    notifyListeners();
    GardenPlantingDao().insertGardenPlanting(gp);
  }

  removePlantFromGarden(String plantId) {
    for (var i = 0; i < _plantingPlants.length; i++) {
      final pp = _plantingPlants[i];
      if (pp.plant.plantId == plantId) {
        _plantingPlants.removeAt(i);
        notifyListeners();
        GardenPlantingDao().deleteGardenPlanting(plantId);
        return;
      }
    }
  }

  bool isPlanted(String plantId) {
    for (final p in _plantingPlants) {
      if (p.plant.plantId == plantId) {
        return true;
      }
    }
    return false;
  }
}
