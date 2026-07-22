import '../../core/env/env.dart';
import '../../core/network/api_client.dart';
import '../models/city_model.dart';

/// Source de données isolée derrière une interface : peut être remplacée par
/// un double dans les tests sans dépendre d'un appel réseau réel.
abstract class CityRemoteDataSource {
  Future<List<CityModel>> searchCities(String query);
}

class CityRemoteDataSourceImpl implements CityRemoteDataSource {
  const CityRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CityModel>> searchCities(String query) async {
    final uri = Uri.parse('${Env.geocodingApiBaseUrl}/search').replace(
      queryParameters: {
        'name': query,
        'count': '10',
        'language': 'fr',
        'format': 'json',
      },
    );
    final json = await _apiClient.get(uri) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;
    if (results == null) {
      return const [];
    }
    return results
        .map((result) => CityModel.fromJson(result as Map<String, dynamic>))
        .toList();
  }
}
