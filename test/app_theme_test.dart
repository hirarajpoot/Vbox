import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/core/theme/app_theme.dart';

void main() {
  test('dark theme uses bundled Poppins instead of runtime fonts', () {
    final theme = AppTheme.dark;
    expect(theme.textTheme.bodyMedium?.fontFamily, AppText.family);
    expect(theme.appBarTheme.titleTextStyle?.fontFamily, AppText.family);
  });
}
