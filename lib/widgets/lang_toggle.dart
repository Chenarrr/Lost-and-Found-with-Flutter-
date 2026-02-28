import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Language toggle — safe to use before login.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final code = app.locale.languageCode;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
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
          onTap: () => context.read<AppState>().setLocale(const Locale('ckb')),
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.borderGray,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
