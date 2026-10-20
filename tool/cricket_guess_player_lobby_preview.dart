// Isolated visual review for the Cricket Guess the Player lobby.
// flutter run -d chrome -t tool/cricket_guess_player_lobby_preview.dart
import 'package:card_game/blocs/guess_player/guess_player_cubit.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/data/guess_player_data.dart';
import 'package:card_game/models/cards.dart';
import 'package:card_game/models/guess_player.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/screens/guess_player/guess_player_home_screen.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: const _Preview(),
  ),
);

class _Preview extends StatefulWidget {
  const _Preview();
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late final GuessPlayerCubit _cubit = GuessPlayerCubit(
    sport: Sport.cricket,
    timelines: cricketGuessTimelines,
    allPlayers: cricketPlayerCards,
    storage: SecureGameStorage(),
  );
  int _phase = 0;
  bool _small = false;
  bool _reduced = false;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  GuessPlayerState get _fixture {
    final day = guessPlayerDayKey(DateTime.now());
    final status = _phase == 2
        ? GuessPlayerResultStatus.won
        : GuessPlayerResultStatus.inProgress;
    final record = GuessPlayerDayRecord(
      dayKey: day,
      puzzleId: 'cricket-gallery',
      playerId: 'classified',
      status: status,
      guessedPlayerIds: const [],
      revealedClueCount: _phase == 0 ? 1 : 2,
      attemptsRemaining: _phase == 0 ? 6 : 5,
      score: _phase == 2 ? 500 : 0,
      xpEarned: _phase == 2 ? 45 : 0,
      elapsedMs: 0,
      startedAtEpochMs: _phase == 0 ? 0 : 1,
      completedAtEpochMs: _phase == 2 ? 2 : 0,
    );
    return GuessPlayerState.loading(day).copyWith(
      loadStatus: GuessPlayerLoadStatus.ready,
      archive: GuessPlayerArchive(resultsByDay: {day: record}),
      activeRecord: record,
      attemptsRemaining: record.attemptsRemaining,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('CRICKET LOBBY // UI REVIEW', style: Cyber.display(18)),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final item in [
                ('Fresh', 0),
                ('In progress', 1),
                ('Solved', 2),
              ])
                TextButton(
                  onPressed: () => setState(() => _phase = item.$2),
                  child: Text(item.$1),
                ),
              TextButton(
                onPressed: () => setState(() => _small = !_small),
                child: Text(_small ? '320px / 1.4x' : '393px / 1x'),
              ),
              TextButton(
                onPressed: () => setState(() => _reduced = !_reduced),
                child: Text(_reduced ? 'Reduced motion' : 'Motion on'),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: _small ? 320 : 393,
                height: 720,
                child: BlocProvider<GuessPlayerCubit>.value(
                  value: _cubit,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(_small ? 320 : 393, 720),
                      textScaler: TextScaler.linear(_small ? 1.4 : 1),
                      disableAnimations: _reduced,
                    ),
                    child: GuessPlayerHomeScreen(
                      state: _fixture,
                      onBack: () {},
                      onOpenToday: () {},
                      onOpenLogs: () {},
                      onRetry: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
