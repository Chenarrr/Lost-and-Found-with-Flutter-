import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Language picker — vertical list style.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final code = app.locale.languageCode;
    return AppPanel(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangRow(
            label: 'English',
            native: 'EN',
            selected: code == 'en',
            onTap: () => context.read<AppState>().setLocale(const Locale('en')),
          ),
          _LangRow(
            label: 'العربية',
            native: 'AR',
            selected: code == 'ar',
            onTap: () => context.read<AppState>().setLocale(const Locale('ar')),
          ),
          _LangRow(
            label: 'کوردی',
            native: 'KU',
            selected: code == 'ckb',
            isLast: true,
            onTap: () =>
                context.read<AppState>().setLocale(const Locale('ckb')),
          ),
        ],
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  const _LangRow({
    required this.label,
    required this.native,
    required this.selected,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final String native;
  final bool selected;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryBlue.withAlpha(18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryBlue
                        : isDark
                        ? Colors.white.withAlpha(12)
                        : AppColors.frost,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    native,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? Colors.white
                          : isDark
                          ? Colors.white.withAlpha(180)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? AppColors.primaryBlue : cs.onSurface,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 14,
            endIndent: 14,
            color: isDark
                ? Colors.white.withAlpha(12)
                : cs.outlineVariant.withAlpha(120),
          ),
      ],
    );
  }
}
