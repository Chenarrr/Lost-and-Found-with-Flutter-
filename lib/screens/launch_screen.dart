import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:google_fonts/google_fonts.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key, required this.isReady});

  final bool isReady;

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1850),
  )..forward();

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  double _stagger(double value, double begin, double end, Curve curve) {
    if (value <= begin) return 0;
    if (value >= end) return 1;
    final normalized = (value - begin) / (end - begin);
    return curve.transform(normalized).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width < 380 ? 148.0 : 176.0;
    final haloSize = logoSize * 1.78;
    final l10n = context.l10n;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _introController,
        builder: (context, child) {
          final intro = _introController.value;
          final ambientAngle = intro * math.pi * 1.7;
          final ambientWave = math.sin(ambientAngle);
          final ambientWaveSoft = math.sin((intro * math.pi * 1.15) + 0.6);

          final glowReveal = _stagger(intro, 0.0, 0.42, Curves.easeOutCubic);
          final logoReveal = _stagger(intro, 0.14, 0.68, Curves.easeOutBack);
          final ringReveal = _stagger(intro, 0.2, 0.82, Curves.easeOutCubic);
          final titleReveal = _stagger(intro, 0.42, 0.82, Curves.easeOutCubic);
          final captionReveal = _stagger(intro, 0.56, 1.0, Curves.easeOutCubic);

          final orbDriftX = ambientWave * 20;
          final orbDriftY = ambientWaveSoft * 16;
          final logoFloat = ambientWaveSoft * 8;
          final logoScale =
              0.78 + (logoReveal * 0.22) + (ringReveal * 0.015 * ambientWave);
          final haloScale = 0.94 + (ringReveal * 0.14) + (ambientWave * 0.02);
          final readyProgress = widget.isReady
              ? 1.0
              : 0.35 + (0.3 * ambientWaveSoft.abs());

          return DecoratedBox(
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
            child: Stack(
              children: [
                Positioned(
                  top: -150 + (18 * orbDriftY),
                  right: -70 + orbDriftX,
                  child: _LaunchOrb(
                    size: size.width * 0.72,
                    opacity: 0.22 + (0.14 * glowReveal),
                    colors: isDark
                        ? [
                            AppColors.primaryBlue.withAlpha(96),
                            AppColors.primaryBlue.withAlpha(2),
                          ]
                        : [
                            AppColors.primaryBlue.withAlpha(70),
                            AppColors.primaryBlue.withAlpha(6),
                          ],
                  ),
                ),
                Positioned(
                  top: size.height * 0.24 - (14 * orbDriftX),
                  left: -110 - (0.6 * orbDriftY),
                  child: _LaunchOrb(
                    size: size.width * 0.58,
                    opacity: 0.18 + (0.12 * glowReveal),
                    colors: isDark
                        ? [
                            AppColors.accentIndigo.withAlpha(88),
                            AppColors.accentIndigo.withAlpha(2),
                          ]
                        : [
                            AppColors.accentIndigo.withAlpha(54),
                            AppColors.accentIndigo.withAlpha(4),
                          ],
                  ),
                ),
                Positioned(
                  bottom: -180 - (10 * orbDriftY),
                  right: size.width * 0.08,
                  child: _LaunchOrb(
                    size: size.width * 0.82,
                    opacity: 0.12 + (0.08 * glowReveal),
                    colors: isDark
                        ? [
                            AppColors.accentGold.withAlpha(44),
                            AppColors.accentGold.withAlpha(1),
                          ]
                        : [
                            AppColors.accentGold.withAlpha(34),
                            AppColors.accentGold.withAlpha(1),
                          ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, (1 - logoReveal) * 42 + logoFloat),
                          child: Opacity(
                            opacity: logoReveal,
                            child: Transform.scale(
                              scale: logoScale,
                              child: SizedBox(
                                width: haloSize,
                                height: haloSize,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: haloScale,
                                      child: Opacity(
                                        opacity: 0.6 * ringReveal,
                                        child: Container(
                                          width: haloSize,
                                          height: haloSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: isDark
                                                  ? [
                                                      Colors.white.withAlpha(
                                                        28,
                                                      ),
                                                      AppColors.primaryBlue
                                                          .withAlpha(28),
                                                      Colors.transparent,
                                                    ]
                                                  : [
                                                      Colors.white.withAlpha(
                                                        180,
                                                      ),
                                                      AppColors.primaryBlue
                                                          .withAlpha(44),
                                                      Colors.transparent,
                                                    ],
                                              stops: const [0.0, 0.56, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.48 * ringReveal,
                                      child: Container(
                                        width: haloSize * 0.88,
                                        height: haloSize * 0.88,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withAlpha(20)
                                                : Colors.white.withAlpha(170),
                                            width: 1.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle:
                                          ((1 - logoReveal) * -0.11) +
                                          (ambientWave * 0.015),
                                      child: Image.asset(
                                        'assets/find-it-symbol-transparent.png',
                                        width: logoSize,
                                        height: logoSize,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Transform.translate(
                          offset: Offset(0, (1 - titleReveal) * 24),
                          child: Opacity(
                            opacity: titleReveal,
                            child: Text(
                              l10n.appName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: size.width < 380 ? 38 : 46,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.2,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 310),
                          child: Transform.translate(
                            offset: Offset(0, (1 - captionReveal) * 20),
                            child: Opacity(
                              opacity: captionReveal,
                              child: Text(
                                l10n.tagline,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 52,
                  child: Opacity(
                    opacity: 0.9 * captionReveal,
                    child: _ProgressGlowBar(
                      progress: readyProgress,
                      glowShift: 0.12 + (0.76 * captionReveal),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LaunchOrb extends StatelessWidget {
  const _LaunchOrb({
    required this.size,
    required this.opacity,
    required this.colors,
  });

  final double size;
  final double opacity;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}

class _ProgressGlowBar extends StatelessWidget {
  const _ProgressGlowBar({required this.progress, required this.glowShift});

  final double progress;
  final double glowShift;

  @override
  Widget build(BuildContext context) {
    final trackColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withAlpha(26)
        : const Color(0x1F0E73FF);

    return SizedBox(
      width: 132,
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      AppColors.primaryBlue,
                      AppColors.accentIndigo,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    transform: _SlidingGradientTransform(glowShift),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.shift);

  final double shift;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (shift - 0.5), 0, 0);
  }
}
