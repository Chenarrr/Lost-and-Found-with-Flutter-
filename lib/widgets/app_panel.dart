import 'package:flutter/material.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.gradient,
    this.color,
    this.borderColor,
    this.boxShadow,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? color ??
                  (isDark
                      ? const Color(0xFF102038).withAlpha(228)
                      : Colors.white.withAlpha(236))
            : null,
        borderRadius: borderRadius,
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? Colors.white.withAlpha(18)
                  : cs.outlineVariant.withAlpha(210)),
        ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(42)
                    : const Color(0x14082956),
                blurRadius: isDark ? 24 : 28,
                offset: const Offset(0, 16),
              ),
            ],
      ),
      clipBehavior: clipBehavior,
      child: Padding(padding: padding, child: child),
    );
  }
}
