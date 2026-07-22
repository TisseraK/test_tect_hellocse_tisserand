import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';
import 'core/storage/hive_initializer.dart';
import 'presentation/bloc/city_search/city_search_bloc.dart';
import 'presentation/bloc/weather_detail/weather_detail_bloc.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/weather_detail/weather_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await HiveInitializer.init();
  await initDependencies();
  runApp(MeteoDeSortieApp());
}

class MeteoDeSortieApp extends StatelessWidget {
  const MeteoDeSortieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo de sortie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider<CitySearchBloc>(
        create: (_) => sl<CitySearchBloc>(),
        child: Builder(
          builder: (context) => SearchScreen(
            onCitySelected: (city) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<WeatherDetailBloc>(
                    create: (_) => sl<WeatherDetailBloc>(),
                    child: WeatherDetailScreen(city: city),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
