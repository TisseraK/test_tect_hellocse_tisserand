import 'package:equatable/equatable.dart';

import '../../../domain/entities/activity.dart';
import '../../../domain/entities/daily_forecast.dart';
import '../../../domain/entities/recommendation_level.dart';

sealed class WeatherDetailState extends Equatable {
  const WeatherDetailState();

  @override
  List<Object?> get props => [];
}

class WeatherDetailLoading extends WeatherDetailState {
  const WeatherDetailLoading();
}

class WeatherDetailLoaded extends WeatherDetailState {
  const WeatherDetailLoaded({
    required this.forecasts,
    required this.selectedActivity,
    required this.recommendations,
  });

  final List<DailyForecast> forecasts;
  final Activity? selectedActivity;

  /// Recommandation du jour à l'index correspondant de [forecasts], pour
  /// [selectedActivity]. `null` si aucune activité n'est sélectionnée : dans
  /// ce cas l'UI n'affiche aucun badge de recommandation. Calculée par le
  /// BLoC via le use case du domaine — les widgets n'appellent jamais
  /// `RecommendActivity` eux-mêmes.
  final List<RecommendationLevel>? recommendations;

  @override
  List<Object?> get props => [forecasts, selectedActivity, recommendations];
}

class WeatherDetailError extends WeatherDetailState {
  const WeatherDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
