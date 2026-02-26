import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:flutter_application/routes/main_page.dart';

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final isInitialized = context.select<AppState, bool>(
      (app) => app.isInitialized,
    );
    final isLoggedIn = context.select<AppState, bool>(
      (app) => app.currentUser != null,
    );

    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }
    if (!isLoggedIn) return const WelcomeScreen();
    return const MainPage();
  }
}
