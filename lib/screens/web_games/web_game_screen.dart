import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../services/secure_storage_service.dart';
import 'bundle_view.dart';

class WebGameScreen extends StatefulWidget {
  const WebGameScreen({
    required this.gameId,
    required this.profileId,
    super.key,
  });
  final String gameId, profileId;
  @override
  State<WebGameScreen> createState() => _WebGameScreenState();
}

class _WebGameScreenState extends State<WebGameScreen> {
  late final String sessionId = List.generate(
    24,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  String? html, error;
  bool active = true;
  Future<void> writes = Future.value();
  String profileOwner = '';
  String get saveKey =>
      'statoz.games.flutter.web-game.${widget.gameId}.$profileOwner';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      profileOwner = (await SecureGameStorage().loadActiveLocalProfile()).name;
      final manifest =
          jsonDecode(
                await rootBundle.loadString('assets/web_games/manifest.json'),
              )
              as Map<String, dynamic>;
      final game = (manifest['games'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((entry) => entry['id'] == widget.gameId);
      final source = await rootBundle.loadString(
        'assets/web_games/${game['path']}',
      );
      if (sha256.convert(utf8.encode(source)).toString() != game['sha256']) {
        throw StateError('Game bundle integrity check failed');
      }
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> saved = {};
      final raw = prefs.getString(saveKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic> || decoded['schemaVersion'] != 1) {
          throw StateError(
            'This save needs a compatible game version; it has been preserved.',
          );
        }
        saved = decoded;
      }
      final boot = jsonEncode({
        ...saved,
        'sessionId': sessionId,
        'origin': 'native',
      }).replaceAll('<', r'\u003c');
      if (game['orientation'] == 'landscape') {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      if (mounted) {
        setState(
          () => html = source.replaceFirst(
            '/*__STATOZ_BOOT__*/',
            'window.__STATOZ_BOOT__=$boot;',
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'This demo game could not load. Its saved progress has been preserved.',
        );
      }
    }
  }

  void receive(String text) {
    if (!active || text.length > 600000) return;
    try {
      final message = jsonDecode(text);
      if (message is! Map ||
          message['protocolVersion'] != 1 ||
          message['gameId'] != widget.gameId ||
          message['sessionId'] != sessionId) {
        return;
      }
      if (message['type'] == 'exit') {
        Navigator.of(context).pop();
        return;
      }
      if (message['type'] == 'save') {
        final payload = message['payload'];
        if (payload is! Map ||
            payload['schemaVersion'] != 1 ||
            payload['stores'] is! Map ||
            payload['resultIds'] is! List) {
          return;
        }
        final value = jsonEncode(payload);
        writes = writes
            .then((_) async {
              final prefs = await SharedPreferences.getInstance();
              if (!await prefs.setString(saveKey, value)) {
                throw StateError('Save failed');
              }
            })
            .catchError((Object _) {
              if (mounted) {
                setState(
                  () => error = 'Progress could not be saved on this device.',
                );
              }
            });
      }
      if (message['type'] == 'error' && mounted) {
        setState(
          () => error = 'The game could not continue. Return and retry.',
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    active = false;
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Cyber.bg,
    body: SafeArea(
      child: Stack(
        children: [
          if (html != null)
            Positioned.fill(
              child: BundleView(html: html!, onMessage: receive),
            )
          else
            Center(
              child: Text(error ?? 'LOADING DEMO GAME', style: Cyber.body(16)),
            ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              tooltip: 'Return to Games',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          if (error != null && html != null)
            Align(
              alignment: Alignment.topCenter,
              child: Text(error!, style: Cyber.body(14)),
            ),
        ],
      ),
    ),
  );
}
