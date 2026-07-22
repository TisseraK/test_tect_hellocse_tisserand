import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

/// État partagé entre l'écran Favoris et le bouton favori de l'écran détail
/// météo : un `Cubit` unique (câblé en singleton), plutôt qu'un `Bloc`
/// événementiel — les seules opérations sont « charger » et « basculer »,
/// pas de flux d'événements à orchestrer.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._favoritesRepository) : super(const FavoritesLoading()) {
    loadFavorites();
  }

  final FavoritesRepository _favoritesRepository;

  Future<void> loadFavorites() async {
    try {
      final favorites = await _favoritesRepository.getFavorites();
      emit(FavoritesLoaded(favorites));
    } on Failure catch (failure) {
      emit(FavoritesError(failure.message));
    }
  }

  Future<void> toggleFavorite(City city) async {
    final current = state;
    if (current is! FavoritesLoaded) return;

    try {
      if (current.contains(city)) {
        await _favoritesRepository.removeFavorite(city);
      } else {
        await _favoritesRepository.addFavorite(city);
      }
      final favorites = await _favoritesRepository.getFavorites();
      emit(FavoritesLoaded(favorites));
    } on Failure catch (failure) {
      emit(FavoritesError(failure.message));
    }
  }
}
