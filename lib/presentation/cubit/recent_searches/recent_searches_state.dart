import 'package:equatable/equatable.dart';

import '../../../domain/entities/city.dart';

sealed class RecentSearchesState extends Equatable {
  const RecentSearchesState();

  @override
  List<Object?> get props => [];
}

class RecentSearchesLoading extends RecentSearchesState {
  const RecentSearchesLoading();
}

class RecentSearchesLoaded extends RecentSearchesState {
  const RecentSearchesLoaded(this.cities);

  final List<City> cities;

  @override
  List<Object?> get props => [cities];
}

class RecentSearchesError extends RecentSearchesState {
  const RecentSearchesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
