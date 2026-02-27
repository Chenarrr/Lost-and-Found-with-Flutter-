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
    final isAr = app.locale.languageCode == 'ar';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chip(
          label: 'English',
          selected: !isAr,
          onTap: () => context.read<AppState>().setLocale(const Locale('en')),
        ),
        const SizedBox(width: 10),
        _Chip(
          label: 'العربية',
          selected: isAr,
          onTap: () => context.read<AppState>().setLocale(const Locale('ar')),
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
