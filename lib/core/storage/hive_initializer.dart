import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_box_names.dart';

/// Initialise Hive et ouvre les boxes utilisées par l'application. Les
/// entrées sont stockées en `Map<String, dynamic>` brut (villes favorites) :
/// petite structure simple, pas besoin de TypeAdapters générés ici.
class HiveInitializer {
  HiveInitializer._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(HiveBoxNames.favorites);
  }
}
