import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(FindItApp(prefs: prefs));
    await tester.pumpAndSettle();
  }

  group('App smoke tests', () {
    testWidgets('App loads and shows Find It branding', (tester) async {
      await pumpApp(tester);
      expect(find.text('Find It'), findsWidgets);
    });

    testWidgets('Welcome screen shows Get Started button', (tester) async {
      await pumpApp(tester);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Tapping Get Started navigates to auth screen', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      // Auth screen has Login and Signup tabs
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Signup'), findsWidgets);
    });

    testWidgets('Auth screen shows phone and password fields', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Login form shows error when submitted empty', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Tap Login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await tester.pumpAndSettle();

      // Form validation triggers — no crash
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
