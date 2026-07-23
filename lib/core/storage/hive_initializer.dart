import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../constants/hive_box_names.dart';

/// Initialise Hive et ouvre les boxes utilisées par l'application. Les
/// entrées sont stockées en structures brutes (`Map`/`List`), pas besoin de
/// TypeAdapters générés pour ce périmètre.
class HiveInitializer {
  HiveInitializer._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(HiveBoxNames.favorites);
    await Hive.openBox<List>(HiveBoxNames.recentSearches);
  }
}
