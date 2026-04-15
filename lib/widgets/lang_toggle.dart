import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Language toggle — safe to use before login.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final code = app.locale.languageCode;
    return AppPanel(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(999),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _Chip(
            label: 'English',
            selected: code == 'en',
            onTap: () => context.read<AppState>().setLocale(const Locale('en')),
          ),
          _Chip(
            label: 'العربية',
            selected: code == 'ar',
            onTap: () => context.read<AppState>().setLocale(const Locale('ar')),
          ),
          _Chip(
            label: 'کوردی',
            selected: code == 'ckb',
            onTap: () =>
                context.read<AppState>().setLocale(const Locale('ckb')),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected
              ? null
              : isDark
              ? Colors.white.withAlpha(10)
              : AppColors.frost,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : isDark
                ? Colors.white.withAlpha(18)
                : AppColors.borderGray,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withAlpha(52),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected
                ? Colors.white
                : isDark
                ? Colors.white.withAlpha(210)
                : AppColors.textSecondary,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
