import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BundleView extends StatefulWidget {
  const BundleView({required this.html, required this.onMessage, super.key});
  final String html;
  final ValueChanged<String> onMessage;
  @override
  State<BundleView> createState() => _BundleViewState();
}

class _BundleViewState extends State<BundleView> with WidgetsBindingObserver {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'StatozGame',
        onMessageReceived: (message) => widget.onMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              request.url == 'about:blank' ||
                  request.url == 'https://statoz-demo.invalid/' ||
                  request.url.startsWith('data:text/html')
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
        ),
      )
      ..loadHtmlString(widget.html, baseUrl: 'https://statoz-demo.invalid/');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      controller.runJavaScript("window.__STATOZ_HOST__?.command?.('pause')");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.runJavaScript("window.__STATOZ_HOST__?.command?.('dispose')");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: controller);
}
