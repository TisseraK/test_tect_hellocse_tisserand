import 'package:equatable/equatable.dart';

import '../../../domain/entities/city.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.favorites);

  final List<City> favorites;

  bool contains(City city) => favorites.any((c) => c.id == city.id);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  const FavoritesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
