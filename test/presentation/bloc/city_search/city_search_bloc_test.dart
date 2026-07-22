import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_tect_hellocse_tisserand/core/error/failures.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/city.dart';
import 'package:test_tect_hellocse_tisserand/domain/repositories/city_repository.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/city_search/city_search_bloc.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/city_search/city_search_event.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/city_search/city_search_state.dart';

class _MockCityRepository extends Mock implements CityRepository {}

void main() {
  late _MockCityRepository repository;

  const paris = City(
    id: 2988507,
    name: 'Paris',
    country: 'France',
    admin1: 'Île-de-France',
    latitude: 48.85341,
    longitude: 2.3488,
  );

  setUp(() {
    repository = _MockCityRepository();
  });

  blocTest<CitySearchBloc, CitySearchState>(
    'émet [Loading, Loaded] quand la recherche renvoie des résultats',
    setUp: () => when(
      () => repository.searchCities('Paris'),
    ).thenAnswer((_) async => [paris]),
    build: () => CitySearchBloc(repository),
    act: (bloc) => bloc.add(const CitySearchQueryChanged('Paris')),
    expect: () => [
      const CitySearchLoading(),
      const CitySearchLoaded([paris]),
    ],
  );

  blocTest<CitySearchBloc, CitySearchState>(
    'émet [Loading, Empty] quand la recherche ne renvoie rien',
    setUp: () => when(
      () => repository.searchCities('zzzzznotacity'),
    ).thenAnswer((_) async => []),
    build: () => CitySearchBloc(repository),
    act: (bloc) => bloc.add(const CitySearchQueryChanged('zzzzznotacity')),
    expect: () => [
      const CitySearchLoading(),
      const CitySearchEmpty('zzzzznotacity'),
    ],
  );

  blocTest<CitySearchBloc, CitySearchState>(
    'émet [Loading, Error] quand le repository lève une Failure',
    setUp: () => when(
      () => repository.searchCities('Paris'),
    ).thenThrow(const NetworkFailure('Pas de connexion internet.')),
    build: () => CitySearchBloc(repository),
    act: (bloc) => bloc.add(const CitySearchQueryChanged('Paris')),
    expect: () => [
      const CitySearchLoading(),
      const CitySearchError('Pas de connexion internet.'),
    ],
  );

  blocTest<CitySearchBloc, CitySearchState>(
    'une requête vide revient à Initial sans appeler le repository',
    build: () => CitySearchBloc(repository),
    seed: () => const CitySearchLoaded([paris]),
    act: (bloc) => bloc.add(const CitySearchQueryChanged('   ')),
    expect: () => [const CitySearchInitial()],
    verify: (_) => verifyNever(() => repository.searchCities(any())),
  );
}
