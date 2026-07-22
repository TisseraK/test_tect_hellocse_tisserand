import '../entities/city.dart';

abstract class FavoritesRepository {
  Future<List<City>> getFavorites();
  Future<bool> isFavorite(City city);
  Future<void> addFavorite(City city);
  Future<void> removeFavorite(City city);
}
