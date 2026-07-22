import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/daily_forecast.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl(this._remoteDataSource);

  final WeatherRemoteDataSource _remoteDataSource;

  @override
  Future<List<DailyForecast>> getForecast(City city) async {
    try {
      final models = await _remoteDataSource.getForecast(
        latitude: city.latitude,
        longitude: city.longitude,
      );
      return models.map((model) => model.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }
}
