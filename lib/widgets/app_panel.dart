import 'package:flutter/material.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
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
                      ? const Color(0xFF151E2E)
                      : Colors.white.withAlpha(244))
            : null,
        borderRadius: borderRadius,
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? const Color(0xFF334155)
                  : cs.outlineVariant.withAlpha(210)),
        ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(18)
                    : const Color(0x0F082956),
                blurRadius: isDark ? 8 : 18,
                offset: const Offset(0, 5),
              ),
            ],
      ),
      clipBehavior: clipBehavior,
      child: Padding(padding: padding, child: child),
    );
  }
}
