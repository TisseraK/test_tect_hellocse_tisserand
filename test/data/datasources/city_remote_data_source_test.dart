import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test_tect_hellocse_tisserand/core/error/exceptions.dart';
import 'package:test_tect_hellocse_tisserand/core/network/api_client.dart';
import 'package:test_tect_hellocse_tisserand/data/datasources/city_remote_data_source.dart';

void main() {
  setUp(() {
    dotenv.testLoad(
      fileInput:
          'GEOCODING_API_BASE_URL=https://geocoding-api.open-meteo.com/v1\n'
          'FORECAST_API_BASE_URL=https://api.open-meteo.com/v1',
    );
  });

  CityRemoteDataSourceImpl buildDataSource(http.Client client) {
    return CityRemoteDataSourceImpl(ApiClient(client: client));
  }

  test(
    'retourne les villes parsées quand l\'API répond avec des résultats',
    () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.queryParameters['name'], 'Paris');
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 2988507,
                'name': 'Paris',
                'country': 'France',
                'admin1': 'Île-de-France',
                'latitude': 48.85341,
                'longitude': 2.3488,
              },
            ],
          }),
          200,
        );
      });

      final result = await buildDataSource(client).searchCities('Paris');

      expect(result, hasLength(1));
      expect(result.single.id, 2988507);
      expect(result.single.name, 'Paris');
      expect(result.single.admin1, 'Île-de-France');
    },
  );

  test(
    'retourne une liste vide quand l\'API ne renvoie pas de clé "results"',
    () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'generationtime_ms': 0.1}), 200);
      });

      final result = await buildDataSource(
        client,
      ).searchCities('zzzzznotacity');

      expect(result, isEmpty);
    },
  );

  test('lève ServerException sur une réponse HTTP en erreur', () async {
    final client = MockClient((request) async {
      return http.Response('Internal error', 500);
    });

    expect(
      () => buildDataSource(client).searchCities('Paris'),
      throwsA(isA<ServerException>()),
    );
  });

  test('lève NetworkException quand la connexion échoue', () async {
    final client = MockClient((request) async {
      throw const SocketException('Pas de réseau');
    });

    expect(
      () => buildDataSource(client).searchCities('Paris'),
      throwsA(isA<NetworkException>()),
    );
  });
}
