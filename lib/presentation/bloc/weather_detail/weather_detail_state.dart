import 'package:equatable/equatable.dart';

import '../../../domain/entities/daily_forecast.dart';

sealed class WeatherDetailState extends Equatable {
  const WeatherDetailState();

  @override
  List<Object?> get props => [];
}

class WeatherDetailLoading extends WeatherDetailState {
  const WeatherDetailLoading();
}

class WeatherDetailLoaded extends WeatherDetailState {
  const WeatherDetailLoaded(this.forecasts);

  final List<DailyForecast> forecasts;

  @override
  List<Object?> get props => [forecasts];
}

class WeatherDetailError extends WeatherDetailState {
  const WeatherDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
