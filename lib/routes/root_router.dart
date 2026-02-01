import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:flutter_application/routes/main_page.dart';

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    if (app.currentUser == null) return const WelcomeScreen();
    return const MainPage();
  }
}
