import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/repositories/recent_searches_repository.dart';
import 'recent_searches_state.dart';

class RecentSearchesCubit extends Cubit<RecentSearchesState> {
  RecentSearchesCubit(this._repository) : super(const RecentSearchesLoading()) {
    _load();
  }

  final RecentSearchesRepository _repository;

  Future<void> _load() async {
    try {
      final cities = await _repository.getRecentSearches();
      emit(RecentSearchesLoaded(cities));
    } on Failure catch (failure) {
      emit(RecentSearchesError(failure.message));
    }
  }

  Future<void> addRecentSearch(City city) async {
    try {
      await _repository.addRecentSearch(city);
      final cities = await _repository.getRecentSearches();
      emit(RecentSearchesLoaded(cities));
    } on Failure catch (failure) {
      emit(RecentSearchesError(failure.message));
    }
  }
}
