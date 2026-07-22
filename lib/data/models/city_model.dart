import '../../domain/entities/city.dart';

/// DTO reflétant la forme d'un résultat de
/// https://geocoding-api.open-meteo.com/v1/search. Sert aussi de format de
/// sérialisation pour la persistance locale des favoris (mêmes clés).
class CityModel {
  const CityModel({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  factory CityModel.fromEntity(City city) {
    return CityModel(
      id: city.id,
      name: city.name,
      country: city.country,
      admin1: city.admin1,
      latitude: city.latitude,
      longitude: city.longitude,
    );
  }

  final int id;
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  City toEntity() {
    return City(
      id: id,
      name: name,
      country: country,
      admin1: admin1,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
