import 'package:card_game/blocs/final_over/final_over_cubit.dart';
import 'package:card_game/blocs/friends/friends_cubit.dart';
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_event.dart';
import 'package:card_game/blocs/picks/picks_cubit.dart';
import 'package:card_game/blocs/prediction/prediction_cubit.dart';
import 'package:card_game/blocs/quiz/quiz_cubit.dart';
import 'package:card_game/blocs/tennis/tennis_cubit.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/data/guess_player_data.dart';
import 'package:card_game/models/cards.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/screens/basketball/basketball_hub.dart';
import 'package:card_game/screens/final_over/final_over_hub.dart';
import 'package:card_game/screens/football_bingo/football_bingo_hub.dart';
import 'package:card_game/screens/football_chess/football_chess_hub.dart';
import 'package:card_game/screens/friends/friends_arena_screen.dart';
import 'package:card_game/screens/friends/referral_screen.dart';
import 'package:card_game/screens/game/game_screen.dart';
import 'package:card_game/screens/grand_prix/grand_prix_hub.dart';
import 'package:card_game/screens/guess_driver/guess_driver_hub.dart';
import 'package:card_game/screens/guess_player/guess_player_hub.dart';
import 'package:card_game/screens/guess_winner/guess_winner_hub.dart';
import 'package:card_game/screens/how_to_play/how_to_play_hub_screen.dart';
import 'package:card_game/screens/leaderboard/leaderboard_screen.dart';
import 'package:card_game/screens/onboarding/profile_setup_screen.dart';
import 'package:card_game/screens/predictions/match_detail_screen.dart';
import 'package:card_game/screens/predictions/prediction_home_screen.dart';
import 'package:card_game/screens/profile/profile_screen.dart';
import 'package:card_game/screens/profile/talk_to_statoz_screen.dart';
import 'package:card_game/screens/quiz/quiz_hub.dart';
import 'package:card_game/screens/shootout/shootout_hub.dart';
import 'package:card_game/screens/shop/shop_screen.dart';
import 'package:card_game/screens/tennis/tennis_hub.dart';
import 'package:card_game/services/pick_repository.dart';
import 'package:card_game/services/basketball_match_package_service.dart';
import 'package:card_game/services/cricket_match_package_service.dart';
import 'package:card_game/services/f1_race_package_service.dart';
import 'package:card_game/services/football_match_package_service.dart';
import 'package:card_game/services/prediction_repository.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/utils/sound_effects.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart' show GameTypographyScope;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: invalid_use_of_visible_for_testing_member
  AudioController.debugUseBackend(_SilentAudioBackend());
  AudioController.instance.muted.value = true;
  await _seedProfile();
  final id =
      Uri.base.queryParameters['scenario'] ?? 'onboarding.profile-setup.avatar';
  final catalogMatches = await _loadCatalogMatches();
  runApp(_catalogApp(_scenario(id, catalogMatches)));
}

Widget _catalogApp(Widget child) => MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => GameBloc(SecureGameStorage())..add(GameLoaded()),
    ),
    BlocProvider(
      create: (_) => PredictionCubit(
        MockPredictionRepository(),
        SecureGameStorage(),
        now: () => DateTime.utc(2026, 9, 7, 12),
      )..load(),
    ),
    BlocProvider(
      create: (_) =>
          PicksCubit(MockPickRepository(), SecureGameStorage())..load(),
    ),
    BlocProvider(create: (_) => FriendsCubit(SecureGameStorage())..load()),
    BlocProvider(create: (_) => QuizCubit(SecureGameStorage())..load()),
    BlocProvider(create: (_) => TennisCubit(SecureGameStorage())..load()),
    BlocProvider(create: (_) => FinalOverCubit(SecureGameStorage())..load()),
  ],
  child: MaterialApp(
    title: 'StatOz Catalog',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: Uri.base.queryParameters['scenario']?.startsWith('games.') == true &&
            Uri.base.queryParameters['scenario']?.startsWith('games.games-hub.') != true
        ? GameTypographyScope(child: child)
        : child,
  ),
);

