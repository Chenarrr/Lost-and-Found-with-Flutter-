import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/routes/root_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(FindItApp(prefs: prefs));
}

class FindItApp extends StatelessWidget {
  const FindItApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(prefs),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Find It',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            primary: AppColors.primaryBlue,
            secondary: AppColors.primaryBlueDark,
            surface: AppColors.bgGray,
            onPrimary: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: AppColors.bgGray,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.cardWhite,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(color: AppColors.primaryBlue),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
        home: const RootRouter(),
      ),
    );
  }
}
