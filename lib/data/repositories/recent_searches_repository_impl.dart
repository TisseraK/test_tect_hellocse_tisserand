import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/recent_searches_repository.dart';
import '../datasources/recent_searches_local_data_source.dart';
import '../models/city_model.dart';

class RecentSearchesRepositoryImpl implements RecentSearchesRepository {
  const RecentSearchesRepositoryImpl(this._localDataSource);

  final RecentSearchesLocalDataSource _localDataSource;

  @override
  Future<List<City>> getRecentSearches() async {
    try {
      return _localDataSource
          .getRecentSearches()
          .map((model) => model.toEntity())
          .toList();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> addRecentSearch(City city) async {
    try {
      await _localDataSource.addRecentSearch(CityModel.fromEntity(city));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
