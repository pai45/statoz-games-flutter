import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../widgets/cyber/cyber_widgets.dart';
import 'web_game_screen.dart';

class WebGameShelf extends StatelessWidget {
  const WebGameShelf({this.sport, super.key});
  final String? sport;
  static final Future<List<dynamic>> games = rootBundle
      .loadString('assets/web_games/manifest.json')
      .then(
        (value) =>
            (jsonDecode(value) as Map<String, dynamic>)['games']
                as List<dynamic>,
      );
  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
    future: games,
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      return Column(
        children: [
          for (final game in snapshot.data!.cast<Map<String, dynamic>>().where(
            (game) =>
                sport == null ||
                game['sport'] == null ||
                game['sport'] == sport,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 96,
                child: CyberPanel(
                  child: ListTile(
                    title: Text(
                      (game['title'] as String?) ??
                          (game['id'] as String)
                              .replaceAll('-', ' ')
                              .toUpperCase(),
                      style: Cyber.label(14),
                    ),
                    subtitle: Text('OFFLINE WEB DEMO', style: Cyber.body(12)),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WebGameScreen(
                          gameId: game['id'] as String,
                          profileId: 'local',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
