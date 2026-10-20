// Production-widget preview. Fixtures do not load a saved profile; the browser's
// dedicated preview origin isolates any persistence from interactive flow QA.
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_state.dart';
import 'package:card_game/config/enums.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/config/tutorial_steps.dart';
import 'package:card_game/models/cards.dart';
import 'package:card_game/models/match.dart';
import 'package:card_game/models/pitch_duel_rules.dart';
import 'package:card_game/screens/deck/deck_builder_screen.dart';
import 'package:card_game/screens/game/widgets/duel_board_phase.dart';
import 'package:card_game/screens/game/game_screen.dart';
import 'package:card_game/screens/game/widgets/final_result_phase.dart';
import 'package:card_game/screens/game/widgets/match_phases.dart';
import 'package:card_game/screens/home/home_screen.dart';
import 'package:card_game/screens/home/widgets/starter_pack_onboarding.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart';
import 'package:card_game/widgets/game_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final mode = Uri.base.queryParameters['screen'] ?? 'board';
  final tutorial = Uri.base.queryParameters['tutorial'];
  final attacking = mode != 'defense';
  final base = GameState.initial();
  final action = base.deckActions.firstWhere(
    (a) => pitchActionFitsRole(a, attacking),
  );
  final player = (attacking ? base.deckAttackers : base.deckDefenders).first;
  final power = pitchPower(
    player: player,
    action: action,
    scenario: scenarios.first,
    attacking: attacking,
    timing: 8,
  );
  final rivalAction = base.deckActions.firstWhere(
    (a) => pitchActionFitsRole(a, !attacking),
  );
  final rivalPlayer =
      (attacking ? base.deckDefenders : base.deckAttackers).first;
  final rivalPower = pitchPower(
    player: rivalPlayer,
    action: rivalAction,
    scenario: scenarios.first,
    attacking: !attacking,
    timing: 4,
  );
  final round = RoundResult(
    round: 1,
    scenario: scenarios.first,
    playerAttacking: attacking,
    attackerCard: attacking ? player : rivalPlayer,
    defenderCard: attacking ? rivalPlayer : player,
    attackAction: attacking ? action : rivalAction,
    defenseAction: attacking ? rivalAction : action,
    outcome: RoundOutcome.goal,
    attackPower: (attacking ? power : rivalPower).total.toDouble(),
    defensePower: (attacking ? rivalPower : power).total.toDouble(),
    attackBreakdown: attacking ? power : rivalPower,
    defenseBreakdown: attacking ? rivalPower : power,
  );
  final bloc = GameBloc(SecureGameStorage());
  // ignore: invalid_use_of_visible_for_testing_member
  bloc.emit(
    base.copyWith(
      loading: false,
      starterPackClaimed: true,
      ownedCardIds: [
        ...base.deckAttackers,
        ...base.deckDefenders,
        base.deckKeeper!,
      ].map((p) => p.id).toList(),
      ownedActionCardIds: base.deckActions.map((a) => a.id).toList(),
      tutorialSeen: tutorialKeys.where((key) => key != tutorial).toSet(),
      phase: mode == 'flow'
          ? MatchPhase.idle
          : mode == 'result'
          ? MatchPhase.finalResult
          : mode == 'reveal'
          ? MatchPhase.roundResult
          : mode == 'scenario'
          ? MatchPhase.scenario
          : MatchPhase.play,
      currentRound: mode == 'flow' ? 0 : 1,
      playerAttacking: attacking,
      initialAttackingChoice: attacking,
      selectedPlayerCard: mode == 'flow' ? null : player,
      selectedActionCard: mode == 'flow' ? null : action,
      currentScenario: mode == 'flow' ? null : scenarios.first,
      opponentAttackers: base.deckAttackers,
      opponentDefenders: base.deckDefenders,
      opponentActions: base.deckActions,
      opponentSelectedPlayerCard: rivalPlayer,
      opponentSelectedActionCard: rivalAction,
      opponentName: 'RIVAL XI',
      playerScore: mode == 'result' || mode == 'reveal' ? 1 : 0,
      previousProgression: base.progression,
      lastMatchXP: 15,
      roundResults: mode == 'result' || mode == 'reveal' ? [round] : [],
    ),
  );
  runApp(
    BlocProvider.value(
      value: bloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              double.tryParse(Uri.base.queryParameters['text'] ?? '') ?? 1,
            ),
            disableAnimations: Uri.base.queryParameters['motion'] == 'reduced',
          ),
          child: GameTypographyScope(child: child!),
        ),
        home: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) => switch (mode) {
            'flow' => GameTabContent(onNavigate: (_) {}),
            'cards' => GameScaffold(
              title: 'Card studio',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: [
                    for (var i = 0; i < 2; i++)
                      CyberPlayerCardTile(
                        card: base.deckAttackers[i],
                        selected: i == 1,
                        size: VisualCardSize.lg,
                        onTap: () {},
                      ),
                    CyberPlayerCardTile(
                      card: base.deckDefenders.first,
                      selected: false,
                      disabled: true,
                      disabledLabel: 'USED',
                      size: VisualCardSize.lg,
                    ),
                    for (final action in base.deckActions)
                      CyberActionCardTile(
                        card: action,
                        selected: false,
                        size: VisualCardSize.lg,
                        onTap: () {},
                      ),
                    const SizedBox(
                      width: 128,
                      height: 192,
                      child: CardBackFace(),
                    ),
                  ],
                ),
              ),
            ),
            'lobby' => HomeScreen(
              onNavigate: (_) {},
              showBottomNavigation: false,
            ),
            'deck' => DeckBuilderScreen.management(onBack: () {}),
            'meter' => Scaffold(
              backgroundColor: Cyber.bg,
              body: ShotMeterOverlay(
                power: pitchPower(
                  player: player,
                  action: action,
                  scenario: scenarios.first,
                  attacking: attacking,
                ),
                accent: Cyber.cyan,
                rivalRange: playerRivalRange(state),
                attacking: attacking,
              ),
            ),
            'pack' => PackOnboardingScreen(
              reveal: PackRevealData(
                playerCards: [
                  ...base.deckAttackers,
                  ...base.deckDefenders,
                  base.deckKeeper!,
                ],
                actionCards: base.deckActions,
                headline: 'STARTER\nPACK',
                statusLabel: 'UNLOCKED',
                ctaLabel: 'ENTER THE GAME',
                summaryLabel: '11 CARDS ADDED TO YOUR COLLECTION',
                xpGained: 20,
                levelsGained: const [],
                groupActionCards: true,
                maxAnimatedPlayerCards: 5,
              ),
            ),
            'result' => FinalResultPhase(state: state, onNavigate: (_) {}),
            _ => DuelBoardPhase(state: state, onQuit: () {}),
          },
        ),
      ),
    ),
  );
}
