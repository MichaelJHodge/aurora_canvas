import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/image_api.dart';
import 'data/random_image_repository.dart';
import 'presentation/image/image_screen.dart';
import 'presentation/image/random_image_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RandomImageApi>(create: (_) => RandomImageApi()),
        ProxyProvider<RandomImageApi, RandomImageRepository>(
          update: (_, api, __) => RandomImageRepository(api),
        ),
        ChangeNotifierProvider<RandomImageController>(
          create: (context) =>
              RandomImageController(context.read<RandomImageRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Aurora Canvas',
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const RandomImageScreen(),
      ),
    );
  }
}
