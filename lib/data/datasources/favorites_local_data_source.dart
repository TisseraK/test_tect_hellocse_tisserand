import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../core/error/exceptions.dart';
import '../models/city_model.dart';

/// Source de données locale isolée derrière une interface, comme les
/// datasources distantes : peut être remplacée par un double dans les tests.
abstract class FavoritesLocalDataSource {
  List<CityModel> getFavorites();
  bool isFavorite(int cityId);
  Future<void> addFavorite(CityModel city);
  Future<void> removeFavorite(int cityId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  const FavoritesLocalDataSourceImpl(this._box);

  final Box<Map> _box;

  @override
  List<CityModel> getFavorites() {
    try {
      return _box.values
          .map((raw) => CityModel.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  bool isFavorite(int cityId) => _box.containsKey(cityId);

  @override
  Future<void> addFavorite(CityModel city) async {
    try {
      await _box.put(city.id, city.toJson());
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> removeFavorite(int cityId) async {
    try {
      await _box.delete(cityId);
    } catch (_) {
      throw const CacheException();
    }
  }
}
