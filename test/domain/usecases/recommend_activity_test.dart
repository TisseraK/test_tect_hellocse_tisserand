import 'package:flutter_test/flutter_test.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/activity.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/daily_forecast.dart';
import 'package:test_tect_hellocse_tisserand/domain/entities/recommendation_level.dart';
import 'package:test_tect_hellocse_tisserand/domain/usecases/recommend_activity.dart';

DailyForecast _forecast({
  double temperatureMin = 15,
  double temperatureMax = 15,
  int precipitationProbability = 0,
  double windSpeedMax = 0,
}) {
  return DailyForecast(
    date: DateTime(2026, 7, 22),
    weatherCode: 0,
    temperatureMin: temperatureMin,
    temperatureMax: temperatureMax,
    precipitationProbability: precipitationProbability,
    windSpeedMax: windSpeedMax,
  );
}

void main() {
  const recommend = RecommendActivity();

  group('Balade', () {
    test('conditions idéales -> Recommandée', () {
      final forecast = _forecast(
        temperatureMin: 18,
        temperatureMax: 22,
        precipitationProbability: 5,
        windSpeedMax: 10,
      );
      expect(
        recommend(forecast, Activity.walk),
        RecommendationLevel.recommended,
      );
    });

    test('un critère seulement acceptable -> Possible', () {
      final forecast = _forecast(
        temperatureMin: 18,
        temperatureMax: 22, // bon
        precipitationProbability: 40, // acceptable (20 < x <= 60)
        windSpeedMax: 10, // bon
      );
      expect(recommend(forecast, Activity.walk), RecommendationLevel.possible);
    });

    test('température extrême -> Déconseillée même si le reste est bon', () {
      final forecast = _forecast(
        temperatureMin: 38,
        temperatureMax: 40, // > 35, mauvais
        precipitationProbability: 0,
        windSpeedMax: 0,
      );
      expect(
        recommend(forecast, Activity.walk),
        RecommendationLevel.notRecommended,
      );
    });

    test('bornes exactes des seuils "bon" -> Recommandée (inclusif)', () {
      final forecast = _forecast(
        temperatureMin: 10,
        temperatureMax: 10, // borne basse exacte
        precipitationProbability: 20, // borne haute exacte
        windSpeedMax: 30, // borne haute exacte
      );
      expect(
        recommend(forecast, Activity.walk),
        RecommendationLevel.recommended,
      );
    });
  });

  group('Course', () {
    test('conditions idéales -> Recommandée', () {
      final forecast = _forecast(
        temperatureMin: 13,
        temperatureMax: 17,
        precipitationProbability: 5,
        windSpeedMax: 10,
      );
      expect(
        recommend(forecast, Activity.run),
        RecommendationLevel.recommended,
      );
    });

    test('vent trop fort -> Déconseillée', () {
      final forecast = _forecast(
        temperatureMin: 13,
        temperatureMax: 17,
        precipitationProbability: 5,
        windSpeedMax: 50, // > 45, mauvais pour la course
      );
      expect(
        recommend(forecast, Activity.run),
        RecommendationLevel.notRecommended,
      );
    });

    test('pluie modérée seule -> Possible', () {
      final forecast = _forecast(
        temperatureMin: 13,
        temperatureMax: 17,
        precipitationProbability: 40, // acceptable (20 < x <= 60)
        windSpeedMax: 10,
      );
      expect(recommend(forecast, Activity.run), RecommendationLevel.possible);
    });
  });

  group('Pique-nique', () {
    test('conditions idéales -> Recommandée', () {
      final forecast = _forecast(
        temperatureMin: 20,
        temperatureMax: 24,
        precipitationProbability: 5,
        windSpeedMax: 10,
      );
      expect(
        recommend(forecast, Activity.picnic),
        RecommendationLevel.recommended,
      );
    });

    test(
      'pluie forte -> Déconseillée (activité la plus sensible à la pluie)',
      () {
        final forecast = _forecast(
          temperatureMin: 20,
          temperatureMax: 24,
          precipitationProbability: 90, // > 50, mauvais
          windSpeedMax: 10,
        );
        expect(
          recommend(forecast, Activity.picnic),
          RecommendationLevel.notRecommended,
        );
      },
    );

    test('vent modéré seul -> Possible', () {
      final forecast = _forecast(
        temperatureMin: 20,
        temperatureMax: 24,
        precipitationProbability: 5,
        windSpeedMax: 28, // acceptable (20 < x <= 35)
      );
      expect(
        recommend(forecast, Activity.picnic),
        RecommendationLevel.possible,
      );
    });
  });

  group('Golf', () {
    test('conditions idéales -> Recommandée', () {
      final forecast = _forecast(
        temperatureMin: 17,
        temperatureMax: 21,
        precipitationProbability: 5,
        windSpeedMax: 10,
      );
      expect(
        recommend(forecast, Activity.golf),
        RecommendationLevel.recommended,
      );
    });

    test('vent fort -> Déconseillée (trajectoire de balle)', () {
      final forecast = _forecast(
        temperatureMin: 17,
        temperatureMax: 21,
        precipitationProbability: 5,
        windSpeedMax: 40, // > 35, mauvais
      );
      expect(
        recommend(forecast, Activity.golf),
        RecommendationLevel.notRecommended,
      );
    });

    test('pluie modérée seule -> Possible', () {
      final forecast = _forecast(
        temperatureMin: 17,
        temperatureMax: 21,
        precipitationProbability: 30, // acceptable (15 < x <= 50)
        windSpeedMax: 10,
      );
      expect(recommend(forecast, Activity.golf), RecommendationLevel.possible);
    });
  });

  group('Tennis', () {
    test('conditions idéales -> Recommandée', () {
      final forecast = _forecast(
        temperatureMin: 18,
        temperatureMax: 22,
        precipitationProbability: 5,
        windSpeedMax: 10,
      );
      expect(
        recommend(forecast, Activity.tennis),
        RecommendationLevel.recommended,
      );
    });

    test('pluie -> Déconseillée (activité la plus sensible au vent/pluie)', () {
      final forecast = _forecast(
        temperatureMin: 18,
        temperatureMax: 22,
        precipitationProbability: 50, // > 35, mauvais
        windSpeedMax: 10,
      );
      expect(
        recommend(forecast, Activity.tennis),
        RecommendationLevel.notRecommended,
      );
    });

    test('vent modéré seul -> Possible', () {
      final forecast = _forecast(
        temperatureMin: 18,
        temperatureMax: 22,
        precipitationProbability: 5,
        windSpeedMax: 25, // acceptable (15 < x <= 30)
      );
      expect(
        recommend(forecast, Activity.tennis),
        RecommendationLevel.possible,
      );
    });
  });
}
