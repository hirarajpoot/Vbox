import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/data/services/telemetry_service.dart';

void main() {
  test('events and errors are no-ops before Firebase is ready', () async {
    final telemetry = TelemetryService();
    expect(telemetry.ready, isFalse);
    await telemetry.event('vpn_connect', {'protocol': 'vmess'});
    await telemetry.error(Exception('test'));
  });
}
