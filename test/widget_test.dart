// Widget tests for Find It app

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application/main.dart';

void main() {
  testWidgets('App loads and shows Find It branding', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences for tests.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build the app and trigger a frame.
    await tester.pumpWidget(FindItApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Verify the app title appears
    expect(find.text('Find It'), findsWidgets);
  });
}
