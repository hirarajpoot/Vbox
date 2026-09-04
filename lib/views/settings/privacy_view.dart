import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class PrivacyView extends StatefulWidget {
  const PrivacyView({super.key});

  @override
  State<PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> {
  late final WebViewController _controller;

  static const _html = '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body { font-family: sans-serif; background:#0B0908; color:#A89888; padding:20px; line-height:1.55; }
  h1 { color:#F6EDE3; font-size:22px; }
  h2 { color:#E08A3D; font-size:15px; }
</style>
</head>
<body>
<h1>VBox Privacy Policy</h1>
<p>VBox is a local VPN / proxy client. It does not require an account and does not operate a server of your traffic.</p>
<h2>What stays on this device</h2>
<p>Server configs, subscriptions, DNS and routing preferences, connection logs and lifetime traffic counters are stored in Hive on the phone.</p>
<h2>What we do not collect</h2>
<p>No login, no analytics SDK, no remote logging of browsing. Subscription URLs are fetched only when you add or refresh them.</p>
<h2>Permissions</h2>
<p>VPN permission tunnels traffic through your chosen VMess / Shadowsocks / V2Ray server. Camera is used only for QR scan. Notifications are used for the Android VPN service.</p>
<p>You can export or wipe configs from Backup and the Configs screen at any time.</p>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(const Color(0xFF0B0908))
      ..loadHtmlString(_html);
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Privacy policy',
      body: WebViewWidget(controller: _controller),
    );
  }
}
