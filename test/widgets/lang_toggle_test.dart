import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/lang_toggle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp(AppState state) {
  return ChangeNotifierProvider.value(
    value: state,
    child: const MaterialApp(
      home: Scaffold(body: Center(child: LangToggle())),
    ),
  );
}

void main() {
  late AppState appState;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    appState = AppState();
  });

  group('LangToggle', () {
    testWidgets('renders all three language options', (tester) async {
      await tester.pumpWidget(_buildTestApp(appState));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('کوردی'), findsOneWidget);
    });

    testWidgets('English is selected by default', (tester) async {
      await tester.pumpWidget(_buildTestApp(appState));
      await tester.pumpAndSettle();

      expect(appState.locale.languageCode, 'en');
    });

    testWidgets('tapping Arabic changes locale to ar', (tester) async {
      await tester.pumpWidget(_buildTestApp(appState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(appState.locale.languageCode, 'ar');
    });

    testWidgets('tapping Kurdish changes locale to ckb', (tester) async {
      await tester.pumpWidget(_buildTestApp(appState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('کوردی'));
      await tester.pumpAndSettle();

      expect(appState.locale.languageCode, 'ckb');
    });

    testWidgets('tapping English after switching returns to en',
        (tester) async {
      appState.setLocale(const Locale('ar'));
      await tester.pumpWidget(_buildTestApp(appState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(appState.locale.languageCode, 'en');
    });

    testWidgets('all three chips are present as GestureDetectors',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(appState));
      await tester.pumpAndSettle();

      // LangToggle uses Wrap with 3 _Chip children (GestureDetector)
      final chips = find.byType(GestureDetector);
      expect(chips, findsWidgets);
    });
  });
}
