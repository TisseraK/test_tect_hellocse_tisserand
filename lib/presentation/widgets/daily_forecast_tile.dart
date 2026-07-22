import 'package:flutter/material.dart';

import '../../domain/entities/daily_forecast.dart';
import '../utils/french_date_formatter.dart';
import '../utils/weather_condition.dart';

class DailyForecastTile extends StatelessWidget {
  const DailyForecastTile({super.key, required this.forecast});

  final DailyForecast forecast;

  @override
  Widget build(BuildContext context) {
    final condition = weatherConditionFor(forecast.weatherCode);
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(condition.icon, size: 32),
        title: Text(formatDayLabel(forecast.date)),
        subtitle: Text(condition.label),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
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
                Icon(Icons.air, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 2),
                Text('${forecast.windSpeedMax.round()} km/h'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
