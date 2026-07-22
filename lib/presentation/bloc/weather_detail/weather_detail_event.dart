import 'package:equatable/equatable.dart';

import '../../../domain/entities/city.dart';

sealed class WeatherDetailEvent extends Equatable {
  const WeatherDetailEvent();

  @override
  List<Object?> get props => [];
}

class WeatherDetailStarted extends WeatherDetailEvent {
  const WeatherDetailStarted(this.city);

  final City city;

  @override
  List<Object?> get props => [city];
}
