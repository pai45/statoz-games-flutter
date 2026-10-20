// Local production-widget review using the existing bundled records, without a live refresh.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_game/blocs/picks/picks_cubit.dart';
import 'package:card_game/blocs/prediction/prediction_cubit.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/services/pick_repository.dart';
import 'package:card_game/services/prediction_repository.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/screens/predictions/widgets/trending_match_bento.dart';

class ReviewPredictions extends PredictionCubit {
  ReviewPredictions(SecureGameStorage storage)
    : super(MockPredictionRepository(), storage);
  @override
  Future<void> loadSport(Sport sport) async {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = SecureGameStorage();
  final predictions = ReviewPredictions(storage);
  final picks = PicksCubit(MockPickRepository(), storage);
  await predictions.load();
  await predictions.ingestFixtures(await MockPredictionRepository().fixtures());
  await picks.load();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PredictionCubit>.value(value: predictions),
        BlocProvider<PicksCubit>.value(value: picks),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          final scale = double.tryParse(
            Uri.base.queryParameters['scale'] ?? '',
          );
          return scale == null
              ? child!
              : MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                );
        },
        home: const Review(),
      ),
    ),
  );
}

class Review extends StatelessWidget {
  const Review({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('STATOZ // MATCH TRENDING', style: Cyber.display(16)),
    ),
    body: TrendingMatchesView(
      onOpenMatch: (_) {},
      onOpenMarket: (_) {},
      onOpenQuiz: (Sport sport) {},
      animateIntro: false,
    ),
  );
}
