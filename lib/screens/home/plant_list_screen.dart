import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/plant.dart';
import '../../models/plants_model.dart';
import 'plant_common_views.dart';

typedef PlantClickCallback = void Function(Plant plant);

class PlantsListView extends StatelessWidget {
  const PlantsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantModel>(builder: (context, model, child) {
      final plants = model.plants;
      if (plants.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return _PlantListView(
        plants: plants,
        clickCallback: (plant) {
          context.go(Uri(path: '/plant.list/${plant.plantId}').toString());
        },
      );
    });
  }
}

class _PlantListView extends StatelessWidget {
  final List<Plant> plants;
  final PlantClickCallback clickCallback;

  const _PlantListView({
    required this.plants,
    required this.clickCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: plants.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 10.0 / 9.0,
      ),
      itemBuilder: (context, index) {
        return _buildPlantItemView(context, plants[index]);
      },
    );
  }

  Widget _buildPlantItemView(BuildContext context, Plant plant) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        clickCallback(plant);
      },
      child: Card(
        shape: plantBorder(),
        elevation: 2.0,
        child: Column(
          children: [
            plantImage(plant.imageUrl),
            Expanded(
              child: Center(
                child: Text(
                  plant.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
