import 'dart:convert';
import 'dart:io';

import 'package:card_game/blocs/final_over/final_over_cubit.dart';
import 'package:card_game/blocs/friends/friends_cubit.dart';
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/picks/picks_cubit.dart';
import 'package:card_game/blocs/prediction/prediction_cubit.dart';
import 'package:card_game/blocs/quiz/quiz_cubit.dart';
import 'package:card_game/blocs/tennis/tennis_cubit.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart' show GameTypographyScope;
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
import 'package:card_game/services/basketball_match_package_service.dart';
import 'package:card_game/services/cricket_match_package_service.dart';
import 'package:card_game/services/f1_race_package_service.dart';
import 'package:card_game/services/football_match_package_service.dart';
import 'package:card_game/services/pick_repository.dart';
import 'package:card_game/services/prediction_repository.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/utils/sound_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _viewport = Size(393, 852);
const _surfaceKey = ValueKey<String>('statoz-catalog-surface');
final _scenarios = <_Scenario>[];
final _findings = <_Finding>[];
var _order = 0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenFileComparator = LocalFileComparator(
    Uri.file('${Directory.current.path}/'),
  );

  setUpAll(() async {
    await (FontLoader('Orbitron')..addFont(
          rootBundle.load('assets/fonts/Orbitron-VariableFont_wght.ttf'),
        ))
        .load();
    await (FontLoader('Space Grotesk')..addFont(
          rootBundle.load('assets/fonts/SpaceGrotesk-VariableFont_wght.ttf'),
        ))
        .load();
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    AudioController.debugUseBackend(_NoopAudioBackend());
    AudioController.instance.muted.value = true;
    await _seedProfile();
  });

  tearDownAll(_writeOutputs);

  testWidgets(
    'captures deterministic StatOz screen catalog',
    (tester) async {
      tester.view.physicalSize = _viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _show(tester, ProfileSetupScreen(onComplete: (_) {}));
      await _shot(
        tester,
        'onboarding',
        'profile-setup',
        'intro',
        'Fresh install',
        'Launch StatOz',
        'The welcome reveal introduces first-launch setup',
        tags: const ['first-launch', 'gratification', 'keyframe-setup'],
      );
      await tester.pump(const Duration(seconds: 2));
      await _tap(tester, 'NEXT');
      await _shot(
        tester,
        'onboarding',
        'profile-setup',
        'banner',
        'Avatar selected',
        'Continue',
        'Banner selection is presented',
        tags: const ['first-launch', 'selection'],
      );
      await _tap(tester, 'NEXT');
      await _shot(
        tester,
        'onboarding',
        'profile-setup',
        'sports',
        'Identity selected',
        'Continue',
        'Sports are picked first, and more than one can be followed',
        tags: const ['first-launch', 'selection'],
      );
      await _tap(tester, 'NEXT');
      await _shot(
        tester,
        'onboarding',
        'profile-setup',
        'following',
        'Sports selected',
        'Continue',
        'Each followed sport gets its own leagues-and-clubs page',
        tags: const ['first-launch', 'optional'],
      );

      const lanes = <String>[
        'trending',
        'football',
        'cricket',
        'basketball',
        'tennis',
        'motorsport',
      ];
      for (var index = 0; index < lanes.length; index++) {
        await _show(tester, _predictionHome(activeTab: 0, sportTab: index));
        await _shot(
          tester,
          'sports',
          'match-hub',
          lanes[index],
          'Seeded fixtures loaded',
          'Open ${lanes[index]} MATCH lane',
          'Fixtures, leagues and match actions are visible',
          tags: const ['match', 'seeded-data'],
        );
      }
      await _show(tester, _predictionHome(activeTab: 1, sportTab: 0));
      await _shot(
        tester,
        'picks',
        'market-hub',
        'browse',
        'Seeded markets loaded',
        'Open PICK',
        'Markets are visible',
        tags: const ['pick', 'seeded-data'],
      );
      for (var index = 0; index < lanes.length; index++) {
        await _show(tester, _predictionHome(activeTab: 2, sportTab: index));
        await _shot(
          tester,
          'games',
          'games-hub',
          lanes[index],
          'Starter packs claimed',
          'Open ${lanes[index]} GAMES lane',
          'All shipped game entries for the lane are visible',
          tags: const ['games', 'seeded-data'],
        );
      }

      final games = <({String id, String sport, Widget widget})>[
        (
          id: 'pitch-duel',
          sport: 'football',
          widget: GameTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'penalty-shootout',
          sport: 'football',
          widget: ShootoutTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'football-chess',
          sport: 'football',
          widget: FootballChessTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'football-quiz',
          sport: 'football',
          widget: QuizTabContent(sport: Sport.football, onNavigate: (_) {}),
        ),
        (
          id: 'football-bingo',
          sport: 'football',
          widget: FootballBingoTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'football-guess-player',
          sport: 'football',
          widget: GuessPlayerTabContent(
            sport: Sport.football,
            timelines: footballGuessTimelines,
            allPlayers: footballPlayerCards,
            onNavigate: (_) {},
          ),
        ),
        (
          id: 'final-over',
          sport: 'cricket',
          widget: FinalOverHub(onExit: () {}),
        ),
        (
          id: 'cricket-quiz',
          sport: 'cricket',
          widget: QuizTabContent(sport: Sport.cricket, onNavigate: (_) {}),
        ),
        (
          id: 'cricket-guess-player',
          sport: 'cricket',
          widget: GuessPlayerTabContent(
            sport: Sport.cricket,
            timelines: cricketGuessTimelines,
            allPlayers: cricketPlayerCards,
            onNavigate: (_) {},
          ),
        ),
        (
          id: 'hoop-duel',
          sport: 'basketball',
          widget: BasketballTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'basketball-quiz',
          sport: 'basketball',
          widget: QuizTabContent(sport: Sport.basketball, onNavigate: (_) {}),
        ),
        (
          id: 'basketball-guess-player',
          sport: 'basketball',
          widget: GuessPlayerTabContent(
            sport: Sport.basketball,
            timelines: basketballGuessTimelines,
            allPlayers: basketballPlayerCards,
            onNavigate: (_) {},
          ),
        ),
        (
          id: 'grand-prix-dash',
          sport: 'motorsport',
          widget: GrandPrixTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'motorsport-quiz',
          sport: 'motorsport',
          widget: QuizTabContent(sport: Sport.motorsport, onNavigate: (_) {}),
        ),
        (
          id: 'guess-driver',
          sport: 'motorsport',
          widget: GuessDriverTabContent(onNavigate: (_) {}),
        ),
        (
          id: 'tennis-rally',
          sport: 'tennis',
          widget: TennisRallyHub(onExit: () {}),
        ),
        (
          id: 'tennis-quiz',
          sport: 'tennis',
          widget: QuizTabContent(sport: Sport.tennis, onNavigate: (_) {}),
        ),
        (
          id: 'guess-winner',
          sport: 'tennis',
          widget: GuessWinnerTabContent(onNavigate: (_) {}),
        ),
      ];
      for (final game in games) {
        await _show(tester, game.widget, gameTypography: true);
        await _shot(
          tester,
          'games',
          game.id,
          'entry',
          '${game.sport} starter gate satisfied',
          'Launch ${game.id}',
          'The mode presents its objective and primary play action',
          tags: ['game-entry', game.sport, 'loaded'],
        );
      }

      const shopStates = [
        'avatars',
        'frames',
        'banners',
        'kits',
        'coins',
        'packs',
        'cards',
      ];
      for (var index = 0; index < shopStates.length; index++) {
        await _show(tester, ShopScreen(initialTab: index, onNavigate: (_) {}));
        await _shot(
          tester,
          'shop',
          'catalogue',
          shopStates[index],
          'Seeded wallet and ownership',
          'Open ${shopStates[index]} tab',
          'Ownership, price and acquisition state are visible',
          tags: const ['shop', 'economy'],
        );
      }
      await _show(tester, LeaderboardScreen(onNavigate: (_) {}));
      await _shot(
        tester,
        'leaderboards',
        'top',
        'rankings',
        'Seeded rival roster',
        'Open TOP',
        'Podium and player rank are visible',
        tags: const ['leaderboard', 'social'],
      );
      await _show(
        tester,
        ProfileScreen(
          onNavigate: (_) {},
          onLogout: () async {},
          onChallenge: (_, _) {},
          onOpenSportGames: (_) {},
        ),
      );
      await _shot(
        tester,
        'profile',
        'player-dossier',
        'loaded',
        'Completed profile',
        'Open PROFILE',
        'Identity and progression are visible',
        tags: const ['profile', 'progression'],
      );
      await _show(tester, FriendsArenaScreen(onChallenge: (_, _) {}));
      await _shot(
        tester,
        'social',
        'friends-arena',
        'loaded',
        'Seeded friends',
        'Open friends',
        'Friend and rival actions are visible',
        tags: const ['friends', 'rivals'],
      );
      await _show(tester, const ReferralScreen());
      await _shot(
        tester,
        'social',
        'referrals',
        'ready',
        'Profile available',
        'Open referrals',
        'Referral rewards and share action are visible',
        tags: const ['referral', 'reward'],
      );
      await _show(tester, HowToPlayHubScreen(onNavigate: (_) {}));
      await _shot(
        tester,
        'help',
        'tutorials',
        'catalogue',
        'Any player',
        'Open tutorials',
        'Game guides are grouped by mode',
        tags: const ['tutorial', 'support'],
      );
      await _show(tester, TalkToStatozScreen(onNavigate: (_) {}));
      await _shot(
        tester,
        'help',
        'support',
        'ready',
        'Any player',
        'Open support',
        'Support topics and contact action are visible',
        tags: const ['support'],
      );

      final catalogMatches = await _catalogMatches();
      const matchSports = [
        Sport.football,
        Sport.cricket,
        Sport.basketball,
        Sport.motorsport,
        Sport.tennis,
      ];
      const matchTabs = ['predict', 'picks', 'tops', 'stats'];
      for (final sport in matchSports) {
        for (var tab = 0; tab < matchTabs.length; tab++) {
          await _show(
            tester,
            MatchDetailScreen(
              match: catalogMatches[sport]!,
              initialTab: tab,
              refreshLiveScore: false,
            ),
          );
          await _shot(
            tester,
            'match-tabs',
            sport.name,
            matchTabs[tab],
            'Seeded ${sport.name} fixture loaded',
            'Open the fixture and select ${matchTabs[tab].toUpperCase()}',
            'The ${matchTabs[tab].toUpperCase()} match-detail tab is visible for ${sport.name}',
            tags: ['match-detail', sport.name, matchTabs[tab], 'seeded-data'],
          );
        }
      }
      for (final sport in matchSports) {
        await _show(
          tester,
          MatchDetailScreen(
            match: catalogMatches[sport]!,
            initialTab: 3,
            refreshLiveScore: false,
          ),
        );
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -4000));
        await tester.pumpAndSettle();
        await _shot(
          tester,
          'match-tabs',
          sport.name,
          'stats-lower',
          'Seeded ${sport.name} fixture loaded',
          'Select STATS and scroll to the terminal screen position',
          'The lower STATS content is visible for ${sport.name}',
          tags: [
            'match-detail',
            sport.name,
            'stats-lower',
            'seeded-data',
            'scroll-continuation',
          ],
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

Widget _predictionHome({required int activeTab, required int sportTab}) =>
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

Future<void> _show(
  WidgetTester tester,
  Widget child, {
  bool gameTypography = false,
}) async {
  debugPrint('CATALOG show ${child.runtimeType}');
  await tester.pumpWidget(
    _providers(
      MaterialApp(
        title: 'StatOz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: RepaintBoundary(
          key: _surfaceKey,
          child: gameTypography ? GameTypographyScope(child: child) : child,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  debugPrint('CATALOG shown ${child.runtimeType}');
  final error = tester.takeException();
  if (error != null) {
    _findings.add(
      _Finding(
        'QA-${(_findings.length + 1).toString().padLeft(3, '0')}',
        'runtime',
        'pending',
        error.toString(),
      ),
    );
  }
}

Widget _providers(Widget child) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => GameBloc(SecureGameStorage())),
    BlocProvider(
      create: (_) => PredictionCubit(
        MockPredictionRepository(),
        SecureGameStorage(),
        now: () => DateTime.utc(2026, 9, 7, 12),
      ),
    ),
    BlocProvider(
      create: (_) => PicksCubit(MockPickRepository(), SecureGameStorage()),
    ),
    BlocProvider(create: (_) => FriendsCubit(SecureGameStorage())),
    BlocProvider(create: (_) => QuizCubit(SecureGameStorage())),
    BlocProvider(create: (_) => TennisCubit(SecureGameStorage())),
    BlocProvider(create: (_) => FinalOverCubit(SecureGameStorage())),
  ],
  child: child,
);

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _shot(
  WidgetTester tester,
  String feature,
  String surface,
  String state,
  String preconditions,
  String action,
  String expected, {
  required List<String> tags,
}) async {
  final id = '$feature.$surface.$state';
  debugPrint('CATALOG shot $id');
  final order = ++_order;
  final filename =
      '${order.toString().padLeft(3, '0')}_${_slug(feature)}__${_slug(surface)}__${_slug(state)}.png';
  final directory = Directory('output/screenshots/statoz');
  await tester.runAsync(() => directory.create(recursive: true));
  await expectLater(
    find.byKey(_surfaceKey),
    matchesGoldenFile('${directory.path.replaceAll('\\', '/')}/$filename'),
    reason: id,
  );
  debugPrint('CATALOG wrote $filename');
  _scenarios.add(
    _Scenario(
      order,
      id,
      feature,
      surface,
      state,
      preconditions,
      action,
      expected,
      'deterministic-seed',
      tags,
      'settled',
      '${directory.path.replaceAll('\\', '/')}/$filename',
      order == 1 ? const <String>[] : <String>[_scenarios.last.id],
      const <String>[],
    ),
  );
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

Future<Map<Sport, SportMatch>> _catalogMatches() async {
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

String _slug(String value) => value
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

Future<void> _writeOutputs() async {
  final directory = Directory('output/screenshots/statoz');
  await directory.create(recursive: true);
  final manifest = {
    'catalog': 'StatOz Complete Screen and State Catalog',
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'viewport': {'width': 393, 'height': 852, 'devicePixelRatio': 1},
    'scenarioCount': _scenarios.length,
    'findingCount': _findings.length,
    'scenarios': _scenarios.map((entry) => entry.toJson()).toList(),
    'nonCapturable': _nonCapturable,
  };
  await File(
    '${directory.path}/manifest.json',
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(manifest));
  await File('${directory.path}/manifest.csv').writeAsString(
    [
      'order,id,feature,surface,state,preconditions,action,expected,data_source,tags,animation_keyframe,screenshot_path,flow_from,flow_to',
      ..._scenarios.map((entry) => entry.toCsv()),
    ].join('\n'),
  );
  await File('${directory.path}/qa_findings.csv').writeAsString(
    [
      'id,severity,scenario_id,summary',
      ..._findings.map((entry) => entry.toCsv()),
    ].join('\n'),
  );
}

const _nonCapturable = [
  {
    'id': 'global.offline.live-service',
    'status': 'BUILT',
    'reason':
        'Requires a controllable service outage; indexed for manual QA without fabricating a frame.',
  },
  {
    'id': 'global.level-up.celebration',
    'status': 'BUILT',
    'reason':
        'Timing-dependent global overlay; existing golden tests remain authoritative.',
  },
  {
    'id': 'shop.purchase.platform-payment',
    'status': 'PROTOTYPE',
    'reason': 'No production payment provider is connected.',
  },
  {
    'id': 'product.planned-and-deprecated',
    'status': 'PLANNED/DEPRECATED',
    'reason':
        'Indexed from product documentation and intentionally not visualized.',
  },
];

String _csv(Object? value) =>
    '"${(value ?? '').toString().replaceAll('"', '""')}"';

class _Scenario {
  const _Scenario(
    this.order,
    this.id,
    this.feature,
    this.surface,
    this.state,
    this.preconditions,
    this.action,
    this.expected,
    this.dataSource,
    this.tags,
    this.animationKeyframe,
    this.screenshotPath,
    this.flowFrom,
    this.flowTo,
  );
  final int order;
  final String id;
  final String feature;
  final String surface;
  final String state;
  final String preconditions;
  final String action;
  final String expected;
  final String dataSource;
  final List<String> tags;
  final String animationKeyframe;
  final String screenshotPath;
  final List<String> flowFrom;
  final List<String> flowTo;
  Map<String, Object?> toJson() => {
    'order': order,
    'id': id,
    'feature': feature,
    'surface': surface,
    'state': state,
    'preconditions': preconditions,
    'action': action,
    'expected': expected,
    'dataSource': dataSource,
    'tags': tags,
    'animationKeyframe': animationKeyframe,
    'screenshotPath': screenshotPath,
    'flowFrom': flowFrom,
    'flowTo': flowTo,
  };
  String toCsv() => [
    order,
    id,
    feature,
    surface,
    state,
    preconditions,
    action,
    expected,
    dataSource,
    tags.join('|'),
    animationKeyframe,
    screenshotPath,
    flowFrom.join('|'),
    flowTo.join('|'),
  ].map(_csv).join(',');
}

class _Finding {
  const _Finding(this.id, this.severity, this.scenarioId, this.summary);
  final String id;
  final String severity;
  final String scenarioId;
  final String summary;
  String toCsv() => [id, severity, scenarioId, summary].map(_csv).join(',');
}

class _NoopAudioBackend implements AudioPlaybackBackend {
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
