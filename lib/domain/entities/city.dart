import 'package:equatable/equatable.dart';

class City extends Equatable {
  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  final String name;
  final String country;

  /// Région/état, quand l'API en fournit une.
  final String? admin1;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [name, country, admin1, latitude, longitude];
}
