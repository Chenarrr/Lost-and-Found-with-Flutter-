import 'package:flutter/material.dart';

class AppMotion {
  static const Duration interactiveDuration = Duration(milliseconds: 280);
  static const Duration emphasisDuration = Duration(milliseconds: 420);
  static const Duration revealDuration = Duration(milliseconds: 520);
  static const Duration authModeDuration = Duration(milliseconds: 560);
  static const Duration routeDuration = Duration(milliseconds: 520);
  static const Duration routeReverseDuration = Duration(milliseconds: 420);
  static const Duration launchIntroDuration = Duration(milliseconds: 2200);
  static const Duration launchExitDuration = Duration(milliseconds: 620);
  static const Duration minimumLaunchDuration = Duration(milliseconds: 2400);

  static const Curve standardCurve = Curves.easeInOutCubicEmphasized;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;

  static const AnimationStyle dialogStyle = AnimationStyle(
    curve: standardCurve,
    reverseCurve: exitCurve,
    duration: emphasisDuration,
    reverseDuration: interactiveDuration,
  );

  static const AnimationStyle bottomSheetStyle = AnimationStyle(
    curve: standardCurve,
    reverseCurve: exitCurve,
    duration: emphasisDuration,
    reverseDuration: interactiveDuration,
  );
}

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.routeDuration;

  @override
  Duration get reverseTransitionDuration => AppMotion.routeReverseDuration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final primaryOffset = route.fullscreenDialog
        ? const Offset(0, 0.04)
        : const Offset(0.035, 0);

    final primarySlide = Tween<Offset>(begin: primaryOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: animation,
            curve: AppMotion.standardCurve,
            reverseCurve: AppMotion.exitCurve,
          ),
        );

    final primaryFade = CurvedAnimation(
      parent: animation,
      curve: AppMotion.enterCurve,
      reverseCurve: AppMotion.exitCurve,
    );
    return FadeTransition(
      opacity: primaryFade,
      child: SlideTransition(position: primarySlide, child: child),
    );
  }
}

const PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: AppPageTransitionsBuilder(),
    TargetPlatform.iOS: AppPageTransitionsBuilder(),
    TargetPlatform.macOS: AppPageTransitionsBuilder(),
    TargetPlatform.windows: AppPageTransitionsBuilder(),
    TargetPlatform.linux: AppPageTransitionsBuilder(),
    TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
  },
);
