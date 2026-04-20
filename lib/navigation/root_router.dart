import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/navigation/main_page.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:flutter_application/screens/launch_screen.dart';
import 'package:provider/provider.dart';

// RootRouter determines the initial screen once on startup.
// After that, all auth transitions are handled imperatively via
// Navigator.pushAndRemoveUntil in OtpScreen (login) and SettingsScreen (logout).
// This avoids the duplicate-GlobalKey errors caused by RootRouter swapping
// its returned widget simultaneously with an imperative pushAndRemoveUntil.
class RootRouter extends StatefulWidget {
  const RootRouter({super.key, this.skipLaunchExperience = false});

  final bool skipLaunchExperience;

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter>
    with SingleTickerProviderStateMixin {
  // Set once when isInitialized becomes true; never changes after that.
  bool? _initialIsLoggedIn;
  bool _minimumLaunchComplete = false;
  bool _launchDismissed = false;
  Timer? _launchTimer;
  AnimationController? _launchExitController;
  Animation<double>? _launchFade;
  Animation<Offset>? _launchSlide;

  @override
  void initState() {
    super.initState();
    if (widget.skipLaunchExperience) {
      _minimumLaunchComplete = true;
      _launchDismissed = true;
      return;
    }
    _launchExitController =
        AnimationController(vsync: this, duration: AppMotion.launchExitDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              setState(() => _launchDismissed = true);
            }
          });
    _launchFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _launchExitController!,
        curve: AppMotion.standardCurve,
        reverseCurve: AppMotion.exitCurve,
      ),
    );
    _launchSlide =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.02)).animate(
          CurvedAnimation(
            parent: _launchExitController!,
            curve: AppMotion.standardCurve,
            reverseCurve: AppMotion.exitCurve,
          ),
        );
    _launchTimer = Timer(AppMotion.minimumLaunchDuration, () {
      if (!mounted) return;
      setState(() => _minimumLaunchComplete = true);
    });
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    _launchExitController?.dispose();
    super.dispose();
  }

  void _maybeDismissLaunch(bool isInitialized) {
    final controller = _launchExitController;
    if (controller == null || _launchDismissed || controller.isAnimating) {
      return;
    }
    if (!_minimumLaunchComplete || !isInitialized) return;
    if (controller.isCompleted) {
      if (!_launchDismissed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _launchDismissed = true);
        });
      }
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !controller.isAnimating) {
        controller.forward();
      }
    });
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

    _maybeDismissLaunch(isInitialized);

    final hasDestination = isInitialized && _initialIsLoggedIn != null;
    final destination = (_initialIsLoggedIn ?? false)
        ? const MainPage()
        : const WelcomeScreen();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasDestination)
          KeyedSubtree(
            key: ValueKey<bool>(_initialIsLoggedIn ?? false),
            child: destination,
          ),
        if (!_launchDismissed)
          IgnorePointer(
            ignoring: _launchExitController?.isCompleted ?? true,
            child: FadeTransition(
              opacity: _launchFade!,
              child: SlideTransition(
                position: _launchSlide!,
                child: LaunchScreen(
                  key: const ValueKey('launch'),
                  isReady: isInitialized,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
