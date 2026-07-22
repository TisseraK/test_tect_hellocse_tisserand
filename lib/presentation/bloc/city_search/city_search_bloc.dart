import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/repositories/city_repository.dart';
import 'city_search_event.dart';
import 'city_search_state.dart';

/// `restartable()` : si une nouvelle recherche est déclenchée pendant qu'une
/// précédente est encore en cours, celle-ci est abandonnée au profit de la
/// plus récente — évite qu'une réponse réseau en retard n'écrase un résultat
/// plus récent (recherche tapée rapidement).
class CitySearchBloc extends Bloc<CitySearchEvent, CitySearchState> {
  CitySearchBloc(this._cityRepository) : super(const CitySearchInitial()) {
    on<CitySearchQueryChanged>(_onQueryChanged, transformer: restartable());
  }

  final CityRepository _cityRepository;

  Future<void> _onQueryChanged(
    CitySearchQueryChanged event,
    Emitter<CitySearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const CitySearchInitial());
      return;
    }

    emit(const CitySearchLoading());
    try {
      final cities = await _cityRepository.searchCities(query);
      emit(cities.isEmpty ? CitySearchEmpty(query) : CitySearchLoaded(cities));
    } on Failure catch (failure) {
      emit(CitySearchError(failure.message));
    }
  }
}
