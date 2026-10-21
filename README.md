# StatOz Games — Flutter host

This project is now a minimal Flutter container for the complete StatOz Games
web application:

`https://pai45.github.io/statoz-games-web/`

The former standalone Flutter product implementation has been removed. The web
project owns the product UI, games, navigation, persistence, and release. This
repository owns only the native/web container, same-origin navigation policy,
loading/error fallback, and platform packaging.

## Run

```powershell
flutter pub get
flutter run
```

The host requires a network connection. Android already declares the Internet
permission; iOS uses the HTTPS GitHub Pages origin without an ATS exception.

## Verify

```powershell
flutter analyze
flutter test
flutter build web
```
