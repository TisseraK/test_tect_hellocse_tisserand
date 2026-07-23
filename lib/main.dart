import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';
import 'core/storage/hive_initializer.dart';
import 'core/theme/app_theme.dart';
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
    return BlocProvider<FavoritesCubit>(
      create: (_) => sl<FavoritesCubit>(),
      child: MaterialApp(
        title: 'Météo de sortie',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),

        themeMode: ThemeMode.system,
        home: const HomeShell(),
      ),
    );
  }
}
