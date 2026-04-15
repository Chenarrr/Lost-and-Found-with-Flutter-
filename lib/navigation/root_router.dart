import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:flutter_application/navigation/main_page.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';

// RootRouter determines the initial screen once on startup.
// After that, all auth transitions are handled imperatively via
// Navigator.pushAndRemoveUntil in OtpScreen (login) and SettingsScreen (logout).
// This avoids the duplicate-GlobalKey errors caused by RootRouter swapping
// its returned widget simultaneously with an imperative pushAndRemoveUntil.
class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  // Set once when isInitialized becomes true; never changes after that.
  bool? _initialIsLoggedIn;

  @override
  Widget build(BuildContext context) {
    final isInitialized = context.select<AppState, bool>(
      (app) => app.isInitialized,
    );

    if (!isInitialized) {
      return const Scaffold(
        body: AppBackdrop(
          child: Center(
            child: AppPanel(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ),
      );
    }

    // Capture auth state once, without registering an ongoing dependency.
    _initialIsLoggedIn ??= context.read<AppState>().currentUser != null;

    return _initialIsLoggedIn! ? const MainPage() : const WelcomeScreen();
  }
}