Widget _scenario(String id, Map<Sport, SportMatch> catalogMatches) {
  if (id == 'onboarding.profile-setup.intro' ||
      id == 'onboarding.profile-setup.avatar') {
    return ProfileSetupScreen(onComplete: (_) {});
  }
  if (id.startsWith('sports.match-hub.')) {
    const lanes = [
      'trending',
      'football',
      'cricket',
      'basketball',
      'tennis',
      'motorsport',
    ];
    return _prediction(
      activeTab: 0,
      sportTab: lanes.indexOf(id.split('.').last).clamp(0, 5),
    );
  }
  if (id == 'picks.market-hub.browse') {
    return _prediction(activeTab: 1, sportTab: 0);
  }
  if (id.startsWith('match-tabs.')) {
    final parts = id.split('.');
    const tabs = ['predict', 'picks', 'tops', 'stats'];
    final sport = Sport.values.firstWhere(
      (candidate) => candidate.name == parts[1],
    );
    final tab = parts[2].startsWith('stats') ? 3 : tabs.indexOf(parts[2]);
    return MatchDetailScreen(
      match: catalogMatches[sport]!,
      initialTab: tab,
      refreshLiveScore: false,
    );
  }
  if (id.startsWith('games.games-hub.')) {
    const lanes = [
      'trending',
      'football',
      'cricket',
      'basketball',
      'tennis',
      'motorsport',
    ];
    return _prediction(
      activeTab: 2,
      sportTab: lanes.indexOf(id.split('.').last).clamp(0, 5),
    );
  }
  if (id.startsWith('shop.catalogue.')) {
    const tabs = [
      'avatars',
      'frames',
      'banners',
      'kits',
      'coins',
      'packs',
      'cards',
    ];
    return ShopScreen(
      onNavigate: (_) {},
      initialTab: tabs.indexOf(id.split('.').last).clamp(0, 6),
    );
  }
  return switch (id) {
    'games.pitch-duel.entry' => GameTabContent(onNavigate: (_) {}),
    'games.penalty-shootout.entry' => ShootoutTabContent(onNavigate: (_) {}),
    'games.football-chess.entry' => FootballChessTabContent(onNavigate: (_) {}),
    'games.football-quiz.entry' => QuizTabContent(
      sport: Sport.football,
      onNavigate: (_) {},
    ),
    'games.football-bingo.entry' => FootballBingoTabContent(onNavigate: (_) {}),
    'games.football-guess-player.entry' => GuessPlayerTabContent(
      sport: Sport.football,
      timelines: footballGuessTimelines,
      allPlayers: footballPlayerCards,
      onNavigate: (_) {},
    ),
    'games.final-over.entry' => FinalOverHub(onExit: () {}),
    'games.cricket-quiz.entry' => QuizTabContent(
      sport: Sport.cricket,
      onNavigate: (_) {},
    ),
    'games.cricket-guess-player.entry' => GuessPlayerTabContent(
      sport: Sport.cricket,
      timelines: cricketGuessTimelines,
      allPlayers: cricketPlayerCards,
      onNavigate: (_) {},
    ),
    'games.hoop-duel.entry' => BasketballTabContent(onNavigate: (_) {}),
    'games.basketball-quiz.entry' => QuizTabContent(
      sport: Sport.basketball,
      onNavigate: (_) {},
    ),
    'games.basketball-guess-player.entry' => GuessPlayerTabContent(
      sport: Sport.basketball,
      timelines: basketballGuessTimelines,
      allPlayers: basketballPlayerCards,
      onNavigate: (_) {},
    ),
    'games.grand-prix-dash.entry' => GrandPrixTabContent(onNavigate: (_) {}),
    'games.motorsport-quiz.entry' => QuizTabContent(
      sport: Sport.motorsport,
      onNavigate: (_) {},
    ),
    'games.guess-driver.entry' => GuessDriverTabContent(onNavigate: (_) {}),
    'games.tennis-rally.entry' => TennisRallyHub(onExit: () {}),
    'games.tennis-quiz.entry' => QuizTabContent(
      sport: Sport.tennis,
      onNavigate: (_) {},
    ),
    'games.guess-winner.entry' => GuessWinnerTabContent(onNavigate: (_) {}),
    'leaderboards.top.rankings' => LeaderboardScreen(onNavigate: (_) {}),
    'profile.player-dossier.loaded' => ProfileScreen(
      onNavigate: (_) {},
      onLogout: () async {},
      onChallenge: (_, _) {},
      onOpenSportGames: (_) {},
    ),
    'social.friends-arena.loaded' => FriendsArenaScreen(onChallenge: (_, _) {}),
    'social.referrals.ready' => const ReferralScreen(),
    'help.tutorials.catalogue' => HowToPlayHubScreen(onNavigate: (_) {}),
    'help.support.ready' => TalkToStatozScreen(onNavigate: (_) {}),
    _ => const Scaffold(body: Center(child: Text('UNKNOWN CATALOG SCENARIO'))),
  };
}

