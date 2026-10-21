# StatOz Games Flutter product documentation

> **Status:** BUILT
> **Last verified:** 2026-10-21

The Flutter project is a thin host for the complete StatOz Games web product at
`https://pai45.github.io/statoz-games-web/`.

The former Flutter-native games, hubs, economy, progression, predictions,
profiles, and supporting state implementation have been removed. Their pages
remain in this repository only as historical documentation and are
**DEPRECATED** for this Flutter runtime. The maintained product experience,
game catalog, navigation, and persistence now come from `statoz-games-web`.

## Current app map

1. Flutter starts a full-screen web host.
2. Android and iOS load the published site in an in-app WebView.
3. Flutter web loads the same site in a full-screen iframe.
4. Same-origin navigation under `/statoz-games-web/` remains inside the host.
5. A native connection failure shows a retry surface.

## Product system

| System | Status | Product page |
|---|---|---|
| Complete StatOz Games web experience hosted inside Flutter | BUILT | [Web games host](systems/web-games-host.md) |
| Former Flutter-native product implementation | DEPRECATED | Historical pages under `games/`, `systems/`, and `design/` |

## Implementation references

- [`lib/main.dart`](../../lib/main.dart)
- [`lib/src/games_web_config.dart`](../../lib/src/games_web_config.dart)
- [`lib/src/games_web_host_native.dart`](../../lib/src/games_web_host_native.dart)
- [`lib/src/games_web_host_web.dart`](../../lib/src/games_web_host_web.dart)
- [`test/games_web_config_test.dart`](../../test/games_web_config_test.dart)

## Current limitation

The host depends on the published HTTPS site and therefore requires a network
connection. The full 400+ MB static export is deliberately not duplicated into
the Flutter binary.

## Documentation contract

Runtime code is authoritative. Product changes belong in `statoz-games-web`;
container, navigation-policy, and platform changes belong here. Append every
documentation update to [DOCUMENTATION_LEDGER.md](DOCUMENTATION_LEDGER.md).
