// Real-Firebase seed entry point — connects to production Firebase (NOT emulators).
// Used only by: flutter test integration_test/seed_real_test.dart
// Never shipped to production.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/navigation/root_router.dart';

class _CkbMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CkbMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
  @override
  bool shouldReload(_CkbMaterialLocalizationsDelegate old) => false;
}

/// Initialises real Firebase (no emulator hooks).
Future<void> setupRealFirebase() async {
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ckb', timeago.ArMessages());
}

Widget buildRealApp() => const _RealApp();

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await setupRealFirebase();
  runApp(buildRealApp());
}

class _RealApp extends StatelessWidget {
  const _RealApp();

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
              _CkbMaterialLocalizationsDelegate(),
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
