import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:test_tect_hellocse_tisserand/data/datasources/recent_searches_local_data_source.dart';
import 'package:test_tect_hellocse_tisserand/data/models/city_model.dart';

const _boxName = 'recent_searches_box';

CityModel _city(int id, String name) =>
    CityModel(id: id, name: name, country: 'France', latitude: 0, longitude: 0);

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_recent_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('la plus récente vient en tête', () async {
    final box = await Hive.openBox<List>(_boxName);
    final dataSource = RecentSearchesLocalDataSourceImpl(box);

    await dataSource.addRecentSearch(_city(1, 'Paris'));
    await dataSource.addRecentSearch(_city(2, 'Lyon'));

    final result = dataSource.getRecentSearches();
    expect(result.map((c) => c.name), ['Lyon', 'Paris']);
  });

  test(
    'une ville déjà présente est déplacée en tête plutôt que dupliquée',
    () async {
      final box = await Hive.openBox<List>(_boxName);
      final dataSource = RecentSearchesLocalDataSourceImpl(box);

      await dataSource.addRecentSearch(_city(1, 'Paris'));
      await dataSource.addRecentSearch(_city(2, 'Lyon'));
      await dataSource.addRecentSearch(_city(1, 'Paris'));

      final result = dataSource.getRecentSearches();
      expect(result.map((c) => c.name), ['Paris', 'Lyon']);
    },
  );

  test('la liste est plafonnée à maxEntries', () async {
    final box = await Hive.openBox<List>(_boxName);
    final dataSource = RecentSearchesLocalDataSourceImpl(box, maxEntries: 3);

    for (var i = 1; i <= 5; i++) {
      await dataSource.addRecentSearch(_city(i, 'Ville $i'));
    }

    final result = dataSource.getRecentSearches();
    expect(result, hasLength(3));
    expect(result.map((c) => c.name), ['Ville 5', 'Ville 4', 'Ville 3']);
  });

  test('survit à la fermeture et réouverture de Hive (redémarrage)', () async {
    final firstSessionBox = await Hive.openBox<List>(_boxName);
    await RecentSearchesLocalDataSourceImpl(
      firstSessionBox,
    ).addRecentSearch(_city(1, 'Paris'));
    await Hive.close();

    Hive.init(tempDir.path);
    final secondSessionBox = await Hive.openBox<List>(_boxName);
    final result = RecentSearchesLocalDataSourceImpl(
      secondSessionBox,
    ).getRecentSearches();

    expect(result, hasLength(1));
    expect(result.single.name, 'Paris');
  });
}
