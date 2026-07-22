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

  Future<void> _onStarted(
    WeatherDetailStarted event,
    Emitter<WeatherDetailState> emit,
  ) async {
    emit(const WeatherDetailLoading());
    try {
      final forecasts = await _weatherRepository.getForecast(event.city);
      emit(_loadedState(forecasts, event.activity));
    } on Failure catch (failure) {
      emit(WeatherDetailError(failure.message));
    }
  }

  void _onActivityChanged(
    WeatherDetailActivityChanged event,
    Emitter<WeatherDetailState> emit,
  ) {
    final current = state;
    if (current is WeatherDetailLoaded) {
      emit(_loadedState(current.forecasts, event.activity));
    }
  }

  WeatherDetailLoaded _loadedState(
    List<DailyForecast> forecasts,
    Activity activity,
  ) {
    return WeatherDetailLoaded(
      forecasts: forecasts,
      selectedActivity: activity,
      recommendations: [
        for (final forecast in forecasts)
          _recommendActivity(forecast, activity),
      ],
    );
  }
}
