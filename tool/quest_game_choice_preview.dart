// Production quest widgets and selection handler with isolated in-memory saves.
// Fixture seeding deliberately uses Bloc.emit; production selection uses events.
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_state.dart';
import 'package:card_game/config/game_ladder.dart';
import 'package:card_game/config/sport_modules.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/models/unlock_progress.dart';
import 'package:card_game/screens/predictions/widgets/beginner_quest_card.dart';
import 'package:card_game/screens/predictions/widgets/unlock_sheets.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart';
import 'package:card_game/widgets/unlock_celebration_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _MemoryStorage extends SecureGameStorage {
  bool fail = false;
  UnlockProgress? saved;
  @override
  Future<void> saveUnlockProgress(UnlockProgress progress) async {
    if (fail) throw StateError('Preview save failure');
    saved = UnlockProgress.fromJson(progress.toJson());
  }
}

class _PreviewBloc extends GameBloc {
  _PreviewBloc(this.memory) : super(memory) {
    reset(Sport.football);
  }
  final _MemoryStorage memory;
  void reset(Sport sport) => emit(
    GameState.initial().copyWith(
      loading: false,
      unlocks: UnlockProgress.fresh(sport),
    ),
  );
  void reload() {
    if (memory.saved != null) emit(state.copyWith(unlocks: memory.saved));
  }

  void finish(Sport sport) {
    final game = state.unlocks.currentStep(sport);
    if (game == null) return;
    final result = state.unlocks.recordPlay(
      game,
      'preview-${state.unlocks.stepsCleared(sport)}',
    );
    memory.saved = result.progress;
    emit(
      state.copyWith(
        unlocks: result.progress,
        coins: result.questCompleted ? 50 : state.coins,
      ),
    );
  }
}

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
  final _memory = _MemoryStorage();
  late final _bloc = _PreviewBloc(_memory);
  final _nav = GlobalKey<NavigatorState>();
  Sport _sport = Sport.football;
  bool _large = false;
  bool _rookie = false;
  ArcadeGame? _launched;

  @override
  void initState() {
    super.initState();
    UnlockRevealGate.instance
      ..hubVisible.value = true
      ..chooseGame = ((sport) {
        final context = _nav.currentContext!;
        showQuestGamePicker(context, sport, onPlay: _launch);
      })
      ..openQuestHub = (() => setState(() => _rookie = true))
      ..backToGames = (() => setState(() => _rookie = false));
  }

  void _launch(ArcadeGame game) => setState(() => _launched = game);

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Text(
            'QUEST CHOICE PREVIEW · ISOLATED SAVE',
            style: Cyber.label(11, color: Cyber.muted),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final sport in Sport.values)
                TextButton(
                  onPressed: () {
                    _bloc.reset(sport);
                    setState(() {
                      _sport = sport;
                      _launched = null;
                    });
                  },
                  child: Text(sportModuleFor(sport).label),
                ),
              TextButton(
                onPressed: () => setState(() => _large = !_large),
                child: Text(_large ? '320 / 1.4x / reduced' : '393 / normal'),
              ),
              TextButton(
                onPressed: () => setState(() => _rookie = !_rookie),
                child: Text(_rookie ? 'Games' : 'Rookie Path'),
              ),
              TextButton(
                onPressed: () {
                  _bloc.finish(_sport);
                  setState(() => _launched = null);
                },
                child: const Text('Finish mission'),
              ),
              TextButton(
                onPressed: _bloc.reload,
                child: const Text('Reload save'),
              ),
              TextButton(
                onPressed: () => setState(() => _memory.fail = !_memory.fail),
                child: Text(_memory.fail ? 'Save fails' : 'Save works'),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: _large ? 320 : 393,
                child: BlocProvider<GameBloc>.value(
                  value: _bloc,
                  child: MaterialApp(
                    navigatorKey: _nav,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.darkTheme,
                    builder: (context, child) => GameTypographyScope(
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(_large ? 1.4 : 1),
                          disableAnimations: _large,
                        ),
                        child: child!,
                      ),
                    ),
                    home: Scaffold(
                      body: BlocBuilder<GameBloc, GameState>(
                        builder: (context, state) => Stack(
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_launched != null) ...[
                                    Text(
                                      'LOBBY CALLBACK · ${_launched!.title}',
                                      style: Cyber.label(
                                        10,
                                        color: Cyber.success,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (_rookie)
                                    RookiePathPanel(
                                      sport: _sport,
                                      unlocks: state.unlocks,
                                      onPlay: _launch,
                                    )
                                  else
                                    BeginnerQuestCard(
                                      sport: _sport,
                                      unlocks: state.unlocks,
                                      onPlay: _launch,
                                    ),
                                  const SizedBox(height: 16),
                                  for (final game in state.unlocks.routeFor(
                                    _sport,
                                  )) ...[
                                    CyberPanel(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            game.title,
                                            style: Cyber.display(13),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            state.unlocks
                                                    .completedFor(_sport)
                                                    .contains(game)
                                                ? 'CLEARED · REPLAY'
                                                : state.unlocks.currentStep(
                                                        _sport,
                                                      ) ==
                                                      game
                                                ? 'ACTIVE MISSION'
                                                : 'LOCKED',
                                            style: Cyber.label(
                                              9,
                                              color: Cyber.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ],
                              ),
                            ),
                            const Positioned.fill(
                              child: UnlockCelebrationHost(),
                            ),
                          ],
                        ),
                      ),
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
