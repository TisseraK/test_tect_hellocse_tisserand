import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/city.dart';
import '../bloc/city_search/city_search_bloc.dart';
import '../bloc/weather_detail/weather_detail_bloc.dart';
import 'favorites/favorites_screen.dart';
import 'search/search_screen.dart';
import 'weather_detail/weather_detail_screen.dart';

/// Point d'entrée de l'app une fois les fondations chargées : deux onglets,
/// Recherche et Favoris, qui poussent tous deux vers le même écran détail.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _openWeatherDetail(City city) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<WeatherDetailBloc>(
          create: (_) => sl<WeatherDetailBloc>(),
          child: WeatherDetailScreen(city: city),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BlocProvider<CitySearchBloc>(
        create: (_) => sl<CitySearchBloc>(),
        child: SearchScreen(onCitySelected: _openWeatherDetail),
      ),
      FavoritesScreen(onCitySelected: _openWeatherDetail),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
        ],
      ),
    );
  }
}
