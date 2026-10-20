import 'dart:io';
import 'temp_cards.dart';

void main() {
  final withImages = <String, List<String>>{
    'Football': [],
    'Cricket': [],
    'Basketball': [],
    'Tennis': [],
    'Motorsport': [],
  };
  final withoutImages = <String, List<String>>{
    'Football': [],
    'Cricket': [],
    'Basketball': [],
    'Tennis': [],
    'Motorsport': [],
  };

  int withCount = 0;
  int withoutCount = 0;

  String getSport(PlayerCard card) {
    if (card.id.startsWith('cricket-')) return 'Cricket';
    if (basketballPlayerCards.any((c) => c.id == card.id)) return 'Basketball';
    if (tennisPlayerCards.any((c) => c.id == card.id)) return 'Tennis';
    if (racingPlayerCards.any((c) => c.id == card.id)) return 'Motorsport';
    return 'Football';
  }

  for (final card in allPlayerCards) {
    final sport = getSport(card);
    final assetPath = card.resolvedPortraitAsset;
    if (assetPath != null && File(assetPath).existsSync()) {
      withImages[sport]!.add('- ${card.id} (${card.name})');
      withCount++;
    } else {
      withoutImages[sport]!.add('- ${card.id} (${card.name})');
      withoutCount++;
    }
  }

  final sb = StringBuffer();
  sb.writeln('# Player Cards Images Audit\n');
  sb.writeln(
    'We ran a script across the entire application\'s data sets for all sports (Football, Cricket, Basketball, Tennis, and Motorsport) to cross-reference the canonical portrait paths in the code with the files that actually exist in the `assets/` directory.\n',
  );
  sb.writeln(
    'The results are listed below by whether the artwork was found on disk.\n',
  );

  sb.writeln('## Summary');
  sb.writeln('- **With Images:** $withCount players');
  sb.writeln('- **Without Images:** $withoutCount players\n');
  sb.writeln('---\n');

  sb.writeln('## 🎨 Players WITH Images ($withCount)\n');
  for (final sport in [
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Motorsport',
  ]) {
    final list = withImages[sport]!;
    if (list.isNotEmpty) {
      sb.writeln('### $sport');
      for (final item in list) {
        sb.writeln(item);
      }
      sb.writeln();
    }
  }

  sb.writeln('---\n');
  sb.writeln('## 🚫 Players WITHOUT Images ($withoutCount)\n');
  for (final sport in [
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Motorsport',
  ]) {
    final list = withoutImages[sport]!;
    if (list.isNotEmpty) {
      sb.writeln('### $sport');
      for (final item in list) {
        sb.writeln(item);
      }
      sb.writeln();
    }
  }

  File(
    r'C:\Users\priya\.gemini\antigravity\brain\d212dc61-291d-4bc1-a88c-23f7f7b52223\player_image_audit.md',
  ).writeAsStringSync(sb.toString());

  stdout.writeln(
    'Artifact updated successfully. With: $withCount, Without: $withoutCount',
  );
}
