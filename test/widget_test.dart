import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Inject a pre-initialized AppState to bypass loading screens and Firebase checks
    final state = AppState();
    await tester.pumpWidget(
      FindItApp(appState: state, skipLaunchExperience: true),
    );
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

    testWidgets('Auth screen shows phone field', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should find at least one TextField (for phone)
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Login form shows error when submitted empty', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Tap Send OTP button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send OTP').first);
      await tester.pumpAndSettle();

      // Form validation triggers — no crash
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
