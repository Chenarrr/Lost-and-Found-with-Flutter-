// ignore_for_file: depend_on_referenced_packages

// Integration test entry point — connects to Firebase emulators.
// Used only by: flutter test integration_test/ --target lib/main_integration.dart
// Never shipped to production.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/navigation/root_router.dart';

/// Called from the integration test before pumping the widget.
Future<void> setupEmulators() async {
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Point to local emulators ─────────────────────────────────────────────
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ckb', timeago.KuMessages());
}

Widget buildIntegrationApp() => const _IntegrationApp();

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await setupEmulators();
  runApp(buildIntegrationApp());
}

class _IntegrationApp extends StatelessWidget {
  const _IntegrationApp();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Selector<AppState, (Locale, ThemeMode)>(
        selector: (_, app) => (app.locale, app.themeMode),
        builder: (_, record, _) {
          final (locale, themeMode) = record;
          final isRtl =
              locale.languageCode == 'ar' || locale.languageCode == 'ckb';
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Find It',
            locale: locale,
            localizationsDelegates: const [
              CkbMaterialLocalizationsDelegate(),
              CkbCupertinoLocalizationsDelegate(),
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            themeMode: themeMode,
            builder: (context, child) => Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryBlue,
              ),
              textTheme: GoogleFonts.interTextTheme(),
            ),
            home: const RootRouter(),
          );
        },
      ),
    );
  }
}
