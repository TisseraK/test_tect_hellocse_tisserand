import '../entities/city.dart';

abstract class CityRepository {
  Future<List<City>> searchCities(String query);
}
