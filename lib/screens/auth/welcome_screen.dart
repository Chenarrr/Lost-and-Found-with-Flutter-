import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/screens/auth/auth_screen.dart';
import 'package:flutter_application/utils/app_route.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/lang_toggle.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroLogoHeight = screenHeight < 760 ? 88.0 : 132.0;
    final heroLogoSpacing = screenHeight < 760 ? 12.0 : 18.0;

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo row
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/find-it-app-icon-official.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.appName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/find-it-symbol-transparent.png',
                      height: heroLogoHeight,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  SizedBox(height: heroLogoSpacing),
                  // Hero text
                  Text(
                    l10n.appName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.tagline,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Language picker
                  const LangToggle(),
                  const SizedBox(height: 24),
                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).push(smoothRoute(builder: (_) => const AuthScreen())),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.accentIndigo,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            l10n.getStarted,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      l10n.loginOrSignup,
                      style: GoogleFonts.manrope(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
