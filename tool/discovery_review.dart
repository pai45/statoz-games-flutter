// Local visual-review entry point; never used by the production application.
import 'package:card_game/config/game_ladder.dart';
import 'package:card_game/config/theme.dart';
import 'package:card_game/widgets/cyber/cyber_game_launch_card.dart';
import 'package:card_game/widgets/cyber/game_discovery.g.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(theme: AppTheme.darkTheme, home: const DiscoveryReview()));

class DiscoveryReview extends StatefulWidget {
  const DiscoveryReview({super.key});
  @override
  State<DiscoveryReview> createState() => _DiscoveryReviewState();
}

class _DiscoveryReviewState extends State<DiscoveryReview> {
  bool _still = true;
  @override
  Widget build(BuildContext context) {
    final scenes = gameDiscoveryData['games'] as Map<String, dynamic>;
    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: Text('STATOZ / DISCOVERY REVIEW', style: Cyber.display(20))),
        Text('STILL', style: Cyber.bodyFor(context, 12)),
        Switch(value: _still, onChanged: (value) => setState(() => _still = value)),
      ])),
      Expanded(child: SingleChildScrollView(child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth < 600 ? (constraints.maxWidth - 44) / 2 : 210.0;
        return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final sport in ['football', 'cricket', 'basketball', 'motorsport', 'tennis']) ...[
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(sport.toUpperCase(), style: Cyber.display(16))),
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final entry in scenes.entries.where((entry) => entry.value['sport'] == sport))
                SizedBox(width: width, height: entry.key == 'pitch-duel' || entry.key == 'penalty-shootout' ? 300 : 330, child: CyberGameLaunchCard(
                  title: entry.value['title'] as String,
                  subtitle: '${sport.toUpperCase()} // ${entry.value['kind']}',
                  badge: 'STATOZ // $sport', action: 'ENTER THE GAME',
                  art: CyberGameArt.tactics,
                  game: ArcadeGame.values.firstWhere((game) => game.name == entry.value['flutter']),
                  accent: Color(int.parse((entry.value['accent'] as String).replaceFirst('#', 'FF'), radix: 16)),
                  animate: !_still, onTap: () {},
                )),
            ]),
          ],
        ]));
      }))),
    ])));
  }
}
