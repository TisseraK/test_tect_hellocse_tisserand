import '../entities/city.dart';

abstract class RecentSearchesRepository {
  Future<List<City>> getRecentSearches();
  Future<void> addRecentSearch(City city);
}
