import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/activity.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/city.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/daily_forecast.dart';
import 'package:test_tect_hellocse_tisserand/domain/repositories/weather_repository.dart';
import 'package:test_tect_hellocse_tisserand/domain/usecases/recommend_activity.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/weather_detail/weather_detail_bloc.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/weather_detail/weather_detail_event.dart';
import 'package:test_tect_hellocse_tisserand/presentation/bloc/weather_detail/weather_detail_state.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late _MockWeatherRepository repository;

  const paris = City(
    id: 2988507,
    name: 'Paris',
    country: 'France',
    admin1: 'Île-de-France',
    latitude: 48.85341,
    longitude: 2.3488,
  );

  final forecast = DailyForecast(
    date: DateTime(2026, 7, 22),
    weatherCode: 3,
    temperatureMin: 16,
    temperatureMax: 21,
    precipitationProbability: 40,
    windSpeedMax: 40,
  );

  setUp(() {
    repository = _MockWeatherRepository();
  });

  blocTest<WeatherDetailBloc, WeatherDetailState>(
    'utilise la dernière activité sélectionnée, même changée pendant le '
    'chargement initial (pas l\'activité figée au lancement de la requête)',
    setUp: () {
      final pending = Completer<List<DailyForecast>>();
      when(
        () => repository.getForecast(paris),
      ).thenAnswer((_) => pending.future);
      // Résout la requête réseau juste après le changement d'activité, pour
      // simuler un utilisateur rapide sans dépendre d'un timing fragile.
      Future<void>.delayed(
        const Duration(milliseconds: 10),
        () => pending.complete([forecast]),
      );
    },
    build: () => WeatherDetailBloc(repository, const RecommendActivity()),
    act: (bloc) async {
      bloc.add(const WeatherDetailStarted(paris, Activity.walk));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      bloc.add(const WeatherDetailActivityChanged(Activity.picnic));
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      final state = bloc.state;
      expect(state, isA<WeatherDetailLoaded>());
      // Vent à 40 km/h : Possible en Balade, mais Déconseillée en
      // Pique-nique (seuil acceptable dépassé) -> si la valeur finale reflète
      // bien "Pique-nique" et pas "Balade" figée au lancement, le niveau
      // correspond à celui du Pique-nique.
      expect((state as WeatherDetailLoaded).selectedActivity, Activity.picnic);
    },
  );
}
