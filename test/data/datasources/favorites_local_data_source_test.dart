import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:test_tect_hellocse_tisserand/data/datasources/favorites_local_data_source.dart';
import 'package:test_tect_hellocse_tisserand/data/models/city_model.dart';

const _boxName = 'favorites_box';

const _paris = CityModel(
  id: 2988507,
  name: 'Paris',
  country: 'France',
  admin1: 'Île-de-France',
  latitude: 48.85341,
  longitude: 2.3488,
);

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_favorites_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('ajoute puis retire un favori', () async {
    Hive.init(tempDir.path);
    final box = await Hive.openBox<Map>(_boxName);
    final dataSource = FavoritesLocalDataSourceImpl(box);

    expect(dataSource.getFavorites(), isEmpty);
    expect(dataSource.isFavorite(_paris.id), isFalse);

    await dataSource.addFavorite(_paris);
    expect(dataSource.isFavorite(_paris.id), isTrue);
    expect(dataSource.getFavorites().single.name, 'Paris');

    await dataSource.removeFavorite(_paris.id);
    expect(dataSource.getFavorites(), isEmpty);

    await Hive.close();
  });

  test(
    'un favori survit à la fermeture et réouverture de Hive (redémarrage)',
    () async {
      Hive.init(tempDir.path);
      final firstSessionBox = await Hive.openBox<Map>(_boxName);
      await FavoritesLocalDataSourceImpl(firstSessionBox).addFavorite(_paris);
      await Hive.close();

      Hive.init(tempDir.path);
      final secondSessionBox = await Hive.openBox<Map>(_boxName);
      final favoritesAfterRestart = FavoritesLocalDataSourceImpl(
        secondSessionBox,
      ).getFavorites();

      expect(favoritesAfterRestart, hasLength(1));
      expect(favoritesAfterRestart.single.id, _paris.id);
      expect(favoritesAfterRestart.single.name, 'Paris');

      await Hive.close();
    },
  );
}
