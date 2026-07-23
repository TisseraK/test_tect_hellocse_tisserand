import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/activity.dart';
import '../../../domain/entities/city.dart';
import '../../bloc/weather_detail/weather_detail_bloc.dart';
import '../../bloc/weather_detail/weather_detail_event.dart';
import '../../bloc/weather_detail/weather_detail_state.dart';
import '../../cubit/favorites/favorites_cubit.dart';
import '../../cubit/favorites/favorites_state.dart';
import '../../widgets/daily_forecast_tile.dart';

class WeatherDetailScreen extends StatefulWidget {
  const WeatherDetailScreen({super.key, required this.city});

  final City city;

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  /// `null` tant que l'utilisateur n'a choisi aucune activité : dans ce cas,
  /// aucune recommandation n'est affichée.
  Activity? _selectedActivity;

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

  void _onActivityChanged(Activity? activity) {
    setState(() => _selectedActivity = activity);
    context.read<WeatherDetailBloc>().add(
      WeatherDetailActivityChanged(activity),
    );
  }

  Future<void> _openActivityPicker() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _ActivityPickerSheet(
        selected: _selectedActivity,
        onSelected: (activity) {
          Navigator.of(sheetContext).pop();
          _onActivityChanged(activity);
        },
      ),
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
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final isFavorite =
                  state is FavoritesLoaded && state.contains(widget.city);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                tooltip: isFavorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                onPressed: () =>
                    context.read<FavoritesCubit>().toggleFavorite(widget.city),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(subtitleParts.join(' · ')),
          ),
        ),
      ),
      body: BlocBuilder<WeatherDetailBloc, WeatherDetailState>(
        builder: (context, state) => switch (state) {
          WeatherDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          WeatherDetailError(:final message) => _ErrorView(
            message: message,
            onRetry: _requestForecast,
          ),
          WeatherDetailLoaded(:final forecasts, :final recommendations) =>
            ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: forecasts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => DailyForecastTile(
                forecast: forecasts[index],
                recommendation: recommendations?[index],
              ),
            ),
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.tonalIcon(
          onPressed: _openActivityPicker,
          icon: const Icon(Icons.filter_alt_outlined),
          label: Text(_selectedActivity?.label ?? 'Choisir une activité'),
        ),
      ),
    );
  }
}

class _ActivityPickerSheet extends StatelessWidget {
  const _ActivityPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  final Activity? selected;
  final ValueChanged<Activity?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RadioGroup<Activity?>(
        groupValue: selected,
        onChanged: onSelected,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Activité',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const RadioListTile<Activity?>(
                value: null,
                title: Text('Aucune'),
              ),
              for (final activity in Activity.values)
                RadioListTile<Activity?>(
                  value: activity,
                  title: Text(activity.label),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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
