// Isolated local visual QA entry point; not imported by the production app.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_event.dart';
import 'package:card_game/blocs/final_over/final_over_cubit.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/screens/final_over/final_over_hub.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/utils/sound_effects.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioController.instance.muted.value = true;
  final storage = SecureGameStorage();
  final game = GameBloc(storage);
  final cricket = FinalOverCubit(storage);
  game.add(GameLoaded());
  await Future.wait([
    game.stream.firstWhere((state) => !state.loading),
    cricket.load(),
  ]);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: game),
        BlocProvider.value(value: cricket),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: Uri.base.queryParameters['still'] == '1',
            textScaler: TextScaler.linear(
              double.tryParse(Uri.base.queryParameters['scale'] ?? '') ?? 1,
            ),
          ),
          child: child!,
        ),
        home: FinalOverHub(onExit: () {}),
      ),
    ),
  );
}
