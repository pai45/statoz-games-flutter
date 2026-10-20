// Isolated UI gallery. All purchases and balances are in-memory fixtures.
// This development-only fixture deliberately seeds state without storage events.
// ignore_for_file: invalid_use_of_visible_for_testing_member
// flutter run -d chrome -t tool/cyber_kit_preview.dart
import 'package:card_game/blocs/game/game_bloc.dart';
import 'package:card_game/blocs/game/game_event.dart';
import 'package:card_game/blocs/game/game_state.dart';
import 'package:card_game/config/game_ladder.dart';
import 'package:card_game/config/sport_modules.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/models/unlock_progress.dart';
import 'package:card_game/screens/predictions/widgets/unlock_sheets.dart';
import 'package:card_game/services/secure_storage_service.dart';
import 'package:card_game/widgets/cyber/cyber_widgets.dart';
import 'package:card_game/widgets/unlock_celebration_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _FixtureBloc extends GameBloc {
  _FixtureBloc(Sport sport, int balance) : super(SecureGameStorage()) {
    emit(
      GameState.initial().copyWith(
        loading: false,
        coins: balance,
        unlocks: UnlockProgress.fresh(
          sport == Sport.football ? Sport.cricket : Sport.football,
        ),
      ),
    );
  }

  @override
  void add(GameEvent event) {
    if (event is SportUnlockPurchased &&
        state.coins >= sportUnlockCostOz &&
        !state.unlocks.isSportUnlocked(event.sport)) {
      emit(
        state.copyWith(
          coins: state.coins - sportUnlockCostOz,
          unlocks: state.unlocks.unlockSport(event.sport),
        ),
      );
    } else if (event is UnlockRevealConsumed) {
      emit(state.copyWith(unlocks: state.unlocks.consumeReveal()));
    }
  }
}

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.darkTheme,
    home: const _Gallery(),
  ),
);

class _Gallery extends StatefulWidget {
  const _Gallery();
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  Sport _sport = Sport.cricket;
  int _balance = 80;
  bool _components = false;
  bool _large = false;
  bool _short = false;
  bool _reduced = false;
  int _revision = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('STATOZ / CYBER UI KIT', style: Cyber.display(18)),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _components = !_components),
                child: Text(
                  _components ? 'Show unlock sheets' : 'Show components',
                ),
              ),
              for (final sport in Sport.values)
                TextButton(
                  onPressed: () => setState(() {
                    _sport = sport;
                    _components = false;
                  }),
                  child: Text(sportModuleFor(sport).label),
                ),
              for (final coins in [0, 49, 50, 80])
                TextButton(
                  onPressed: () => setState(() => _balance = coins),
                  child: Text('$coins OZ'),
                ),
              TextButton(
                onPressed: () => setState(() => _large = !_large),
                child: Text(_large ? '320px / 1.4x' : '393px / 1x'),
              ),
              TextButton(
                onPressed: () => setState(() => _short = !_short),
                child: Text(_short ? 'Short height' : 'Full height'),
              ),
              TextButton(
                onPressed: () => setState(() => _reduced = !_reduced),
                child: Text(_reduced ? 'Reduced motion' : 'Motion on'),
              ),
              TextButton(
                onPressed: () => setState(() => _revision++),
                child: const Text('Reset'),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: _large ? 320 : 393,
                height: _short ? 520 : 852,
                child: LayoutBuilder(
                  builder: (context, constraints) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      textScaler: TextScaler.linear(_large ? 1.4 : 1),
                      disableAnimations: _reduced,
                    ),
                    child: _components
                        ? const _Components()
                        : BlocProvider<GameBloc>(
                            key: ValueKey(
                              '$_sport-$_balance-$_large-$_short-$_reduced-$_revision',
                            ),
                            create: (_) => _FixtureBloc(_sport, _balance),
                            child: Navigator(
                              onGenerateRoute: (_) => MaterialPageRoute<void>(
                                builder: (_) => _SheetStage(sport: _sport),
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

class _SheetStage extends StatefulWidget {
  const _SheetStage({required this.sport});
  final Sport sport;
  @override
  State<_SheetStage> createState() => _SheetStageState();
}

class _SheetStageState extends State<_SheetStage> {
  String _result = 'Preview only · no career storage';
  @override
  void initState() {
    super.initState();
    UnlockRevealGate.instance.hubVisible.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _open();
    });
  }

  Future<void> _open() async {
    final purchased = await showSportUnlockSheet(context, widget.sport);
    if (mounted) {
      setState(
        () => _result = purchased
            ? 'SPORT UNLOCKED · PURCHASE SIMULATED'
            : 'SHEET DISMISSED',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_result, style: Cyber.body(14)),
                const SizedBox(height: 24),
                CyberActionButton(label: 'OPEN UNLOCK SHEET', onPressed: _open),
              ],
            ),
          ),
        ),
        const Positioned.fill(child: UnlockCelebrationHost()),
      ],
    ),
  );
}

class _Components extends StatefulWidget {
  const _Components();
  @override
  State<_Components> createState() => _ComponentsState();
}

class _ComponentsState extends State<_Components> {
  int _taps = 0;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CyberKitSection(label: 'ACTION CONTROLS', count: '03'),
        const SizedBox(height: 16),
        Text(
          'Tap, hold, hover or Tab to inspect feedback. $_taps activations.',
          style: Cyber.body(13),
        ),
        const SizedBox(height: 16),
        CyberActionButton(
          label: 'UNLOCK · 50 OZ',
          onPressed: () => setState(() => _taps++),
        ),
        const SizedBox(height: 12),
        CyberActionButton(
          label: 'VIEW QUESTS',
          variant: CyberActionVariant.secondary,
          onPressed: () => setState(() => _taps++),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: CyberActionButton(
            label: 'Close preview',
            icon: Icons.close,
            variant: CyberActionVariant.icon,
            onPressed: () => setState(() => _taps++),
          ),
        ),
        const SizedBox(height: 12),
        for (final variant in CyberActionVariant.values) ...[
          CyberActionButton(
            label: 'DISABLED ACTION',
            variant: variant,
            onPressed: null,
          ),
          const SizedBox(height: 12),
          if (variant != CyberActionVariant.icon) ...[
            CyberActionButton(
              label: 'UNLOCK',
              variant: variant,
              loading: true,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
          ],
        ],
        const CyberKitSection(label: 'IDENTITY & STATUS'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final sport in Sport.values)
              CyberSportEmblem(
                icon: sportModuleFor(sport).icon,
                accent: sportModuleFor(sport).accent,
              ),
            const CyberStatusBadge(label: 'OPENS ON UNLOCK'),
            const CyberStatusBadge(
              label: 'LOCKED',
              tone: CyberStatusTone.locked,
            ),
            const CyberStatusBadge(
              label: '+40 XP',
              tone: CyberStatusTone.reward,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const CyberKitSection(label: 'PROGRESSION', count: '03'),
        const SizedBox(height: 16),
        for (var i = 0; i < sportGameLadder[Sport.cricket]!.length; i++)
          CyberProgressionEntry(
            index: i + 1,
            title: sportGameLadder[Sport.cricket]![i].title,
            icon: sportGameLadder[Sport.cricket]![i].icon,
            featured: i == 0,
            last: i == 2,
            detail: i == 0
                ? 'Your first game.'
                : 'AFTER ${sportGameLadder[Sport.cricket]![i - 1].title}',
          ),
      ],
    ),
  );
}
