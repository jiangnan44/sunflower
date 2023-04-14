import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/theme.dart';
import '../../models/planting_plants.dart';
import '../../models/plants_model.dart';
import 'plant_common_views.dart';

class MyGardenListView extends StatelessWidget {
  const MyGardenListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantModel>(builder: (context, model, child) {
      final plantingPlants = model.plantingPlants;
      if (plantingPlants.isEmpty) {
        return _EmptyGardenView();
      }
      return _GardenPlantingListView(plantingPlants);
    });
  }
}

class _GardenPlantingListView extends StatelessWidget {
  final List<PlantingPlants> _plants;

  const _GardenPlantingListView(this._plants);

  @override
  Widget build(BuildContext context) {
    // final double itemWidth = ((MediaQuery.of(context).size.width - 30) / 2);
    return GridView.builder(
      itemCount: _plants.length,
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 8.0 / 13.0),
      itemBuilder: (context, index) {
        final pp = _plants[index];
        return _PlantingItemView(pp);
      },
    );
  }
}

class _PlantingItemView extends StatelessWidget {
  final PlantingPlants _plant;

  const _PlantingItemView(this._plant);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subTitleStyle = theme.textTheme.bodyMedium!.copyWith(
      color: SColors.green700,
      fontWeight: FontWeight.w500,
    );
    final contentStyle = theme.textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w500,
    );

    return GestureDetector(
      onTap: () {
        context.go(Uri(path: '/plant.list/${_plant.plant.plantId}').toString());
      },
      child: Card(
        shape: plantBorder(),
        elevation: 2.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            plantImage(_plant.plant.imageUrl),
            const SizedBox(height: 14.0),
            Text(
              _plant.plant.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 18.0),
            Text(
              'Planted',
              style: subTitleStyle,
            ),
            const SizedBox(height: 5.0),
            Text(
              _plant.gardenPlanting.plantDateTime(),
              style: contentStyle,
            ),
            const SizedBox(height: 15.0),
            Text(
              'Last Watered',
              style: subTitleStyle,
            ),
            const SizedBox(height: 5.0),
            Text(
              _plant.gardenPlanting.lastWateringDateTime(),
              style: contentStyle,
            ),
            const SizedBox(height: 3.0),
            Text(
              _plant.plant.waterInString(),
              style: contentStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGardenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your garden is empty',
            style: Theme.of(context).textTheme.headlineSmall!,
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('add plant')),
              );
            },
            style: TextButton.styleFrom(
                shape: plantBorder(),
                backgroundColor: SColors.white,
                elevation: 2.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0)),
            child: const Text('Add plant'),
          )
        ],
      ),
    );
  }
}
