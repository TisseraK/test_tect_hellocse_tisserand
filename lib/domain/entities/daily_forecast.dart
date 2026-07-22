import 'package:equatable/equatable.dart';

class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.precipitationProbability,
    required this.windSpeedMax,
  });

  final DateTime date;
  final int
  weatherCode; // Code météo WMO tel que retourné par Open-Meteo (`daily.weathercode`).
  final double temperatureMin;
  final double temperatureMax;
  final int
  precipitationProbability; // Probabilité de précipitation maximale du jour, en pourcentage (0-100).
  final double windSpeedMax; // Vitesse de vent maximale du jour, en km/h.

  @override
  List<Object?> get props => [
    date,
    weatherCode,
    temperatureMin,
    temperatureMax,
    precipitationProbability,
    windSpeedMax,
  ];
}
