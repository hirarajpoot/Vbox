import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:vbox/core/utils/public_ip.dart';

class PublicIpService {
  PublicIpService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const endpoints = [
    'https://api.ipify.org',
    'https://ifconfig.me/ip',
    'https://ipinfo.io/ip',
  ];

  static const _socksPorts = [10808, 1080];
  static const _httpChecks = [
    ('1.1.1.1', 80, 'GET /cdn-cgi/trace HTTP/1.1'),
    ('api.ipify.org', 80, 'GET / HTTP/1.1'),
  ];

  Future<String> lookup({String? proxy}) async {
    if (proxy != null) return lookupThroughTunnel();
    Object? lastError;
    for (final url in endpoints) {
      try {
        final body = await _getDirect(url);
        final ip = parsePublicIp(body);
        if (ip != null) return ip;
        lastError = 'bad body';
      } catch (error) {
        lastError = error;
      }
    }
    throw Exception('IP check failed (${lastError ?? 'unavailable'})');
  }

  Future<String> lookupThroughTunnel() async {
    Object? lastError;
    for (final port in _socksPorts) {
      for (final check in _httpChecks) {
        try {
          return await _lookupViaSocks(
            socksPort: port,
            host: check.$1,
            port: check.$2,
            requestLine: check.$3,
          );
        } catch (error) {
          lastError = error;
        }
      }
    }
    try {
      final body = await _getViaHttpProxy('http://api.ipify.org', '127.0.0.1:10809');
      final ip = parsePublicIpFromHttp(body) ?? parsePublicIp(body);
      if (ip != null) return ip;
    } catch (error) {
      lastError = error;
    }
    throw Exception('IP check failed (${lastError ?? 'unavailable'})');
  }

  Future<String> _getDirect(String url) async {
    final response =
        await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.body;
  }

  Future<String> _getViaHttpProxy(String url, String proxy) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 4)
      ..idleTimeout = const Duration(seconds: 4)
      ..findProxy = (_) => 'PROXY $proxy';
    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(const Duration(seconds: 4));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return await response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _lookupViaSocks({
    required int socksPort,
    required String host,
    required int port,
    required String requestLine,
  }) async {
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      socksPort,
      sourceAddress: InternetAddress.loopbackIPv4,
      timeout: const Duration(seconds: 3),
    );
    final reader = _SocketReader(socket);
    try {
      socket.add(Uint8List.fromList(const [0x05, 0x01, 0x00]));
      final greet = await reader.read(2);
      if (greet[0] != 0x05 || greet[1] != 0x00) {
        throw Exception('SOCKS auth rejected');
      }

      socket.add(_socksConnect(host, port));
      final head = await reader.read(4);
      if (head[1] != 0x00) {
        throw Exception('SOCKS connect failed');
      }
      await _skipSocksBind(reader, head[3]);

      socket.add(
        utf8.encode('$requestLine\r\nHost: $host\r\nConnection: close\r\n\r\n'),
      );
      final raw = await reader.readRemaining();
      final ip = parsePublicIpFromHttp(raw);
      if (ip == null) throw Exception('bad socks body');
      return ip;
    } finally {
      reader.dispose();
      socket.destroy();
    }
  }

  Uint8List _socksConnect(String host, int port) {
    final portHi = (port >> 8) & 0xff;
    final portLo = port & 0xff;
    final ipv4 = parsePublicIp(host);
    if (ipv4 != null && ipv4.contains('.')) {
      return Uint8List.fromList([
        0x05,
        0x01,
        0x00,
        0x01,
        ...ipv4.split('.').map(int.parse),
        portHi,
        portLo,
      ]);
    }
    final hostBytes = utf8.encode(host);
    return Uint8List.fromList([
      0x05,
      0x01,
      0x00,
      0x03,
      hostBytes.length,
      ...hostBytes,
      portHi,
      portLo,
    ]);
  }

  Future<void> _skipSocksBind(_SocketReader reader, int atyp) async {
    if (atyp == 0x01) {
      await reader.read(6);
    } else if (atyp == 0x04) {
      await reader.read(18);
    } else if (atyp == 0x03) {
      final len = (await reader.read(1)).first;
      await reader.read(len + 2);
    }
  }
}

class _SocketReader {
  _SocketReader(Socket socket) {
    _sub = socket.listen(
      (data) {
        _buffer.addAll(data);
        _notify();
      },
      onDone: () {
        _done = true;
        _notify();
      },
      onError: (Object error) {
        _error = error;
        _notify();
      },
      cancelOnError: true,
    );
  }

  final _buffer = <int>[];
  late final StreamSubscription<Uint8List> _sub;
  Completer<void>? _wait;
  var _done = false;
  Object? _error;

  Future<List<int>> read(int count) async {
    while (_buffer.length < count) {
      if (_error != null) throw _error!;
      if (_done) throw Exception('SOCKS closed');
      _wait = Completer<void>();
      await _wait!.future.timeout(const Duration(seconds: 4));
    }
    final out = _buffer.sublist(0, count);
    _buffer.removeRange(0, count);
    return out;
  }

  Future<String> readRemaining() async {
    while (!_done) {
      if (_error != null) throw _error!;
      _wait = Completer<void>();
      try {
        await _wait!.future.timeout(const Duration(seconds: 4));
      } on TimeoutException {
        break;
      }
    }
    if (_error != null) throw _error!;
    return utf8.decode(_buffer);
  }

  void _notify() {
    final wait = _wait;
    if (wait != null && !wait.isCompleted) wait.complete();
  }

  void dispose() {
    _sub.cancel();
  }
}
