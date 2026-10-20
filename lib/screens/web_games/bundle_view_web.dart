import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class BundleView extends StatefulWidget {
  const BundleView({required this.html, required this.onMessage, super.key});
  final String html;
  final ValueChanged<String> onMessage;
  @override
  State<BundleView> createState() => _BundleViewState();
}

class _BundleViewState extends State<BundleView> {
  late final web.HTMLIFrameElement frame;
  late final String viewId;
  late final JSFunction listener;
  static int serial = 0;
  @override
  void initState() {
    super.initState();
    viewId = 'statoz-bundle-${serial++}';
    frame = web.HTMLIFrameElement()
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('allow', 'autoplay; fullscreen');
    listener = ((web.MessageEvent event) {
      if (event.source != frame.contentWindow ||
          event.origin != web.window.location.origin) {
        return;
      }
      try {
        widget.onMessage(jsonEncode(event.data.dartify()));
      } catch (_) {}
    }).toJS;
    web.window.addEventListener('message', listener);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (_) => frame);
    frame.srcdoc = widget.html
        .replaceFirst(
          '"origin":"native"',
          '"origin":${jsonEncode(web.window.location.origin)}',
        )
        .toJS;
  }

  @override
  void dispose() {
    web.window.removeEventListener('message', listener);
    frame.src = 'about:blank';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: viewId);
}
