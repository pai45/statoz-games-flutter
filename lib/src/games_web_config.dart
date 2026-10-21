const String gamesWebUrl = 'https://pai45.github.io/statoz-games-web/';

final Uri gamesWebUri = Uri.parse(gamesWebUrl);

bool isGamesWebNavigationAllowed(Uri uri) {
  if (uri.scheme == 'about' || uri.scheme == 'data' || uri.scheme == 'blob') {
    return true;
  }

  return uri.scheme == gamesWebUri.scheme &&
      uri.host == gamesWebUri.host &&
      (uri.path == '/statoz-games-web' ||
          uri.path.startsWith('/statoz-games-web/'));
}
