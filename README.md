# StatOz Games — Flutter demo

Independent demo/UI-reference project copied from local pai45/flutter-card-game at 78333df4eedb18ab41ee9e788c3bd30b228c441a, including reviewed local work. Original checkout is unchanged. No shared account service, cloud synchronization, payments or production commerce.

Sports arcade games; excludes matches, picks, quizzes, Bingo and guessing modes.

Player data starts fresh and stays local to this app. Existing placeholder modes retain that status. See ASSET-REPLACEMENTS.md for temporary artwork and original provenance.

Use Flutter matching the source toolchain. Run `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build web --base-href /statoz-games-flutter/`. Android outputs are development builds; iOS verification requires an Apple toolchain.

Only this repository may be changed by its scripts. Never run synchronization against the original card_game or statoz_web folders.
