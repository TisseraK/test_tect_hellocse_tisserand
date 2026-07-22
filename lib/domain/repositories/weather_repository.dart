import '../entities/city.dart';
import '../entities/daily_forecast.dart';

abstract class WeatherRepository {
  /// Prévisions des 7 prochains jours pour la ville donnée.
  Future<List<DailyForecast>> getForecast(City city);
}
