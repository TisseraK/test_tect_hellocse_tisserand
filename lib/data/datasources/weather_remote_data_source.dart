import '../../core/env/env.dart';
import '../../core/network/api_client.dart';
import '../models/daily_forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<List<DailyForecastModel>> getForecast({
    required double latitude,
    required double longitude,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  const WeatherRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<DailyForecastModel>> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('${Env.forecastApiBaseUrl}/forecast').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'daily':
            'weathercode,temperature_2m_max,temperature_2m_min,'
            'precipitation_probability_max,windspeed_10m_max',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );
    final json = await _apiClient.get(uri) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    return DailyForecastModel.listFromDailyJson(daily);
  }
}
