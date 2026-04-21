import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/profile_setup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Widget _buildApp(String name, {Locale locale = const Locale('en')}) {
  return ChangeNotifierProvider(
    create: (_) => AppState(),
    child: MaterialApp(
      localizationsDelegates: const [
        CkbMaterialLocalizationsDelegate(),
        CkbCupertinoLocalizationsDelegate(),
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: ProfileSetupScreen(name: name),
    ),
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProfileSetupScreen', () {
    testWidgets('shows greeting with first name', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed Ali'));
      await tester.pumpAndSettle();
      expect(find.text('Hi, Ahmed!'), findsOneWidget);
    });

    testWidgets('uses only first name in greeting', (tester) async {
      await tester.pumpWidget(_buildApp('Sara Kareem'));
      await tester.pumpAndSettle();
      expect(find.text('Hi, Sara!'), findsOneWidget);
    });

    testWidgets('shows city section title', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Your City'), findsOneWidget);
    });

    testWidgets('shows all 6 city chips in English', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      for (final city in [
        'Erbil',
        'Sulaymaniyah',
        'Duhok',
        'Halabja',
        'Zakho',
        'Koya',
      ]) {
        expect(find.text(city), findsOneWidget);
      }
    });

    testWidgets('shows Continue button', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Continue →'), findsOneWidget);
    });

    testWidgets('shows error snackbar when no city selected', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue →'));
      await tester.pumpAndSettle();
      expect(find.text('Please select your city.'), findsOneWidget);
    });

    testWidgets('shows name initial in avatar', (tester) async {
      await tester.pumpWidget(_buildApp('Omar'));
      await tester.pumpAndSettle();
      expect(find.text('O'), findsOneWidget);
    });

    testWidgets('chip tapping works', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      // Tap Erbil chip — no error thrown
      await tester.tap(find.text('Erbil'));
      await tester.pumpAndSettle();
      // No snackbar after tapping chip (it only selects)
      expect(find.text('Please select your city.'), findsNothing);
    });

    testWidgets('renders city names in Arabic', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed', locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text('أربيل'), findsOneWidget);
      expect(find.text('السليمانية'), findsOneWidget);
    });

    testWidgets('renders city names in Kurdish', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed', locale: const Locale('ckb')));
      await tester.pumpAndSettle();
      expect(find.text('هەولێر'), findsOneWidget);
      expect(find.text('سلێمانی'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text("Tell us where you're based."), findsOneWidget);
    });
  });
}
