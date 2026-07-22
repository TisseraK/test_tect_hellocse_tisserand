import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/activity.dart';
import '../../../domain/entities/city.dart';
import '../../bloc/weather_detail/weather_detail_bloc.dart';
import '../../bloc/weather_detail/weather_detail_event.dart';
import '../../bloc/weather_detail/weather_detail_state.dart';
import '../../widgets/activity_selector.dart';
import '../../widgets/daily_forecast_tile.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key, required this.city});

  final City city;

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  Activity _selectedActivity = Activity.walk;

  @override
  void initState() {
    super.initState();
    _requestForecast();
  }

  void _requestForecast() {
    context.read<WeatherDetailBloc>().add(
      WeatherDetailStarted(widget.city, _selectedActivity),
    );
  }

  void _onActivityChanged(Activity activity) {
    setState(() => _selectedActivity = activity);
    context.read<WeatherDetailBloc>().add(
      WeatherDetailActivityChanged(activity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (widget.city.admin1 != null && widget.city.admin1!.isNotEmpty)
        widget.city.admin1!,
      widget.city.country,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(subtitleParts.join(' · ')),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: ActivitySelector(
              selected: _selectedActivity,
              onChanged: _onActivityChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<WeatherDetailBloc, WeatherDetailState>(
              builder: (context, state) => switch (state) {
                WeatherDetailLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                WeatherDetailError(:final message) => _ErrorView(
                  message: message,
                  onRetry: _requestForecast,
                ),
                WeatherDetailLoaded(:final forecasts, :final recommendations) =>
                  ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: forecasts.length,
                    itemBuilder: (context, index) => DailyForecastTile(
                      forecast: forecasts[index],
                      recommendation: recommendations[index],
                    ),
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
