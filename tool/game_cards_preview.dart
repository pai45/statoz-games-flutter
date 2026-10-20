// Production Games hub with an isolated, unlocked career for visual QA.
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_state.dart';
import 'package:card_game/blocs/prediction/prediction_cubit.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/screens/predictions/prediction_home_screen.dart';
import 'package:card_game/services/prediction_repository.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _PreviewGameBloc extends GameBloc {
  _PreviewGameBloc() : super(SecureGameStorage()) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(GameState.initial().copyWith(loading: false));
  }
}

void main() => runApp(const _Preview());

class _Preview extends StatefulWidget {
  const _Preview();
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  final _game = _PreviewGameBloc();
  final _prediction = PredictionCubit(
    MockPredictionRepository(),
    SecureGameStorage(),
  );
  int _sport = int.tryParse(Uri.base.queryParameters['sport'] ?? '') ?? 1;
  final _large = Uri.base.queryParameters['large'] == '1';
  final _reduced = Uri.base.queryParameters['reduced'] == '1';

  @override
  void dispose() {
    _game.close();
    _prediction.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<GameBloc>.value(value: _game),
      BlocProvider<PredictionCubit>.value(value: _prediction),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_large ? 1.4 : 1),
          disableAnimations: _reduced,
        ),
        child: child!,
      ),
      home: Builder(
        builder: (context) {
          void launch(String title) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('$title // RETURN', style: Cyber.display(18)),
                  ),
                ),
              ),
            ),
          );
          return PredictionHomeScreen(
            activeTab: 1,
            onTabChanged: (_) {},
            activeMatchSportTab: 1,
            onMatchSportTabChanged: (_) {},
            activeGamesSportTab: _sport,
            onGamesSportTabChanged: (value) => setState(() => _sport = value),
            onNavigate: (_) {},
            onOpenMatch: (_) {},
            onOpenMarket: (_) {},
            onOpenLeague: (_) {},
            onOpenLeagueGames: (_) {},
            onOpenGame: () => launch('PITCH DUEL'),
            onOpenShootout: () => launch('PENALTY SHOOTOUT'),
            onOpenQuiz: (_) => launch('QUIZ'),
            onOpenFootballBingo: () => launch('FOOTBALL BINGO'),
            onOpenFootballChess: () => launch('FOOTBALL CHESS'),
            onOpenGuessPlayer: () => launch('GUESS THE PLAYER'),
            onOpenBasketballGuessPlayer: () => launch('GUESS THE PLAYER'),
            onOpenCricketGuessPlayer: () => launch('GUESS THE PLAYER'),
            onOpenGrandPrix: () => launch('GRAND PRIX DASH'),
            onOpenF1GuessDriver: () => launch('GUESS THE DRIVER'),
            onOpenTennisGuessWinner: () => launch('GUESS THE WINNER'),
            onOpenBasketball: () => launch('HOOP DUEL'),
            onOpenFinalOver: () => launch('FINAL OVER'),
            onOpenTennisRally: () => launch('TENNIS RALLY'),
          );
        },
      ),
    ),
  );
}
