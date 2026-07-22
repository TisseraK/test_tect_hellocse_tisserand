import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_tect_hellocse_tisserand/core/error/exceptions.dart';
import 'package:test_tect_hellocse_tisserand/core/error/failures.dart';
import 'package:test_tect_hellocse_tisserand/data/datasources/city_remote_data_source.dart';
import 'package:test_tect_hellocse_tisserand/data/models/city_model.dart';
import 'package:test_tect_hellocse_tisserand/data/repositories/city_repository_impl.dart';

class _MockCityRemoteDataSource extends Mock implements CityRemoteDataSource {}

void main() {
  late _MockCityRemoteDataSource remoteDataSource;
  late CityRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _MockCityRemoteDataSource();
    repository = CityRepositoryImpl(remoteDataSource);
  });

  const cityModel = CityModel(
    id: 2988507,
    name: 'Paris',
    country: 'France',
    admin1: 'Île-de-France',
    latitude: 48.85341,
    longitude: 2.3488,
  );

  test('convertit les CityModel de la datasource en entités City', () async {
    when(
      () => remoteDataSource.searchCities('Paris'),
    ).thenAnswer((_) async => [cityModel]);

    final result = await repository.searchCities('Paris');

    expect(result, [cityModel.toEntity()]);
  });

  test('traduit ServerException en ServerFailure', () async {
    when(
      () => remoteDataSource.searchCities(any()),
    ).thenThrow(const ServerException('boom'));

    expect(
      () => repository.searchCities('Paris'),
      throwsA(isA<ServerFailure>()),
    );
  });

  test('traduit NetworkException en NetworkFailure', () async {
    when(
      () => remoteDataSource.searchCities(any()),
    ).thenThrow(const NetworkException());

    expect(
      () => repository.searchCities('Paris'),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
