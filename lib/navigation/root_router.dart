import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/navigation/main_page.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:flutter_application/screens/launch_screen.dart';

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
  static const _minimumLaunchDuration = Duration(milliseconds: 2100);

  // Set once when isInitialized becomes true; never changes after that.
  bool? _initialIsLoggedIn;
  bool _minimumLaunchComplete = false;
  Timer? _launchTimer;

  @override
  void initState() {
    super.initState();
    _launchTimer = Timer(_minimumLaunchDuration, () {
      if (!mounted) return;
      setState(() => _minimumLaunchComplete = true);
    });
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = context.select<AppState, bool>(
      (app) => app.isInitialized,
    );

    if (isInitialized && _initialIsLoggedIn == null) {
      // Capture auth state once, without registering an ongoing dependency.
      _initialIsLoggedIn = context.read<AppState>().currentUser != null;
    }

    final showLaunch = !_minimumLaunchComplete || !isInitialized;
    final destination = (_initialIsLoggedIn ?? false)
        ? const MainPage()
        : const WelcomeScreen();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 680),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final scale =
            Tween<double>(
              begin: child.key == const ValueKey('launch') ? 1.0 : 0.985,
              end: 1.0,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            // ignore: use_null_aware_elements
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: showLaunch
          ? LaunchScreen(key: const ValueKey('launch'), isReady: isInitialized)
          : KeyedSubtree(
              key: const ValueKey('destination'),
              child: destination,
            ),
    );
  }
}
