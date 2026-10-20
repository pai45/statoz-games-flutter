param(
  [string]$ChromePath = 'C:\Program Files\Google\Chrome\Application\chrome.exe',
  [int]$Port = 7357,
  [string[]]$ScenarioIds = @()
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$flutter = Join-Path $projectRoot 'flutter\bin\flutter.bat'
$captureHelper = Join-Path $projectRoot 'tool\capture_chrome_viewport.mjs'
$outputDirectory = Join-Path $projectRoot 'output\screenshots\statoz'
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$allScenarioIds = @(
  'onboarding.profile-setup.intro',
  'sports.match-hub.trending', 'sports.match-hub.football',
  'sports.match-hub.cricket', 'sports.match-hub.basketball',
  'sports.match-hub.tennis', 'sports.match-hub.motorsport',
  'picks.market-hub.browse',
  'games.games-hub.trending', 'games.games-hub.football',
  'games.games-hub.cricket', 'games.games-hub.basketball',
  'games.games-hub.tennis', 'games.games-hub.motorsport',
  'games.pitch-duel.entry', 'games.penalty-shootout.entry',
  'games.football-chess.entry', 'games.football-quiz.entry',
  'games.football-bingo.entry', 'games.football-guess-player.entry',
  'games.final-over.entry', 'games.cricket-quiz.entry',
  'games.cricket-guess-player.entry', 'games.hoop-duel.entry',
  'games.basketball-quiz.entry', 'games.basketball-guess-player.entry',
  'games.grand-prix-dash.entry', 'games.motorsport-quiz.entry',
  'games.guess-driver.entry', 'games.tennis-rally.entry',
  'games.tennis-quiz.entry', 'games.guess-winner.entry',
  'shop.catalogue.avatars', 'shop.catalogue.frames',
  'shop.catalogue.banners', 'shop.catalogue.kits', 'shop.catalogue.coins',
  'shop.catalogue.packs', 'shop.catalogue.cards',
  'leaderboards.top.rankings', 'profile.player-dossier.loaded',
  'social.friends-arena.loaded', 'social.referrals.ready',
  'help.tutorials.catalogue', 'help.support.ready',
  'match-tabs.football.predict', 'match-tabs.football.picks',
  'match-tabs.football.tops', 'match-tabs.football.stats',
  'match-tabs.cricket.predict', 'match-tabs.cricket.picks',
  'match-tabs.cricket.tops', 'match-tabs.cricket.stats',
  'match-tabs.basketball.predict', 'match-tabs.basketball.picks',
  'match-tabs.basketball.tops', 'match-tabs.basketball.stats',
  'match-tabs.motorsport.predict', 'match-tabs.motorsport.picks',
  'match-tabs.motorsport.tops', 'match-tabs.motorsport.stats',
  'match-tabs.tennis.predict', 'match-tabs.tennis.picks',
  'match-tabs.tennis.tops', 'match-tabs.tennis.stats',
  'match-tabs.football.stats-lower', 'match-tabs.cricket.stats-lower',
  'match-tabs.basketball.stats-lower', 'match-tabs.motorsport.stats-lower',
  'match-tabs.tennis.stats-lower'
)

if ($ScenarioIds.Count -eq 0) {
  $scenarioIds = $allScenarioIds
} else {
  $unknownScenarioIds = $ScenarioIds | Where-Object { $_ -notin $allScenarioIds }
  if ($unknownScenarioIds.Count -gt 0) {
    throw "Unknown catalog scenario ID(s): $($unknownScenarioIds -join ', ')"
  }
  $scenarioIds = $ScenarioIds
}

Push-Location $projectRoot
try {
  & $flutter build web --release -t tool/statoz_catalog_app.dart --no-wasm-dry-run
  $server = Start-Process -FilePath 'python' `
    -ArgumentList @('-m', 'http.server', $Port, '--directory', 'build/web') `
    -PassThru -WindowStyle Hidden
  Start-Sleep -Seconds 1

  for ($index = 0; $index -lt $scenarioIds.Count; $index++) {
    $id = $scenarioIds[$index]
    $parts = $id.Split('.')
    $order = (($allScenarioIds.IndexOf($id)) + 1).ToString('000')
    $filename = "${order}_$($parts[0])__$($parts[1])__$($parts[2]).png"
    $screenshotPath = Join-Path $outputDirectory $filename
    $profileDirectory = Join-Path $env:TEMP "statoz-catalog-$order-$([guid]::NewGuid().ToString('N'))"
    $scrollY = if ($id.EndsWith('.stats-lower')) { '10000' } else { '0' }
    New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    & node $captureHelper `
      '--chrome' $ChromePath `
      '--url' "http://127.0.0.1:$Port/?scenario=$id" `
      '--output' $screenshotPath `
      '--profile' $profileDirectory `
      '--width' '393' `
      '--height' '852' `
      '--dpr' '1' `
      '--scroll-y' $scrollY `
      '--wait-ms' '8000'
    if ($LASTEXITCODE -ne 0) {
      throw "Exact-viewport capture failed for $filename"
    }
  }

  python tool/build_statoz_screen_catalog.py
}
finally {
  if ($null -ne $server -and -not $server.HasExited) {
    Stop-Process -Id $server.Id
  }
  Pop-Location
}
