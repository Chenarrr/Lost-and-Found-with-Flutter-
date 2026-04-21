import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/navigation/main_page.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key, required this.name});

  final String name;

  String get _firstName => name.split(' ').first;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.revealDuration,
                curve: AppMotion.standardCurve,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 26 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Checkmark circle
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.heroNavy,
                            AppColors.heroBlue,
                            AppColors.heroTeal,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withAlpha(60),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.doneTitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      '$_firstName.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.doneSubtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Community stats card
                    AppPanel(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_alt_rounded,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.doneCommunitySnapshot,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _Stat(value: '2,847', label: l10n.doneItemsReturned),
                              _Divider(),
                              _Stat(value: '4', label: l10n.doneCitiesCovered),
                              _Divider(),
                              _Stat(value: '12k', label: l10n.doneActiveMembers),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainPage()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.accentIndigo,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withAlpha(56),
                                blurRadius: 24,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              l10n.doneOpenApp,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderGray,
    );
  }
}
