import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firebase_options.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/navigation/root_router.dart';

// ── Dark palette ────────────────────────────────────────────────────────────
const _darkBg = Color(0xFF071323);
const _darkSurface = Color(0xFF102038);
const _darkSurfaceSoft = Color(0xFF162741);
const _darkBorder = Color(0xFF213551);
const _darkOnSurface = Color(0xFFF2F7FF);
const _darkOnSurface2 = Color(0xFF94A9C0);

TextTheme _appTextTheme(Brightness brightness) {
  final base = ThemeData(useMaterial3: true, brightness: brightness).textTheme;
  final bodyTheme = GoogleFonts.manropeTextTheme(base);

  return bodyTheme.copyWith(
    displayLarge: GoogleFonts.spaceGrotesk(
      textStyle: bodyTheme.displayLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.2,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      textStyle: bodyTheme.displayMedium,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
    headlineLarge: GoogleFonts.spaceGrotesk(
      textStyle: bodyTheme.headlineLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      textStyle: bodyTheme.headlineMedium,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      textStyle: bodyTheme.titleLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    titleMedium: GoogleFonts.spaceGrotesk(
      textStyle: bodyTheme.titleMedium,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
  );
}

ThemeData _lightTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentIndigo,
        tertiary: AppColors.accentGold,
        surface: Colors.white,
      ).copyWith(
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.borderGray,
        outlineVariant: const Color(0xFFE8EEF5),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    pageTransitionsTheme: appPageTransitionsTheme,
    textTheme: _appTextTheme(Brightness.light),
    scaffoldBackgroundColor: AppColors.bgGray,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backdropLightTop,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha(232),
      hintStyle: GoogleFonts.manrope(
        color: AppColors.placeholderGray,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: GoogleFonts.manrope(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.borderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.lostPrimary),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.lostPrimary, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        side: const BorderSide(color: AppColors.borderGray),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withAlpha(238),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFFE8EEF5)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withAlpha(224),
      selectedColor: AppColors.primaryBlue,
      disabledColor: AppColors.borderGray,
      showCheckmark: false,
      side: const BorderSide(color: AppColors.borderGray),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: GoogleFonts.manrope(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      secondaryLabelStyle: GoogleFonts.manrope(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.primaryBlue
            : AppColors.borderGray;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.heroNavy,
      contentTextStyle: GoogleFonts.manrope(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE8EEF5)),
  );
}

ThemeData _darkTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentIndigo,
        tertiary: AppColors.accentGold,
        surface: _darkSurface,
      ).copyWith(
        onPrimary: Colors.white,
        onSurface: _darkOnSurface,
        onSurfaceVariant: _darkOnSurface2,
        outline: _darkBorder,
        outlineVariant: const Color(0xFF233955),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    pageTransitionsTheme: appPageTransitionsTheme,
    textTheme: _appTextTheme(Brightness.dark),
    scaffoldBackgroundColor: _darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backdropDarkTop,
      surfaceTintColor: Colors.transparent,
      foregroundColor: _darkOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: _darkOnSurface,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: _darkOnSurface),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceSoft.withAlpha(236),
      hintStyle: GoogleFonts.manrope(
        color: _darkOnSurface2,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: GoogleFonts.manrope(color: _darkOnSurface2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.lostPrimary),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.lostPrimary, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkOnSurface,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        side: const BorderSide(color: _darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkSurfaceSoft.withAlpha(242),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: _darkBorder),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurfaceSoft.withAlpha(222),
      selectedColor: AppColors.primaryBlue,
      disabledColor: _darkBorder,
      showCheckmark: false,
      side: const BorderSide(color: _darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: GoogleFonts.manrope(
        color: _darkOnSurface,
        fontWeight: FontWeight.w700,
      ),
      secondaryLabelStyle: GoogleFonts.manrope(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? Colors.white
            : _darkOnSurface2;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.primaryBlue
            : _darkBorder;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkSurfaceSoft,
      contentTextStyle: GoogleFonts.manrope(color: _darkOnSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    dividerTheme: const DividerThemeData(color: _darkBorder),
  );
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ckb', timeago.KuMessages());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const FindItApp());
  FlutterNativeSplash.remove();
}

final ThemeData _cachedLightTheme = _lightTheme();
final ThemeData _cachedDarkTheme = _darkTheme();

class FindItApp extends StatelessWidget {
  final AppState? appState;
  final bool skipLaunchExperience;
  const FindItApp({
    super.key,
    this.appState,
    this.skipLaunchExperience = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => appState ?? AppState(),
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
            theme: _cachedLightTheme,
            darkTheme: _cachedDarkTheme,
            home: RootRouter(skipLaunchExperience: skipLaunchExperience),
            onGenerateRoute: (_) => null,
          );
        },
      ),
    );
  }
}
