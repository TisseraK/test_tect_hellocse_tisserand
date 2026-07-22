import '../../domain/entities/city.dart';

/// DTO reflétant la forme d'un résultat de
/// https://geocoding-api.open-meteo.com/v1/search.
class CityModel {
  const CityModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  City toEntity() {
    return City(
      name: name,
      country: country,
      admin1: admin1,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
