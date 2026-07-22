/// Exceptions levées par la couche data (datasources distantes et locales).
/// Elles restent internes à cette couche : les repositories les catchent et
/// les traduisent en [Failure] pour le reste de l'application.
class ServerException implements Exception {
  const ServerException([this.message = 'Une erreur serveur est survenue.']);

  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Pas de connexion internet.']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = "Erreur d'accès au stockage local."]);

  final String message;
}
