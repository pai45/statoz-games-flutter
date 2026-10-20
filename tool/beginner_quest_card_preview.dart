import 'package:card_game/config/game_ladder.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/models/unlock_progress.dart';
import 'package:card_game/screens/predictions/widgets/beginner_quest_card.dart';
import 'package:flutter/material.dart';

void main() => runApp(const _QuestPreview());

class _QuestPreview extends StatefulWidget {
  const _QuestPreview();

  @override
  State<_QuestPreview> createState() => _QuestPreviewState();
}

class _QuestPreviewState extends State<_QuestPreview> {
  Sport _sport = Sport.football;
  int _cleared = 0;
  bool _largeText = false;
  double _width = 393;

  UnlockProgress get _progress {
    var progress = UnlockProgress.fresh(_sport);
    for (var i = 0; i < _cleared; i++) {
      final game = sportGameLadder[_sport]![i];
      progress = progress.recordPlay(game, 'preview-${game.name}').progress;
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Wrap(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _sport = Sport.football;
                    _cleared = 0;
                  }),
                  child: const Text('Football start'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _sport = Sport.football;
                    _cleared = 2;
                  }),
                  child: const Text('Football quiz'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _sport = Sport.football;
                    _cleared = 3;
                  }),
                  child: const Text('Explorer'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _sport = Sport.football;
                    _cleared = 5;
                  }),
                  child: const Text('Football final'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _sport = Sport.cricket;
                    _cleared = 0;
                  }),
                  child: const Text('Cricket'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _width = _width == 393 ? 320 : 393;
                    _largeText = !_largeText;
                  }),
                  child: Text(_largeText ? '320 / large' : '393 / normal'),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _width,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(_largeText ? 1.4 : 1),
                      disableAnimations: _largeText,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: BeginnerQuestCard(
                        sport: _sport,
                        unlocks: _progress,
                        onPlay: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
