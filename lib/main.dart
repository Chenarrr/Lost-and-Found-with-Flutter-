import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/navigation/root_router.dart';

// Kurdish Sorani (ckb) is not in GlobalMaterialLocalizations, so Material
// widgets like AppBar would crash with "No MaterialLocalizations found".
// This delegate bridges ckb → Arabic material strings (same script/RTL).
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


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ckb', timeago.ArMessages());
  runApp(const FindItApp());
}

class FindItApp extends StatelessWidget {
  final AppState? appState;
  const FindItApp({super.key, this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => appState ?? AppState(),
      child: Consumer<AppState>(
        builder: (_, app, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Find It',
          locale: app.locale,
          localizationsDelegates: const [
            _CkbMaterialLocalizationsDelegate(),
            ...AppLocalizations.localizationsDelegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final isRtl =
                app.locale.languageCode == 'ar' ||
                app.locale.languageCode == 'ckb';
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              secondary: AppColors.accentIndigo,
              surface: AppColors.cardWhite,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textTheme: GoogleFonts.interTextTheme(),
            scaffoldBackgroundColor: AppColors.bgGray,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              titleTextStyle: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
              iconTheme: const IconThemeData(color: AppColors.primaryBlue),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white.withAlpha(230),
              hintStyle: GoogleFonts.inter(color: AppColors.placeholderGray),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.4,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                elevation: 2,
                shadowColor: AppColors.primaryBlue.withAlpha(64),
              ),
            ),
            cardTheme: CardThemeData(
              color: AppColors.cardWhite,
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryBlue,
              disabledColor: AppColors.borderGray,
              showCheckmark: false,
              side: const BorderSide(color: AppColors.borderGray),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              labelStyle: GoogleFonts.inter(color: AppColors.textPrimary),
              secondaryLabelStyle: GoogleFonts.inter(color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: AppColors.iconGray,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8,
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textPrimary,
              contentTextStyle: GoogleFonts.inter(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          home: const RootRouter(),
        ),
      ),
    );
  }
}
