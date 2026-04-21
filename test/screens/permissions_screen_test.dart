import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/done_screen.dart';
import 'package:flutter_application/screens/auth/permissions_screen.dart';
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
      home: PermissionsScreen(name: name),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => DoneScreen(name: name),
      ),
    ),
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PermissionsScreen', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Just a couple\nof things.'), findsOneWidget);
    });

    testWidgets('shows subtitle', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(
        find.text('These help FindIt work better for you.'),
        findsOneWidget,
      );
    });

    testWidgets('shows notifications permission card', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows location permission card', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('shows two toggle switches defaulted on', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.length, 2);
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isTrue);
    });

    testWidgets('can toggle notifications off', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      final switches = find.byType(Switch);
      await tester.tap(switches.first);
      await tester.pumpAndSettle();
      final updated = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(updated[0].value, isFalse);
    });

    testWidgets('shows Allow button', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(find.text('Allow & continue'), findsOneWidget);
    });

    testWidgets('shows settings hint', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      expect(
        find.text('You can change these anytime in Settings.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Allow navigates to DoneScreen', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow & continue'));
      await tester.pumpAndSettle();
      expect(find.byType(DoneScreen), findsOneWidget);
    });

    testWidgets('renders in Arabic', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed', locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text('بضعة أشياء\nفقط.'), findsOneWidget);
    });

    testWidgets('renders in Kurdish', (tester) async {
      await tester.pumpWidget(_buildApp('Ahmed', locale: const Locale('ckb')));
      await tester.pumpAndSettle();
      expect(find.text('چەند شتێکی\nپێویست.'), findsOneWidget);
    });
  });
}
