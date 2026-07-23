import 'package:flutter/material.dart';

import '../../domain/entities/daily_forecast.dart';
import '../../domain/entities/recommendation_level.dart';
import '../utils/french_date_formatter.dart';
import '../utils/weather_condition.dart';
import 'recommendation_badge.dart';

class DailyForecastTile extends StatelessWidget {
  const DailyForecastTile({
    super.key,
    required this.forecast,
    this.recommendation,
  });

  final DailyForecast forecast;

  /// `null` si aucune activité n'est sélectionnée : dans ce cas, aucun badge
  /// n'est affiché.
  final RecommendationLevel? recommendation;

  @override
  Widget build(BuildContext context) {
    final condition = weatherConditionFor(forecast.weatherCode);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(condition.icon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatDayLabel(forecast.date)),
                      Text(condition.label),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${forecast.temperatureMax.round()}° / ${forecast.temperatureMin.round()}°',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text('${forecast.precipitationProbability}%'),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.air,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text('${forecast.windSpeedMax.round()} km/h'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (recommendation != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: RecommendationBadge(level: recommendation!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
