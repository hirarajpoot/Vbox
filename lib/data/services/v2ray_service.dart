import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vbox/platform/v2ray_plugin.dart';
import 'package:vbox/core/constants/lan_bypass.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/data/models/vpn_config.dart';

class V2RayService {
  FlutterV2ray? _engine;
  void Function(V2RayStatus status)? onStatus;

  bool get isAvailable => _engine != null;

  static bool get supportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    if (!supportedPlatform) return;
    try {
      final engine = FlutterV2ray(
        onStatusChanged: (status) => onStatus?.call(status),
      );
      await engine.initializeV2Ray(
        notificationIconResourceType: 'mipmap',
        notificationIconResourceName: 'ic_launcher',
      );
      _engine = engine;
    } catch (error, stack) {
      debugPrint('V2Ray init skipped: $error\n$stack');
    }
  }

  Future<String> coreVersion() async {
    try {
      return await _engine?.getCoreVersion() ?? 'preview';
    } catch (_) {
      return 'unknown';
    }
  }

  String buildConfiguration(VpnConfig config, AppSettings settings) {
    late String json;
    if (config.isJson || detectJson(config.shareLink)) {
      json = config.shareLink;
    } else {
      json = FlutterV2ray.parseFromURL(config.shareLink).getFullConfiguration();
    }
    json = _enableTunnelDns(json, settings);
    return _applyMtu(json, settings.mtuSize);
  }

  String remarkOf(VpnConfig config) {
    if (config.isJson) return config.remark;
    try {
      return FlutterV2ray.parseFromURL(config.shareLink).remark;
    } catch (_) {
      return config.remark;
    }
  }

  Future<bool> requestPermission() async {
    if (_engine == null) return false;
    return _engine!.requestPermission();
  }

  Future<void> start({
    required VpnConfig config,
    required AppSettings settings,
  }) async {
    final engine = _engine;
    if (engine == null) {
      throw StateError('VPN core runs on Android only. Use a phone or emulator.');
    }
    final json = buildConfiguration(config, settings);
    final bypass = <String>[
      if (settings.routeMode == RouteMode.bypassLan) ...lanBypassSubnets,
      if (settings.routeMode == RouteMode.custom)
        ...settings.customBypassSubnets.where((s) => s.trim().isNotEmpty),
    ];
    await engine.startV2Ray(
      remark: config.remark,
      config: json,
      blockedApps: settings.perAppProxy && settings.blockedApps.isNotEmpty
          ? settings.blockedApps
          : null,
      bypassSubnets: bypass.isEmpty ? null : bypass,
      proxyOnly: settings.proxyOnly,
      notificationDisconnectButtonName: 'DISCONNECT',
    );
  }

  Future<void> stop() async {
    await _engine?.stopV2Ray();
  }

  Future<int> pingConfig(VpnConfig config, AppSettings settings) async {
    try {
      final engine = _engine;
      if (engine == null) return -1;
      final json = buildConfiguration(config, settings);
      return await engine.getServerDelay(
        config: json,
        url: 'https://www.gstatic.com/generate_204',
      );
    } catch (_) {
      return -1;
    }
  }

  Future<int> pingConnected() async {
    try {
      return await _engine?.getConnectedServerDelay(
            url: 'https://www.gstatic.com/generate_204',
          ) ??
          -1;
    } catch (_) {
      return -1;
    }
  }

  static bool detectJson(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('{')) return false;
    try {
      jsonDecode(trimmed);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// V2Box-style DNS for tun2socks: Android VpnService can only addDnsServer()
  /// real IPs (string entries first). FakeDNS is an object so Java skips it
  /// after the IPs are already installed. UDP 53 is handed to Xray's DNS
  /// module instead of being forwarded as UDP through the VMess node.
  String _enableTunnelDns(String jsonConfig, AppSettings settings) {
    try {
      final map = jsonDecode(jsonConfig);
      if (map is! Map<String, dynamic>) return jsonConfig;

      map['dns'] = _dnsObject(settings);

      final inbounds = map['inbounds'];
      if (inbounds is List) {
        for (final inbound in inbounds) {
          if (inbound is! Map) continue;
          inbound['sniffing'] = {
            'enabled': true,
            'destOverride': ['http', 'tls', 'fakedns'],
          };
        }
      }

      final outbounds = map['outbounds'];
      if (outbounds is List) {
        outbounds.removeWhere(
          (item) => item is Map && item['tag'] == 'dns-out',
        );
        outbounds.add({
          'tag': 'dns-out',
          'protocol': 'dns',
        });
      }

      map['routing'] = {
        'domainStrategy': 'IPIfNonMatch',
        'rules': [
          {
            'type': 'field',
            'network': 'udp',
            'port': '53',
            'outboundTag': 'dns-out',
          },
        ],
      };

      return jsonEncode(map);
    } catch (error, stack) {
      debugPrint('V2Ray tunnel DNS skipped: $error\n$stack');
      return jsonConfig;
    }
  }

  String _applyMtu(String jsonConfig, int mtu) {
    final size = mtu <= 0 ? 1500 : mtu;
    try {
      final map = jsonDecode(jsonConfig) as Map<String, dynamic>;
      _walkMtu(map, size);
      return jsonEncode(map);
    } catch (_) {
      return jsonConfig;
    }
  }

  void _walkMtu(dynamic node, int mtu) {
    if (node is Map) {
      if (node.containsKey('mtu')) {
        node['mtu'] = mtu;
      }
      final kcp = node['kcpSettings'];
      if (kcp is Map) {
        kcp['mtu'] = mtu;
      }
      for (final value in node.values) {
        _walkMtu(value, mtu);
      }
    } else if (node is List) {
      for (final value in node) {
        _walkMtu(value, mtu);
      }
    }
  }

  Map<String, dynamic> _dnsObject(AppSettings settings) {
    final resolver = settings.vpnDns.trim();
    final ip = _isIpLiteral(resolver) ? resolver : '1.1.1.1';
    return {
      'servers': [
        ip,
        if (ip != '8.8.8.8') '8.8.8.8',
        {'address': 'fakedns'},
      ],
      'queryStrategy': 'UseIPv4',
      'fakeDns': {
        'ipPool': '198.18.0.0/15',
        'poolSize': 32768,
      },
    };
  }

  bool _isIpLiteral(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
