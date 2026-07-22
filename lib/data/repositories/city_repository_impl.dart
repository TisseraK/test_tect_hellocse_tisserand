import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';
import '../datasources/city_remote_data_source.dart';

class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl(this._remoteDataSource);

  final CityRemoteDataSource _remoteDataSource;

  @override
  Future<List<City>> searchCities(String query) async {
    try {
      final models = await _remoteDataSource.searchCities(query);
      return models.map((model) => model.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
