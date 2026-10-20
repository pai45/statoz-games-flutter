# Basketball player-card image audit

Source: `C:\Users\priya\Downloads\basketball-revamp.json` (30 roster players), checked against the runtime `basketballPortraitAssets` mapping in `lib/data/basketball_portraits.dart` on 2026-08-28.

An image is considered attached only when the player card resolves to a mapped, bundled portrait asset. Files that happen to exist in the asset folder but are not in that mapping are not counted as attached.

## Summary

| Status | Player cards |
| --- | ---: |
| Image attached | 5 |
| No image attached | 25 |
| Total | 30 |

## Cards with an attached image

| Player ID | Player | Team | Position | Image asset |
| --- | --- | --- | --- | --- |
| 4066259 | De'Aaron Fox | San Antonio Spurs | G | `assets/basketball_player_images/deaaron_fox.webp` |
| 3934719 | OG Anunoby | New York Knicks | F | `assets/basketball_player_images/og_anunoby.webp` |
| 3136195 | Karl-Anthony Towns | New York Knicks | C | `assets/basketball_player_images/karl_anthony_towns.webp` |
| 3147657 | Mikal Bridges | New York Knicks | G | `assets/basketball_player_images/mikal_bridges.webp` |
| 3934672 | Jalen Brunson | New York Knicks | G | `assets/basketball_player_images/jalen_brunson.webp` |

## Cards without an attached image

| Player ID | Player | Team | Position |
| --- | --- | --- | --- |
| 4592479 | Julian Champagnie | San Antonio Spurs | F |
| 5104157 | Victor Wembanyama | San Antonio Spurs | F |
| 4395630 | Devin Vassell | San Antonio Spurs | G |
| 4845367 | Stephon Castle | San Antonio Spurs | G |
| 4395723 | Keldon Johnson | San Antonio Spurs | F |
| 5061568 | Carter Bryant | San Antonio Spurs | F |
| 3064560 | Luke Kornet | San Antonio Spurs | C |
| 5037871 | Dylan Harper | San Antonio Spurs | G |
| 6578 | Harrison Barnes | San Antonio Spurs | F |
| 2489663 | Kelly Olynyk | San Antonio Spurs | F |
| 4066317 | Lindy Waters III | San Antonio Spurs | F |
| 6427 | Bismack Biyombo | San Antonio Spurs | C |
| 2488653 | Mason Plumlee | San Antonio Spurs | C |
| 3134916 | Jordan McLaughlin | San Antonio Spurs | G |
| 3062679 | Josh Hart | New York Knicks | G |
| 4610139 | Jeremy Sochan | New York Knicks | F |
| 4351852 | Mitchell Robinson | New York Knicks | C |
| 4871141 | Ariel Hukporti | New York Knicks | C |
| 2528426 | Jordan Clarkson | New York Knicks | G |
| 3914044 | Landry Shamet | New York Knicks | G |
| 4277869 | Jose Alvarado | New York Knicks | G |
| 4431823 | Miles McBride | New York Knicks | G |
| 5211983 | Pacome Dadiet | New York Knicks | F |
| 5289900 | Mohamed Diawara | New York Knicks | F |
| 4433225 | Tyler Kolek | New York Knicks | G |
