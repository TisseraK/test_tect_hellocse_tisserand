import 'package:equatable/equatable.dart';

import '../../../domain/entities/activity.dart';
import '../../../domain/entities/city.dart';

sealed class WeatherDetailEvent extends Equatable {
  const WeatherDetailEvent();

  @override
  List<Object?> get props => [];
}

class WeatherDetailStarted extends WeatherDetailEvent {
  const WeatherDetailStarted(this.city, this.activity);

  final City city;
  final Activity activity;

  @override
  List<Object?> get props => [city, activity];
}

class WeatherDetailActivityChanged extends WeatherDetailEvent {
  const WeatherDetailActivityChanged(this.activity);

  final Activity activity;

  @override
  List<Object?> get props => [activity];
}
