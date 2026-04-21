import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Widget _buildAuthApp(Locale locale) {
  final state = AppState()..setLocale(locale);

  return ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        CkbMaterialLocalizationsDelegate(),
        CkbCupertinoLocalizationsDelegate(),
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection:
            locale.languageCode == 'ar' || locale.languageCode == 'ckb'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: child!,
      ),
      home: const AuthScreen(),
    ),
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> expectRtlSwitcherWorks(
    WidgetTester tester, {
    required Locale locale,
    required String expectedSignupField,
  }) async {
    await tester.pumpWidget(_buildAuthApp(locale));
    await tester.pumpAndSettle();

    final loginFinder = find.byKey(const ValueKey('auth_mode_login'));
    final signupFinder = find.byKey(const ValueKey('auth_mode_signup'));
    final indicatorFinder = find.byKey(const ValueKey('auth_mode_indicator'));

    expect(loginFinder, findsOneWidget);
    expect(signupFinder, findsOneWidget);
    expect(indicatorFinder, findsOneWidget);

    final initialLoginCenter = tester.getCenter(loginFinder);
    final initialSignupCenter = tester.getCenter(signupFinder);
    final initialIndicatorCenter = tester.getCenter(indicatorFinder);

    expect(initialLoginCenter.dx, greaterThan(initialSignupCenter.dx));
    expect(
      (initialIndicatorCenter.dx - initialLoginCenter.dx).abs(),
      lessThan((initialIndicatorCenter.dx - initialSignupCenter.dx).abs()),
    );

    await tester.tap(signupFinder);
    await tester.pumpAndSettle();

    final signupIndicatorCenter = tester.getCenter(indicatorFinder);
    final signupCenter = tester.getCenter(signupFinder);
    final loginCenter = tester.getCenter(loginFinder);

    expect(
      (signupIndicatorCenter.dx - signupCenter.dx).abs(),
      lessThan((signupIndicatorCenter.dx - loginCenter.dx).abs()),
    );
    expect(find.text(expectedSignupField), findsOneWidget);
  }

  group('AuthScreen RTL mode switcher', () {
    testWidgets('Arabic switcher aligns and changes pane correctly', (
      tester,
    ) async {
      await expectRtlSwitcherWorks(
        tester,
        locale: const Locale('ar'),
        expectedSignupField: 'الاسم الكامل',
      );
    });

    testWidgets('Kurdish switcher aligns and changes pane correctly', (
      tester,
    ) async {
      await expectRtlSwitcherWorks(
        tester,
        locale: const Locale('ckb'),
        expectedSignupField: 'ناوی تەواو',
      );
    });
  });
}
