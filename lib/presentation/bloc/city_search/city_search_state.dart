import 'package:equatable/equatable.dart';

import '../../../domain/entities/city.dart';

sealed class CitySearchState extends Equatable {
  const CitySearchState();

  @override
  List<Object?> get props => [];
}

/// Aucune recherche en cours (champ vide).
class CitySearchInitial extends CitySearchState {
  const CitySearchInitial();
}

class CitySearchLoading extends CitySearchState {
  const CitySearchLoading();
}

class CitySearchLoaded extends CitySearchState {
  const CitySearchLoaded(this.cities);

  final List<City> cities;

  @override
  List<Object?> get props => [cities];
}

class CitySearchEmpty extends CitySearchState {
  const CitySearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class CitySearchError extends CitySearchState {
  const CitySearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
