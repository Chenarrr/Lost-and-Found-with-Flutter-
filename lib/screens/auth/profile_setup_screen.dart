import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/permissions_screen.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const _cities = [
  'Erbil',
  'Sulaymaniyah',
  'Duhok',
  'Halabja',
  'Zakho',
  'Koya',
];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.name});

  final String name;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? _selectedCity;
  bool _saving = false;

  String get _initial =>
      widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?';

  Future<void> _continue() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.profileSetupSelectCityError,
            style: GoogleFonts.manrope(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryBlueDark,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final app = Provider.of<AppState>(context, listen: false);
    await app.updateUserCity(_selectedCity!);

    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PermissionsScreen(name: widget.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.heroNavy,
                              AppColors.heroBlue,
                              AppColors.heroTeal,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initial,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.surface,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.profileSetupHi(widget.name.split(' ').first),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.profileSetupSubtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileSetupCityTitle,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.profileSetupCitySubtitle,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _cities.map((city) {
                            final selected = _selectedCity == city;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCity = city),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryBlue
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withAlpha(10)
                                          : AppColors.bgGray),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryBlue
                                        : AppColors.borderGray,
                                  ),
                                ),
                                child: Text(
                                  city,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _continue,
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
                          child: _saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l10n.profileSetupContinue,
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
    );
  }
}
