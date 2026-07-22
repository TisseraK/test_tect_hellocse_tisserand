import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../models/city_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<List<City>> getFavorites() async {
    try {
      return _localDataSource
          .getFavorites()
          .map((model) => model.toEntity())
          .toList();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<bool> isFavorite(City city) async {
    return _localDataSource.isFavorite(city.id);
  }

  @override
  Future<void> addFavorite(City city) async {
    try {
      await _localDataSource.addFavorite(CityModel.fromEntity(city));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> removeFavorite(City city) async {
    try {
      await _localDataSource.removeFavorite(city.id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
