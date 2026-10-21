import 'package:flutter/material.dart';

import 'games_web_host.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StatOzGamesApp());
}

class StatOzGamesApp extends StatelessWidget {
  const StatOzGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'StatOz Games',
      debugShowCheckedModeBanner: false,
      home: GamesWebHost(),
    );
  }
}
