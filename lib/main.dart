import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';
import 'core/storage/hive_initializer.dart';

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
      home: const _FoundationsPlaceholder(),
    );
  }
}

class _FoundationsPlaceholder extends StatelessWidget {
  const _FoundationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Météo de sortie — fondations en place')),
    );
  }
}
