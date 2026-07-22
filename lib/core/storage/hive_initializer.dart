import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_box_names.dart';

/* Initialise Hive et ouvre les boxes utilisées par l'application. Les
 entrées sont stockées en `Map<String, dynamic>` bruts (villes favorites,
 prévisions en cache) : ce sont de petites structures simples, pas besoin
 de TypeAdapters générés pour ce périmètre.*/
class HiveInitializer {
  HiveInitializer._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(HiveBoxNames.favorites);
    await Hive.openBox<Map>(HiveBoxNames.forecastCache);
  }
}
