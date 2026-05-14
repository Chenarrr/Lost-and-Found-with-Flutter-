import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        AppColors.backdropDarkTop,
                        AppColors.backdropDarkMid,
                        AppColors.backdropDarkBottom,
                      ]
                    : const [
                        AppColors.backdropLightTop,
                        AppColors.backdropLightMid,
                        AppColors.backdropLightBottom,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -110,
                right: -40,
                child: _GlowOrb(
                  size: 260,
                  colors: isDark
                      ? [
                          AppColors.primaryBlue.withAlpha(80),
                          AppColors.primaryBlue.withAlpha(6),
                        ]
                      : [
                          AppColors.primaryBlue.withAlpha(52),
                          AppColors.primaryBlue.withAlpha(4),
                        ],
                ),
              ),
              Positioned(
                top: 180,
                left: -80,
                child: _GlowOrb(
                  size: 220,
                  colors: isDark
                      ? [
                          AppColors.accentIndigo.withAlpha(72),
                          AppColors.accentIndigo.withAlpha(4),
                        ]
                      : [
                          AppColors.accentIndigo.withAlpha(40),
                          AppColors.accentIndigo.withAlpha(3),
                        ],
                ),
              ),
              Positioned(
                bottom: -130,
                right: -30,
                child: _GlowOrb(
                  size: 280,
                  colors: isDark
                      ? [
                          AppColors.accentGold.withAlpha(44),
                          AppColors.accentGold.withAlpha(2),
                        ]
                      : [
                          AppColors.accentGold.withAlpha(26),
                          AppColors.accentGold.withAlpha(1),
                        ],
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
