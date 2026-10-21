# Complete web games host

Status: **BUILT**

## Purpose

The Flutter application presents the whole published `statoz-games-web`
product as its only player-facing experience. It no longer maintains a second
Flutter implementation of the games product.

## Player experience

- Launching the app immediately opens the complete StatOz Games web home.
- Internal routes under `https://pai45.github.io/statoz-games-web/` stay inside
  the app.
- Android system back navigates WebView history when history exists.
- Native loading failures preserve the app shell and offer a retry.
- Flutter web uses the same published experience in a full-screen iframe.

## Ownership

- `statoz-games-web` owns UI, game logic, navigation, content, persistence, and
  deployment.
- `statoz-games-flutter` owns the container, trusted-origin policy, native back
  behavior, error fallback, and platform builds.
- No runtime code or assets are synchronized back to legacy repositories.

## Persistence

The web product retains its own origin-scoped browser/WebView storage. The
Flutter host adds no independent profile, economy, progression, or save model.

## Limitations

- A network connection is required.
- The host displays the last published web release, not an unbuilt local web
  checkout.
- External top-level navigation is blocked by the native host.

## Verification

- `flutter analyze`
- `flutter test`
- `flutter build web`
- Running-app check that the home page loads and an internal route opens inside
  the host
