import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';
import 'core/storage/hive_initializer.dart';
import 'presentation/cubit/favorites/favorites_cubit.dart';
import 'presentation/screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await HiveInitializer.init();
  await initDependencies();
  runApp(const MeteoDeSortieApp());
}

class MeteoDeSortieApp extends StatelessWidget {
  const MeteoDeSortieApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FavoritesCubit est fourni au-dessus du MaterialApp (donc au-dessus de
    // son Navigator interne) : c'est un état partagé par plusieurs routes
    // (écran Favoris, bouton favori de l'écran détail poussé par-dessus),
    // pas un état scopé à une seule route comme les autres BLoC de l'app.
    return BlocProvider<FavoritesCubit>(
      create: (_) => sl<FavoritesCubit>(),
      child: MaterialApp(
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
        home: const HomeShell(),
      ),
    );
  }
}
