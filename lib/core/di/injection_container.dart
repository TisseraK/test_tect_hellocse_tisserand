import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../data/datasources/city_remote_data_source.dart';
import '../../data/repositories/city_repository_impl.dart';
import '../../domain/repositories/city_repository.dart';
import '../../presentation/bloc/city_search/city_search_bloc.dart';
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

  // Data sources
  sl.registerLazySingleton<CityRemoteDataSource>(
    () => CityRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<CityRepository>(
    () => CityRepositoryImpl(sl<CityRemoteDataSource>()),
  );

  // BLoC — une nouvelle instance à chaque écran (pas de singleton).
  sl.registerFactory<CitySearchBloc>(
    () => CitySearchBloc(sl<CityRepository>()),
  );
}
