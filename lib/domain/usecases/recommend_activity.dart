import '../entities/activity.dart';
import '../entities/daily_forecast.dart';
import '../entities/recommendation_level.dart';

class RecommendActivity {
  const RecommendActivity();

  RecommendationLevel call(DailyForecast forecast, Activity activity) {
    final thresholds = _thresholds[activity]!;
    final averageTemperature =
        (forecast.temperatureMin + forecast.temperatureMax) / 2;

    final ratings = [
      _rateTemperature(averageTemperature, thresholds),
      _ratePrecipitation(forecast.precipitationProbability, thresholds),
      _rateWind(forecast.windSpeedMax, thresholds),
    ];

    if (ratings.contains(_CriterionRating.bad)) {
      return RecommendationLevel.notRecommended;
    }
    if (ratings.every((rating) => rating == _CriterionRating.good)) {
      return RecommendationLevel.recommended;
    }
    return RecommendationLevel.possible;
  }

  _CriterionRating _rateTemperature(double temperature, _ActivityThresholds t) {
    if (temperature >= t.goodTemperatureMin &&
        temperature <= t.goodTemperatureMax) {
      return _CriterionRating.good;
    }
    if (temperature >= t.acceptableTemperatureMin &&
        temperature <= t.acceptableTemperatureMax) {
      return _CriterionRating.acceptable;
    }
    return _CriterionRating.bad;
  }

  _CriterionRating _ratePrecipitation(
    int precipitationProbability,
    _ActivityThresholds t,
  ) {
    if (precipitationProbability <= t.goodMaxPrecipitationProbability) {
      return _CriterionRating.good;
    }
    if (precipitationProbability <= t.acceptableMaxPrecipitationProbability) {
      return _CriterionRating.acceptable;
    }
    return _CriterionRating.bad;
  }

  _CriterionRating _rateWind(double windSpeed, _ActivityThresholds t) {
    if (windSpeed <= t.goodMaxWindSpeed) {
      return _CriterionRating.good;
    }
    if (windSpeed <= t.acceptableMaxWindSpeed) {
      return _CriterionRating.acceptable;
    }
    return _CriterionRating.bad;
  }

  static const Map<Activity, _ActivityThresholds> _thresholds = {
    Activity.walk: _ActivityThresholds(
      goodTemperatureMin: 10,
      goodTemperatureMax: 28,
      acceptableTemperatureMin: 0,
      acceptableTemperatureMax: 35,
      goodMaxPrecipitationProbability: 20,
      acceptableMaxPrecipitationProbability: 60,
      goodMaxWindSpeed: 30,
      acceptableMaxWindSpeed: 50,
    ),
    Activity.run: _ActivityThresholds(
      goodTemperatureMin: 5,
      goodTemperatureMax: 22,
      acceptableTemperatureMin: -5,
      acceptableTemperatureMax: 30,
      goodMaxPrecipitationProbability: 20,
      acceptableMaxPrecipitationProbability: 60,
      goodMaxWindSpeed: 25,
      acceptableMaxWindSpeed: 45,
    ),
    Activity.picnic: _ActivityThresholds(
      goodTemperatureMin: 15,
      goodTemperatureMax: 28,
      acceptableTemperatureMin: 10,
      acceptableTemperatureMax: 33,
      goodMaxPrecipitationProbability: 10,
      acceptableMaxPrecipitationProbability: 50,
      goodMaxWindSpeed: 20,
      acceptableMaxWindSpeed: 35,
    ),
    Activity.golf: _ActivityThresholds(
      goodTemperatureMin: 12,
      goodTemperatureMax: 26,
      acceptableTemperatureMin: 2,
      acceptableTemperatureMax: 32,
      goodMaxPrecipitationProbability: 15,
      acceptableMaxPrecipitationProbability: 50,
      goodMaxWindSpeed: 20,
      acceptableMaxWindSpeed: 35,
    ),
    Activity.tennis: _ActivityThresholds(
      goodTemperatureMin: 15,
      goodTemperatureMax: 27,
      acceptableTemperatureMin: 5,
      acceptableTemperatureMax: 32,
      goodMaxPrecipitationProbability: 10,
      acceptableMaxPrecipitationProbability: 35,
      goodMaxWindSpeed: 15,
      acceptableMaxWindSpeed: 30,
    ),
  };
}

enum _CriterionRating { good, acceptable, bad }

class _ActivityThresholds {
  const _ActivityThresholds({
    required this.goodTemperatureMin,
    required this.goodTemperatureMax,
    required this.acceptableTemperatureMin,
    required this.acceptableTemperatureMax,
    required this.goodMaxPrecipitationProbability,
    required this.acceptableMaxPrecipitationProbability,
    required this.goodMaxWindSpeed,
    required this.acceptableMaxWindSpeed,
  });

  final double goodTemperatureMin;
  final double goodTemperatureMax;
  final double acceptableTemperatureMin;
  final double acceptableTemperatureMax;
  final int goodMaxPrecipitationProbability;
  final int acceptableMaxPrecipitationProbability;
  final double goodMaxWindSpeed;
  final double acceptableMaxWindSpeed;
}
