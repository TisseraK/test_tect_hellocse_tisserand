import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/activity.dart';
import '../../../domain/entities/daily_forecast.dart';
import '../../../domain/repositories/weather_repository.dart';
import '../../../domain/usecases/recommend_activity.dart';
import 'weather_detail_event.dart';
import 'weather_detail_state.dart';

class WeatherDetailBloc extends Bloc<WeatherDetailEvent, WeatherDetailState> {
  WeatherDetailBloc(this._weatherRepository, this._recommendActivity)
    : super(const WeatherDetailLoading()) {
    on<WeatherDetailStarted>(_onStarted);
    on<WeatherDetailActivityChanged>(_onActivityChanged);
  }

  final WeatherRepository _weatherRepository;
  final RecommendActivity _recommendActivity;

  /// Activité la plus récente demandée par l'utilisateur. Suivie ici plutôt
  /// que lue depuis l'event de `WeatherDetailStarted` au moment de l'émission
  /// finale : si l'utilisateur change d'activité pendant que le chargement
  /// initial est encore en cours, ce champ capture ce choix pour que le
  /// résultat final reflète la dernière sélection, pas celle figée au moment
  /// du lancement de la requête.
  Activity? _selectedActivity;

  Future<void> _onStarted(
    WeatherDetailStarted event,
    Emitter<WeatherDetailState> emit,
  ) async {
    _selectedActivity = event.activity;
    emit(const WeatherDetailLoading());
    try {
      final forecasts = await _weatherRepository.getForecast(event.city);
      emit(_loadedState(forecasts, _selectedActivity));
    } on Failure catch (failure) {
      emit(WeatherDetailError(failure.message));
    }
  }

  void _onActivityChanged(
    WeatherDetailActivityChanged event,
    Emitter<WeatherDetailState> emit,
  ) {
    _selectedActivity = event.activity;
    final current = state;
    if (current is WeatherDetailLoaded) {
      emit(_loadedState(current.forecasts, _selectedActivity));
    }
  }

  WeatherDetailLoaded _loadedState(
    List<DailyForecast> forecasts,
    Activity? activity,
  ) {
    return WeatherDetailLoaded(
      forecasts: forecasts,
      selectedActivity: activity,
      recommendations: activity == null
          ? null
          : [
              for (final forecast in forecasts)
                _recommendActivity(forecast, activity),
            ],
    );
  }
}
