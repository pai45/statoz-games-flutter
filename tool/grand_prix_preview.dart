// Production screens with isolated local fixtures; never loads a saved career.
import 'dart:math';

import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_state.dart';
import 'package:card_game/blocs/grand_prix/grand_prix_cubit.dart';
import 'package:card_game/blocs/grand_prix/grand_prix_state.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/data/grand_prix_circuits.dart';
import 'package:card_game/models/cards.dart';
import 'package:card_game/models/grand_prix.dart';
import 'package:card_game/screens/grand_prix/grand_prix_lobby_screen.dart';
import 'package:card_game/screens/grand_prix/grand_prix_pit_deck_screen.dart';
import 'package:card_game/screens/grand_prix/grand_prix_race_screen.dart';
import 'package:card_game/screens/grand_prix/widgets/grand_prix_result.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/utils/sound_effects.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _PreviewStorage extends SecureGameStorage {
  @override
  Future<void> saveGrandPrixStats(GrandPrixStats stats) async {}
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final query = Uri.base.queryParameters;
  final mode = query['screen'] ?? 'race';
  final circuit = grandPrixCircuitFromName(query['circuit']);
  final storage = _PreviewStorage();
  final game = GameBloc(storage);
  final base = GameState.initial();
  final driver = racingPlayerCards.first;
  // ignore: invalid_use_of_visible_for_testing_member
  game.emit(
    base.copyWith(
      loading: false,
      deckRacingPlayers: [driver],
      deckRacingStarter: driver,
      ownedCardIds: [...base.ownedCardIds, driver.id],
      ownedGrandPrixLiveryIds: ['gridLine'],
      grandPrixStarterPackClaimed: true,
    ),
  );
  final cubit = GrandPrixCubit(storage, random: Random(77));
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  cubit.emit(
    const GrandPrixState().copyWith(
      loading: false,
      stats: GrandPrixStats(
        lastCircuit: circuit,
        lastLaps: int.tryParse(query['laps'] ?? '') ?? 1,
        coachSeen: mode != 'coach',
        reducedEffects: query['effects'] == 'reduced',
      ),
    ),
  );
  cubit.buildRace(6);
  if (mode == 'pause') {
    cubit.beginLights(reducedMotion: true);
    cubit.pauseRace();
  }
  AudioController.instance.setMuted(query['audio'] != 'on', persist: false);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: game),
        BlocProvider.value(value: cubit),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              double.tryParse(query['text'] ?? '') ?? 1,
            ),
            disableAnimations: query['motion'] == 'reduced',
          ),
          child: GameTypographyScope(child: child!),
        ),
        home: mode == 'pit'
            ? GrandPrixPitDeckScreen(onBack: () {})
            : mode == 'lobby'
            ? GrandPrixLobbyScreen(onNavigate: (_) {})
            : mode == 'result'
            ? Scaffold(
                body: Stack(
                  children: [
                    GrandPrixResultOverlay(
                      result: GrandPrixResult(
                        position: 3,
                        fieldSize: 20,
                        startPosition: 12,
                        lapTimeMs: 189000,
                        personalBest: true,
                        launchGrade: LaunchGrade.great,
                        circuit: circuit,
                        xp: 39,
                        laps: 3,
                        lapTimesMs: const [64000, 63000, 62000],
                        cleanRace: true,
                        cleanOvertakes: 4,
                        newMastery: GrandPrixMastery.values,
                      ),
                      circuitName: grandPrixCircuit(circuit).name,
                      onExit: () {},
                      onRaceAgain: () {},
                    ),
                  ],
                ),
              )
            : GrandPrixRaceScreen(onExit: () {}, onRaceAgain: () {}),
      ),
    ),
  );
}
