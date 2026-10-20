import 'package:flutter_test/flutter_test.dart';
import 'package:card_game/config/game_ladder.dart';
import 'package:card_game/models/sport_match.dart';
import 'package:card_game/models/unlock_progress.dart';

void main() {
  test('short sport ladders graduate and unlock daily quests', () {
    for (final sport in Sport.values) {
      var progress = UnlockProgress.fresh(sport);
      final ladder = sportGameLadder[sport]!;
      final required = ladder.length.clamp(1, beginnerChapterLength);
      for (var i = 0; i < required; i++) {
        progress = progress.selectGame(ladder[i]);
        final result = progress.recordPlay(ladder[i], 'demo-$i');
        progress = result.progress;
        expect(result.graduated, i == required - 1);
      }
      expect(progress.dailyQuestsUnlocked, isTrue);
    }
  });
  test(
    'catalog contains only this product and each sport has playable missions',
    () {
      for (final sport in Sport.values) {
        final games = sportGameLadder[sport]!;
        expect(games, isNotEmpty);
        for (final game in games) {
          expect(demoGameEnabled(game), isTrue);
          final trivia =
              game.isQuiz ||
              game.name.contains('GuessPlayer') ||
              game == ArcadeGame.footballBingo ||
              game == ArcadeGame.guessDriver ||
              game == ArcadeGame.guessWinner;
          expect(trivia, false);
        }
        expect(UnlockProgress.fresh(sport).initialQuestActive, isTrue);
      }
    },
  );
}
