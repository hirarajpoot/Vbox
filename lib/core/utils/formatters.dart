String formatBytes(num bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var i = 0;
  while (value >= 1024 && i < units.length - 1) {
    value /= 1024;
    i++;
  }
  final digits = value >= 100 || i == 0 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[i]}';
}

String formatSpeed(num bytesPerSec) => '${formatBytes(bytesPerSec)}/s';

String formatPing(int? ms) {
  if (ms == null) return '—';
  if (ms < 0) return 'timeout';
  return '${ms}ms';
}

String protocolLabel(String protocol) {
  switch (protocol.toLowerCase()) {
    case 'ss':
    case 'shadowsocks':
      return 'SS';
    case 'vmess':
      return 'VMess';
    case 'vless':
      return 'VLESS';
    case 'trojan':
      return 'Trojan';
    case 'json':
      return 'JSON';
    default:
      return protocol.toUpperCase();
  }
}
