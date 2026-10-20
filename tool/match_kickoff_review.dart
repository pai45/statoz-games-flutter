// Production card review with existing bundled identities and illustrative kickoff.
import 'package:flutter/material.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/services/prediction_repository.dart';
import 'package:card_game/widgets/cyber/match_discovery.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fixtures = await MockPredictionRepository().fixtures();
  runApp(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Review(fixtures: fixtures),
    ),
  );
}

class Review extends StatelessWidget {
  const Review({required this.fixtures, super.key});
  final List<SportMatch> fixtures;
  @override
  Widget build(BuildContext context) {
    final scale = double.tryParse(Uri.base.queryParameters['scale'] ?? '') ?? 1;
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: Scaffold(
        backgroundColor: Cyber.bg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('MATCH CARDS · REVIEW', style: Cyber.display(16)),
              for (final sport in Sport.values)
                if (fixtures
                        .where(
                          (m) =>
                              m.sport == sport &&
                              m.status == MatchStatus.upcoming,
                        )
                        .firstOrNull
                    case final source?) ...[
                  const SizedBox(height: 24),
                  Text(
                    sport.name.toUpperCase(),
                    style: Cyber.bodyFor(context, 14),
                  ),
                  const SizedBox(height: 12),
                  Text('SPORT TAB', style: Cyber.bodyFor(context, 12)),
                  const SizedBox(height: 8),
                  EditorialMatchCard(
                    match: source.copyWith(
                      kickoff: DateTime(2026, 10, 20, 0, 30),
                    ),
                    showCompetition: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  Text('TRENDS', style: Cyber.bodyFor(context, 12)),
                  const SizedBox(height: 8),
                  EditorialMatchCard(
                    match: source.copyWith(
                      kickoff: DateTime(2026, 10, 20, 0, 30),
                    ),
                    showCompetition: true,
                    onTap: () {},
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
