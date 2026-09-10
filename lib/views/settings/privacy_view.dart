import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  static const _html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body { font-family: sans-serif; background: #17110C; color: #A89888; padding: 16px; line-height: 1.55; }
  h1 { color: #F6EDE3; font-size: 22px; }
  h2 { color: #E08A3D; font-size: 15px; }
</style>
</head>
<body>
<h1>VBox Privacy Policy</h1>
<p>VBox is a local VPN / proxy client. It does not require an account and does not operate a server of your traffic.</p>
<h2>What stays on this device</h2>
<p>Server configs, subscriptions, DNS and routing preferences, connection logs and lifetime traffic counters are stored locally (Hive).</p>
<h2>What we do not collect</h2>
<p>No login, no analytics SDK, no remote logging of browsing. Subscription URLs are fetched only when you add or refresh them.</p>
<h2>Permissions</h2>
<p>VPN permission tunnels traffic through your chosen VMess / Shadowsocks / V2Ray server on Android. Camera is used only for QR scan. Notifications are used for the Android VPN service.</p>
</body>
</html>
''';

  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    try {
      _controller = WebViewController()
        ..setBackgroundColor(const Color(0xFF17110C))
        ..loadHtmlString(_html);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _controller == null) return const PrivacyView();
    return SubPageScaffold(
      kicker: 'LEDGER',
      title: 'Privacy Policy',
      body: WebViewWidget(controller: _controller!),
    );
  }
}

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      kicker: 'LEDGER',
      title: 'Privacy',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          8,
          AppSpacing.screen,
          32,
        ),
        children: const [
          Text(
            'VBox Privacy Policy',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'VBox is a local VPN / proxy client. It does not require an account and does not operate a server of your traffic.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.55),
          ),
          SizedBox(height: 20),
          Text(
            'What stays on this device',
            style: TextStyle(
              color: AppColors.copper,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Server configs, subscriptions, DNS and routing preferences, connection logs and lifetime traffic counters are stored locally (Hive).',
            style: TextStyle(color: AppColors.textSecondary, height: 1.55),
          ),
          SizedBox(height: 20),
          Text(
            'What we do not collect',
            style: TextStyle(
              color: AppColors.copper,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No login, no analytics SDK, no remote logging of browsing. Subscription URLs are fetched only when you add or refresh them.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.55),
          ),
          SizedBox(height: 20),
          Text(
            'Permissions',
            style: TextStyle(
              color: AppColors.copper,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'VPN permission tunnels traffic through your chosen VMess / Shadowsocks / V2Ray server on Android. Camera is used only for QR scan. Notifications are used for the Android VPN service. The web version is a UI preview — the VPN core does not run in a browser.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.55),
          ),
          SizedBox(height: 12),
          Text(
            'You can export or wipe configs from Backup and the Configs screen at any time.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.55),
          ),
        ],
      ),
    );
  }
}
