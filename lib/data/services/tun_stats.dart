import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vbox/core/utils/public_ip.dart';
import 'package:vbox/core/utils/session_traffic.dart';

class TunStats {
  TunStats({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('vbox/tun_stats');

  final MethodChannel _channel;

  Future<TrafficSnapshot?> read() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('read');
      if (raw == null) return null;
      final rx = _asInt(raw['rx']);
      final tx = _asInt(raw['tx']);
      if (rx == null || tx == null) return null;
      return TrafficSnapshot(rx: rx, tx: tx, at: DateTime.now());
    } catch (_) {
      return null;
    }
  }

  Future<String> publicIp() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw Exception('Android only');
    }
    try {
      final raw = await _channel.invokeMethod<String>('publicIp');
      final ip = parsePublicIp(raw ?? '') ?? parsePublicIpFromHttp(raw ?? '');
      if (ip != null) return ip;
      throw Exception(raw ?? 'empty');
    } on PlatformException catch (error) {
      throw Exception(error.message ?? error.code);
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}
