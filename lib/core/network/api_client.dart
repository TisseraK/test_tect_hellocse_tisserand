import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../error/exceptions.dart';

/// Point d'entrée réseau unique de l'application. Les datasources distantes
/// dépendent de cette abstraction plutôt que directement de `http.Client`,
/// afin de pouvoir être testées avec un double (voir mocktail) sans appel
/// réseau réel.
class ApiClient {
  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 10)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<dynamic> get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      throw ServerException('Erreur serveur (${response.statusCode}).');
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('Le serveur met trop de temps à répondre.');
    } on FormatException {
      throw const ServerException('Réponse serveur invalide.');
    }
  }

  void dispose() => _client.close();
}
