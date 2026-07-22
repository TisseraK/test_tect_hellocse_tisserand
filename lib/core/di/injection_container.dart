import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_box_names.dart';
import '../network/api_client.dart';

/// Service locator unique de l'application. Câblé au démarrage (voir
/// `main.dart`), une fois que l'environnement et Hive sont initialisés.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<Box<Map>>(
    () => Hive.box<Map>(HiveBoxNames.favorites),
    instanceName: HiveBoxNames.favorites,
  );
  sl.registerLazySingleton<Box<Map>>(
    () => Hive.box<Map>(HiveBoxNames.forecastCache),
    instanceName: HiveBoxNames.forecastCache,
  );

  // Data sources, repositories, use cases et BLoC seront enregistrés ici au
  // fur et à mesure de l'implémentation de chaque couche.
}
