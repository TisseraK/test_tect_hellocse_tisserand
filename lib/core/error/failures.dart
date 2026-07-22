/* Erreurs exposées par le domaine et la présentation, traduites par les
 repositories à partir des exceptions de la couche data. L'UI ne connaît
 jamais les exceptions réseau/stockage brutes, seulement ces [Failure].*/
abstract class Failure {
  const Failure(this.message);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Une erreur serveur est survenue.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = "Erreur d'accès au stockage local."]);
}
