import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'games_web_config.dart';

class GamesWebHost extends StatefulWidget {
  const GamesWebHost({super.key});

  @override
  State<GamesWebHost> createState() => _GamesWebHostState();
}

class _GamesWebHostState extends State<GamesWebHost> {
  static int _nextViewId = 0;

  late final String _viewType;
  late final web.HTMLIFrameElement _frame;
  late final JSFunction _loadListener;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _viewType = 'statoz-games-web-${_nextViewId++}';
    _frame = web.HTMLIFrameElement()
      ..src = gamesWebUrl
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('allow', 'autoplay; fullscreen')
      ..setAttribute('allowfullscreen', 'true');
    _loadListener = ((web.Event _) {
      if (mounted) setState(() => _loading = false);
    }).toJS;
    _frame.addEventListener('load', _loadListener);
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (_) => _frame);
  }

  @override
  void dispose() {
    _frame.removeEventListener('load', _loadListener);
    _frame.src = 'about:blank';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          HtmlElementView(viewType: _viewType),
          if (_loading)
            const ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
