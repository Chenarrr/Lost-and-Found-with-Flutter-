import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/navigation/main_page.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/done_screen.dart';
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
      home: DoneScreen(name: name),
      routes: {'/main': (_) => const MainPage()},
    ),
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('DoneScreen', () {
    testWidgets('shows done title', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed Ali'));
      await tester.pumpAndSettle();
      expect(find.text("You're all set,"), findsOneWidget);
    });

    testWidgets('shows first name only', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed Ali'));
      await tester.pumpAndSettle();
      expect(find.text('Ahmed.'), findsOneWidget);
      expect(find.text('Ali.'), findsNothing);
    });

    testWidgets('works with single-word name', (tester) async {
      await tester.pumpWidget(_buildApp('Sara'));
      await tester.pumpAndSettle();
      expect(find.text('Sara.'), findsOneWidget);
    });

    testWidgets('shows subtitle', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to the FindIt community.'), findsOneWidget);
    });

    testWidgets('shows community snapshot section', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Community snapshot'), findsOneWidget);
    });

    testWidgets('shows stat values', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('2,847'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('12k'), findsOneWidget);
    });

    testWidgets('shows Open FindIt button', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Open FindIt →'), findsOneWidget);
    });

    testWidgets('shows check icon', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('renders in Arabic', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed', locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text('أنت جاهز،'), findsOneWidget);
    });

    testWidgets('renders in Kurdish', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed', locale: const Locale('ckb')));
      await tester.pumpAndSettle();
      expect(find.text('ئامادەیت،'), findsOneWidget);
    });
  });
}
