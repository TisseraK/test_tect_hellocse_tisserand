import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get geocodingApiBaseUrl => _require('GEOCODING_API_BASE_URL');

  static String get forecastApiBaseUrl => _require('FORECAST_API_BASE_URL');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Variable d\'environnement manquante: $key');
    }
    return value;
  }
}
