String? parsePublicIp(String raw) {
  final value = raw.trim().split(RegExp(r'\s+')).first;
  if (_isIpv4(value) || _isIpv6(value)) return value;
  return null;
}

String? parsePublicIpFromHttp(String raw) {
  var body = raw;
  final crlf = raw.indexOf('\r\n\r\n');
  if (crlf >= 0) {
    body = raw.substring(crlf + 4);
  } else {
    final lf = raw.indexOf('\n\n');
    if (lf >= 0) body = raw.substring(lf + 2);
  }
  final named = RegExp(
    r'(?:^|[\s;])ip=([0-9a-fA-F:.]+)',
    caseSensitive: false,
  ).firstMatch(body);
  if (named != null) {
    final ip = parsePublicIp(named.group(1)!);
    if (ip != null) return ip;
  }
  final direct = parsePublicIp(body);
  if (direct != null) return direct;
  final match = RegExp(r'(?:^|[^0-9])((?:\d{1,3}\.){3}\d{1,3})(?:[^0-9]|$)')
      .firstMatch(body);
  if (match != null) return parsePublicIp(match.group(1)!);
  return null;
}

bool isSamePublicIp(String? left, String? right) {
  if (left == null || right == null) return false;
  final a = parsePublicIp(left);
  final b = parsePublicIp(right);
  if (a == null || b == null) return false;
  return a == b;
}

/// Prefer a freshly fetched tunnel IP. If that check leaked or failed,
/// keep the last good IP that was not the ISP address.
String? pickPublicIpToShow({
  String? shown,
  String? fetched,
  String? ispIp,
}) {
  final fetchedIp = parsePublicIp(fetched ?? '');
  if (fetchedIp != null && !isSamePublicIp(fetchedIp, ispIp)) {
    return fetchedIp;
  }
  final shownIp = parsePublicIp(shown ?? '');
  if (shownIp != null && !isSamePublicIp(shownIp, ispIp)) {
    return shownIp;
  }
  if (fetchedIp != null && ispIp == null) return fetchedIp;
  return shownIp;
}

bool _isIpv4(String value) {
  final parts = value.split('.');
  if (parts.length != 4) return false;
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255) return false;
    if (part.length > 1 && part.startsWith('0')) return false;
  }
  return true;
}

bool _isIpv6(String value) {
  if (!value.contains(':') || value.contains(' ')) return false;
  if (value.length < 2 || value.length > 45) return false;
  return RegExp(r'^[0-9a-fA-F:]+$').hasMatch(value);
}
