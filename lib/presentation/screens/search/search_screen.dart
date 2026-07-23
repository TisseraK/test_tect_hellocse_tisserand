import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/city.dart';
import '../../bloc/city_search/city_search_bloc.dart';
import '../../bloc/city_search/city_search_event.dart';
import '../../bloc/city_search/city_search_state.dart';
import '../../widgets/city_list_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.onCitySelected});

  final ValueChanged<City>? onCitySelected;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _debounceDuration = Duration(milliseconds: 400);

  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      context.read<CitySearchBloc>().add(CitySearchQueryChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher une ville')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBar(
              controller: _controller,
              textInputAction: TextInputAction.search,
              hintText: 'Nom de la ville',
              leading: const Icon(Icons.search),
              onChanged: _onChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<CitySearchBloc, CitySearchState>(
                builder: (context, state) => switch (state) {
                  CitySearchInitial() => const _SearchMessage(
                    message: 'Recherchez une ville pour consulter sa météo.',
                    icon: Icons.travel_explore,
                  ),
                  CitySearchLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  CitySearchEmpty(:final query) => _SearchMessage(
                    message: 'Aucun résultat pour « $query ».',
                    icon: Icons.search_off,
                  ),
                  CitySearchError(:final message) => _SearchMessage(
                    message: message,
                    icon: Icons.error_outline,
                  ),
                  CitySearchLoaded(:final cities) => ListView.separated(
                    itemCount: cities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return CityListTile(
                        city: city,
                        onTap: () => widget.onCitySelected?.call(city),
                      );
                    },
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.message, required this.icon});

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
