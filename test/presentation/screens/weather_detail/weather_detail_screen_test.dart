import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_tect_hellocse_tisserand/core/error/failures.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/city.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/daily_forecast.dart';
import 'package:test_tect_hellocse_tisserand/domain/repositories/favorites_repository.dart';
import 'package:test_tect_hellocse_tisserand/domain/repositories/weather_repository.dart';
import 'package:test_tect_hellocse_tisserand/domain/usecases/recommend_activity.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/weather_detail/weather_detail_bloc.dart';
import 'package:test_tect_hellocse_tisserand/presentation/cubit/favorites/favorites_cubit.dart';
import 'package:test_tect_hellocse_tisserand/presentation/screens/weather_detail/weather_detail_screen.dart';

const _paris = City(
  id: 2988507,
  name: 'Paris',
  country: 'France',
  admin1: 'Île-de-France',
  latitude: 48.85341,
  longitude: 2.3488,
);

const _recommendationLabels = ['Recommandée', 'Possible', 'Déconseillée'];

class _FakeWeatherRepository implements WeatherRepository {
  _FakeWeatherRepository({this.shouldFail = false});

  final bool shouldFail;
  int callCount = 0;

  @override
  Future<List<DailyForecast>> getForecast(City city) async {
    callCount++;
    if (shouldFail) {
      throw const NetworkFailure('Pas de connexion internet.');
    }
    return [
      DailyForecast(
        date: DateTime(2026, 7, 22),
        weatherCode: 0,
        temperatureMin: 15,
        temperatureMax: 25,
        precipitationProbability: 5,
        windSpeedMax: 10,
      ),
      DailyForecast(
        date: DateTime(2026, 7, 23),
        weatherCode: 3,
        temperatureMin: 16,
        temperatureMax: 21,
        precipitationProbability: 40,
        windSpeedMax: 40,
      ),
    ];
  }
}

class _InMemoryFavoritesRepository implements FavoritesRepository {
  final List<City> _favorites = [];

  @override
  Future<void> addFavorite(City city) async => _favorites.add(city);

  @override
  Future<List<City>> getFavorites() async => List.of(_favorites);

  @override
  Future<bool> isFavorite(City city) async =>
      _favorites.any((c) => c.id == city.id);

  @override
  Future<void> removeFavorite(City city) async =>
      _favorites.removeWhere((c) => c.id == city.id);
}

Widget _wrap({
  required WeatherRepository weatherRepository,
  FavoritesCubit? favoritesCubit,
}) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesCubit>.value(
          value:
              favoritesCubit ?? FavoritesCubit(_InMemoryFavoritesRepository()),
        ),
        BlocProvider<WeatherDetailBloc>(
          create: (_) =>
              WeatherDetailBloc(weatherRepository, const RecommendActivity()),
        ),
      ],
      child: const WeatherDetailScreen(city: _paris),
    ),
  );
}

Finder _recommendationBadges() => find.byWidgetPredicate(
  (w) => w is Text && _recommendationLabels.contains(w.data),
);

void main() {
  testWidgets(
    'aucune recommandation tant qu\'aucune activité n\'est sélectionnée',
    (tester) async {
      await tester.pumpWidget(
        _wrap(weatherRepository: _FakeWeatherRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Ciel clair'), findsOneWidget);
      expect(_recommendationBadges(), findsNothing);
      expect(find.text('Choisir une activité'), findsOneWidget);
    },
  );

  testWidgets('choisir une activité dans le bottom sheet affiche les badges', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(weatherRepository: _FakeWeatherRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisir une activité'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balade'));
    await tester.pumpAndSettle();

    // Balade : vent à 40 km/h du 2e jour reste acceptable -> Possible.
    expect(find.text('Possible'), findsOneWidget);
    expect(find.text('Déconseillée'), findsNothing);
    // Le bouton affiche désormais l'activité choisie.
    expect(find.widgetWithText(FilledButton, 'Balade'), findsOneWidget);
  });

  testWidgets('changer d\'activité recalcule les recommandations affichées', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(weatherRepository: _FakeWeatherRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisir une activité'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Balade'));
    await tester.pumpAndSettle();
    expect(find.text('Possible'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Balade'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pique-nique'));
    await tester.pumpAndSettle();

    // Pique-nique : vent à 40 km/h dépasse le seuil acceptable -> Déconseillée.
    expect(find.text('Déconseillée'), findsOneWidget);
  });

  testWidgets('choisir "Aucune" retire les badges de recommandation', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(weatherRepository: _FakeWeatherRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisir une activité'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Golf'));
    await tester.pumpAndSettle();
    expect(_recommendationBadges(), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Golf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aucune'));
    await tester.pumpAndSettle();

    expect(_recommendationBadges(), findsNothing);
    expect(find.text('Choisir une activité'), findsOneWidget);
  });

  testWidgets('affiche une erreur avec un bouton Réessayer fonctionnel', (
    tester,
  ) async {
    final repository = _FakeWeatherRepository(shouldFail: true);
    await tester.pumpWidget(_wrap(weatherRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Pas de connexion internet.'), findsOneWidget);
    expect(repository.callCount, 1);

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(repository.callCount, 2);
    expect(find.text('Pas de connexion internet.'), findsOneWidget);
  });

  testWidgets('le bouton favori bascule l\'état de la ville affichée', (
    tester,
  ) async {
    final favoritesCubit = FavoritesCubit(_InMemoryFavoritesRepository());
    addTearDown(favoritesCubit.close);

    await tester.pumpWidget(
      _wrap(
        weatherRepository: _FakeWeatherRepository(),
        favoritesCubit: favoritesCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
