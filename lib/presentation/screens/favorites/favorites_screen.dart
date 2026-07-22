import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/city.dart';
import '../../cubit/favorites/favorites_cubit.dart';
import '../../cubit/favorites/favorites_state.dart';
import '../../widgets/city_list_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onCitySelected});

  final ValueChanged<City> onCitySelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) => switch (state) {
          FavoritesLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          FavoritesError(:final message) => _Message(
            message: message,
            icon: Icons.error_outline,
          ),
          FavoritesLoaded(:final favorites) when favorites.isEmpty =>
            const _Message(
              message: 'Aucune ville favorite pour le moment.',
              icon: Icons.favorite_border,
            ),
          FavoritesLoaded(:final favorites) => ListView.separated(
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final city = favorites[index];
              return CityListTile(
                city: city,
                onTap: () => onCitySelected(city),
              );
            },
          ),
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
