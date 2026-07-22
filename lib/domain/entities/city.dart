import 'package:equatable/equatable.dart';

class City extends Equatable {
  const City({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  /// Identifiant Open-Meteo de la localisation (`results[].id` de l'API
  /// geocoding). Stable d'un appel à l'autre, utilisé comme clé pour les
  /// favoris plutôt que les coordonnées (précision flottante).
  final int id;
  final String name;
  final String country;

  /// Région/état, quand l'API en fournit une.
  final String? admin1;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [id, name, country, admin1, latitude, longitude];
}
