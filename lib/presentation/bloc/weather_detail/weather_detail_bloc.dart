import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/repositories/weather_repository.dart';
import 'weather_detail_event.dart';
import 'weather_detail_state.dart';

class WeatherDetailBloc extends Bloc<WeatherDetailEvent, WeatherDetailState> {
  WeatherDetailBloc(this._weatherRepository)
    : super(const WeatherDetailLoading()) {
    on<WeatherDetailStarted>(_onStarted);
  }

  final WeatherRepository _weatherRepository;

  Future<void> _onStarted(
    WeatherDetailStarted event,
    Emitter<WeatherDetailState> emit,
  ) async {
    emit(const WeatherDetailLoading());
    try {
      final forecasts = await _weatherRepository.getForecast(event.city);
      emit(WeatherDetailLoaded(forecasts));
    } on Failure catch (failure) {
      emit(WeatherDetailError(failure.message));
    }
  }
}