Widget _prediction({required int activeTab, required int sportTab}) =>
    PredictionHomeScreen(
      activeTab: activeTab,
      onTabChanged: (_) {},
      activeMatchSportTab: sportTab,
      onMatchSportTabChanged: (_) {},
      activeGamesSportTab: sportTab,
      onGamesSportTabChanged: (_) {},
      onNavigate: (_) {},
      onOpenMatch: (_) {},
      onOpenMarket: (_) {},
      onOpenLeague: (_) {},
      onOpenLeagueGames: (_) {},
      onOpenGame: () {},
      onOpenShootout: () {},
      onOpenQuiz: (_) {},
      onOpenFootballBingo: () {},
      onOpenFootballChess: () {},
      onOpenGuessPlayer: () {},
      onOpenBasketballGuessPlayer: () {},
      onOpenCricketGuessPlayer: () {},
      onOpenGrandPrix: () {},
      onOpenF1GuessDriver: () {},
      onOpenTennisGuessWinner: () {},
      onOpenBasketball: () {},
      onOpenFinalOver: () {},
      onOpenTennisRally: () {},
    );

/// Loads one real, deterministic fixture per sport before the app is mounted.
///
/// The catalog routes each match-detail tab through its production widget. This
/// keeps PREDICT, PICKS, TOPS, and STATS evidence tied to the same fixture and
/// avoids a synthetic screen only used for screenshots.
Future<Map<Sport, SportMatch>> _loadCatalogMatches() async {
  final repository = MockPredictionRepository(
    now: () => DateTime.utc(2026, 9, 7, 12),
  );
  final motorsportFixtures = await F1RacePackageService.bundledFixtures();
  final tennisFixtures = await repository.fixtures(sport: Sport.tennis);
  if (tennisFixtures.isEmpty) {
    throw StateError('No deterministic catalog fixture for tennis.');
  }
  return {
    Sport.football: await const FootballMatchPackageService().loadBundled(),
    Sport.cricket: await const CricketMatchPackageService().loadBundled(),
    Sport.basketball: await const BasketballMatchPackageService().loadBundled(),
    Sport.motorsport: motorsportFixtures.firstWhere(
      (match) => match.home.name.toLowerCase().contains('italian grand prix'),
      orElse: () =>
          throw StateError('Italian Grand Prix catalog fixture absent.'),
    ),
    Sport.tennis: tennisFixtures.first,
  };
}

Future<void> _seedProfile() async {
  final storage = SecureGameStorage();
  await storage.saveSelectedAvatarId('avatar_1');
  await storage.saveSelectedProfileBannerId('banner_1');
  await storage.savePrimarySportName('football');
  await storage.saveOnboardingComplete(true);
  await storage.saveOnboardingRewardStatus(OnboardingRewardStatus.seen);
  await storage.saveStarterPackClaimed();
  await storage.saveCricketStarterPackClaimed();
  await storage.saveBasketballStarterPackClaimed();
  await storage.saveTennisStarterPackClaimed();
  await storage.saveGrandPrixStarterPackClaimed();
}

class _SilentAudioBackend implements AudioPlaybackBackend {
  @override
  Future<void> dispose() async {}
  @override
  Future<void> playEffect(
    String assetPath, {
    required AudioBus bus,
    required double volume,
  }) async {}
  @override
  Future<void> preload(List<String> assetPaths) async {}
  @override
  Future<void> setAmbienceVolume(double volume) async {}
  @override
  Future<void> setDynamicLoop({
    required double volume,
    required double rate,
  }) async {}
  @override
  Future<void> startAmbience(
    String assetPath, {
    required double volume,
  }) async {}
  @override
  Future<void> startDynamicLoop(
    String assetPath, {
    required double volume,
  }) async {}
  @override
  Future<void> stopAll() async {}
  @override
  Future<void> stopAmbience() async {}
  @override
  Future<void> stopDynamicLoop() async {}
}
