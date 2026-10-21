import 'package:flutter_test/flutter_test.dart';
import 'package:statoz_games_flutter/src/games_web_config.dart';

void main() {
  test('opens the published complete games web app', () {
    expect(gamesWebUrl, 'https://pai45.github.io/statoz-games-web/');
  });

  test('keeps top-level navigation inside the games web app', () {
    expect(
      isGamesWebNavigationAllowed(
        Uri.parse('https://pai45.github.io/statoz-games-web/games/'),
      ),
      isTrue,
    );
    expect(
      isGamesWebNavigationAllowed(Uri.parse('https://example.com/')),
      isFalse,
    );
  });
}
