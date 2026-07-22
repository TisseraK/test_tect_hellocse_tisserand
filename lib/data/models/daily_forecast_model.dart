import '../../domain/entities/daily_forecast.dart';

/// DTO reflétant un jour de la réponse `daily` de
/// https://api.open-meteo.com/v1/forecast (format en colonnes parallèles).
class DailyForecastModel {
  const DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.precipitationProbability,
    required this.windSpeedMax,
  });

  /// Convertit le bloc `daily` (colonnes parallèles indexées par jour) en
  /// une liste d'un modèle par jour.
  static List<DailyForecastModel> listFromDailyJson(
    Map<String, dynamic> daily,
  ) {
    final dates = daily['time'] as List<dynamic>;
    final weatherCodes = daily['weathercode'] as List<dynamic>;
    final temperaturesMax = daily['temperature_2m_max'] as List<dynamic>;
    final temperaturesMin = daily['temperature_2m_min'] as List<dynamic>;
    final precipitations =
        daily['precipitation_probability_max'] as List<dynamic>;
    final windSpeeds = daily['windspeed_10m_max'] as List<dynamic>;

    return List.generate(dates.length, (i) {
      return DailyForecastModel(
        date: DateTime.parse(dates[i] as String),
        weatherCode: (weatherCodes[i] as num).toInt(),
        temperatureMin: (temperaturesMin[i] as num).toDouble(),
        temperatureMax: (temperaturesMax[i] as num).toDouble(),
        precipitationProbability: (precipitations[i] as num).toInt(),
        windSpeedMax: (windSpeeds[i] as num).toDouble(),
      );
    });
  }

  final DateTime date;
  final int weatherCode;
  final double temperatureMin;
  final double temperatureMax;
  final int precipitationProbability;
  final double windSpeedMax;

  DailyForecast toEntity() {
    return DailyForecast(
      date: date,
      weatherCode: weatherCode,
      temperatureMin: temperatureMin,
      temperatureMax: temperatureMax,
      precipitationProbability: precipitationProbability,
      windSpeedMax: windSpeedMax,
    );
  }
}
