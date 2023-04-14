import 'dart:developer';
import 'package:flutter/material.dart';

import '../../common/theme.dart';
import 'my_garden_screen.dart';
import 'plant_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.primaryContainer;

    return Scaffold(
      backgroundColor: bgColor,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) => [
            _buildSliverAppBar(),
          ],
          body: const TabBarView(children: [
            MyGardenListView(),
            PlantsListView(),
          ]),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return const SliverAppBar(
      title: Center(child: Text('Sunflower')),
      floating: true,
      expandedHeight: 120.0,
      pinned: true,
      snap: true,
      bottom: TabBar(
        tabs: [
          Tab(
            icon: Icon(Icons.sunny),
            text: 'My garden',
          ),
          Tab(
            icon: Icon(Icons.energy_savings_leaf),
            text: 'Plant list',
          ),
        ],
        labelColor: SColors.yellow500,
      ),
    );
  }
}
