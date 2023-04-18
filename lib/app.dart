import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sunflower/models/gallery_model.dart';
import 'package:sunflower/screens/gallery/gallery_screen.dart';

import 'common/theme.dart';
import 'models/plants_model.dart';
import 'screens/home/home_screen.dart';
import 'screens/plant_detail/plant_detail_screen.dart';
import 'util/snack_bar.dart';

final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'plant.list/:id',
          builder: (context, state) {
            final id = state.params['id']!;
            return PlantDetailScreen(plantId: id);
          },
          routes: [
            GoRoute(
              path: 'gallery/:keyword',
              builder: (context, state) {
                final key = state.params['keyword']!;
                return GalleryScreen(keyWord: key);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class SunflowerApp extends StatelessWidget {
  const SunflowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: SColors.green500,
      onPrimary: SColors.gray50,
      secondary: SColors.yellow500,
      onSecondary: SColors.green900,
      error: SColors.red400,
      onError: SColors.yellow300,
      background: SColors.green500,
      onBackground: SColors.white,
      surface: SColors.gray50,
      onSurface: SColors.green900,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlantModel()),
        ChangeNotifierProvider(create: (context) => GalleryModel()),
      ],
      child: MaterialApp.router(
        theme: ThemeData.from(colorScheme: colorScheme),
        scaffoldMessengerKey: GlobalSnackBar.key,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
