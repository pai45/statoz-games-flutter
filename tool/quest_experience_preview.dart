// Local UI verification: flutter run -d web-server -t tool/quest_experience_preview.dart
// Seeds in-memory quest states for visual review.
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_state.dart';
import 'package:card_game/blocs/picks/picks_cubit.dart';
import 'package:card_game/blocs/prediction/prediction_cubit.dart';
import 'package:card_game/config/game_ladder.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/models/unlock_progress.dart';
import 'package:card_game/screens/predictions/streak_calendar_screen.dart';
import 'package:card_game/screens/predictions/widgets/beginner_quest_card.dart';
import 'package:card_game/screens/predictions/widgets/unlock_sheets.dart';
import 'package:card_game/services/pick_repository.dart';
import 'package:card_game/services/prediction_repository.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart';
import 'package:card_game/widgets/unlock_celebration_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _PreviewBloc extends GameBloc {
  _PreviewBloc() : super(SecureGameStorage()) {
    seed(0);
  }
  void seed(int count, {bool reveal = false, bool active = false}) {
    var progress = UnlockProgress.fresh(Sport.football);
    QuestCompletionReceipt? receipt;
    for (var i = 0; i < count; i++) {
      final game = sportGameLadder[Sport.football]![i];
      progress = progress.selectGame(game);
      final result = progress.recordPlay(game, 'preview-$i');
      progress = result.progress;
      receipt = QuestCompletionReceipt(
        game: game,
        sourceId: 'preview-$i',
        completed: i + 1,
        total: 6,
        graduated: result.graduated,
        questCompleted: result.questCompleted,
        nextGame: result.unlockedGame,
      );
    }
    if (active && count < sportGameLadder[Sport.football]!.length) {
      progress = progress.selectGame(sportGameLadder[Sport.football]![count]);
    }
    progress = progress.copyWith(
      pendingReveals: reveal && progress.pendingReveals.isNotEmpty
          ? [progress.pendingReveals.last]
          : [],
    );
    // Preview fixture deliberately seeds an in-memory Bloc without app events.
    // ignore: invalid_use_of_visible_for_testing_member
    emit(
      GameState.initial().copyWith(
        loading: false,
        unlocks: progress,
        coins: count == 6 ? 50 : 0,
        questReceipts: receipt == null ? {} : {receipt.id: receipt},
      ),
    );
  }
}

void main() => runApp(
  MultiBlocProvider(
    providers: [
      BlocProvider<GameBloc>(create: (_) => _PreviewBloc()),
      BlocProvider(
        create: (_) =>
            PredictionCubit(MockPredictionRepository(), SecureGameStorage()),
      ),
      BlocProvider(
        create: (_) => PicksCubit(MockPickRepository(), SecureGameStorage()),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _Preview(),
    ),
  ),
);

class _Preview extends StatefulWidget {
  const _Preview();
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  String _screen = 'quest';
  double _width = 393;
  bool _large = false;

  @override
  void initState() {
    super.initState();
    UnlockRevealGate.instance
      ..playGame = ((_) => select('quest', 3))
      ..openQuestHub = (() => select('hub', 3))
      ..chooseSport = (() => select('sports', 6))
      ..backToGames = (() => select('hub', 6))
      ..continueQuest = (() => select('reveal', 3));
  }

  void select(String screen, int count) {
    (context.read<GameBloc>() as _PreviewBloc).seed(
      count,
      reveal: screen == 'reveal',
      active: screen == 'live',
    );
    UnlockRevealGate.instance.hubVisible.value = screen == 'reveal';
    setState(() => _screen = screen);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Text('QUEST UI PREVIEW - SIMULATED RESULTS', style: Cyber.body(12)),
        Wrap(
          children: [
            for (final item in [
              ('Start', 'quest', 0),
              ('Quiz', 'quest', 2),
              ('Live', 'live', 2),
              ('Explorer', 'quest', 3),
              ('Daily hub', 'hub', 3),
              ('Receipt', 'receipt', 3),
              ('Graduate', 'reveal', 3),
              ('Complete', 'reveal', 6),
              ('Sports', 'sports', 6),
            ])
              TextButton(
                onPressed: () => select(item.$2, item.$3),
                child: Text(item.$1),
              ),
            TextButton(
              onPressed: () => setState(() {
                _width = _width == 393 ? 320 : 393;
                _large = !_large;
              }),
              child: Text(_large ? '320 / large' : '393 / normal'),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: _width,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(_width, 852),
                  textScaler: TextScaler.linear(_large ? 1.4 : 1),
                  disableAnimations: _large,
                ),
                child: BlocBuilder<GameBloc, GameState>(
                  builder: (context, state) => Stack(
                    children: [
                      Positioned.fill(
                        child: switch (_screen) {
                          'hub' => StreakCalendarScreen(
                            onBeginnerNavigate: (_) {},
                          ),
                          'sports' => SportUnlockSheet(sport: Sport.cricket),
                          'receipt' => SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text('QUIZ COMPLETE', style: Cyber.display(24)),
                                const QuestResultReceipt(
                                  game: ArcadeGame.footballQuiz,
                                  sourceId: 'preview-2',
                                ),
                              ],
                            ),
                          ),
                          _ => SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: RookiePathPanel(
                              sport: Sport.football,
                              unlocks: state.unlocks,
                              onPlay: (_) {},
                            ),
                          ),
                        },
                      ),
                      if (_screen == 'reveal')
                        const Positioned.fill(child: UnlockCelebrationHost()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
