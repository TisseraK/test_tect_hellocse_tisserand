import 'package:equatable/equatable.dart';

sealed class CitySearchEvent extends Equatable {
  const CitySearchEvent();

  @override
  List<Object?> get props => [];
}

class CitySearchQueryChanged extends CitySearchEvent {
  const CitySearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
