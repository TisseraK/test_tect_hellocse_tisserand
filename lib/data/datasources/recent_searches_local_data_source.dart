import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../core/error/exceptions.dart';
import '../models/city_model.dart';

/// Source de données locale isolée derrière une interface, comme
/// `FavoritesLocalDataSource`. Stockée comme une seule liste ordonnée (la
/// plus récente en tête) plutôt qu'une entrée par ville, car l'ordre et le
/// plafond de taille sont les points importants ici, pas l'accès par clé.
abstract class RecentSearchesLocalDataSource {
  List<CityModel> getRecentSearches();
  Future<void> addRecentSearch(CityModel city);
}

class RecentSearchesLocalDataSourceImpl
    implements RecentSearchesLocalDataSource {
  const RecentSearchesLocalDataSourceImpl(this._box, {this.maxEntries = 8});

  final Box<List> _box;
  final int maxEntries;

  static const _key = 'recent';

  @override
  List<CityModel> getRecentSearches() {
    try {
      final raw = _box.get(_key) ?? const [];
      return raw
          .map(
            (entry) =>
                CityModel.fromJson(Map<String, dynamic>.from(entry as Map)),
          )
          .toList();
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> addRecentSearch(CityModel city) async {
    try {
      final withoutDuplicate = getRecentSearches().where(
        (c) => c.id != city.id,
      );
      final updated = [city, ...withoutDuplicate].take(maxEntries).toList();
      await _box.put(_key, updated.map((c) => c.toJson()).toList());
    } catch (_) {
      throw const CacheException();
    }
  }
}
