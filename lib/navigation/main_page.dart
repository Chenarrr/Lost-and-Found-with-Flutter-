import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/activity_screen.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'package:flutter_application/screens/post/create_post_sheet.dart';
import 'package:flutter_application/screens/profile_screen.dart';
import 'package:flutter_application/utils/app_route.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  void _openCreatePost() {
    Navigator.of(context).push(
      smoothRoute(
        builder: (_) => CreatePostSheet(
          onGoHome: () {
            if (!mounted) return;
            setState(() => _selectedIndex = 0);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final app = context.read<AppState>();
    final currentUserName = context.select<AppState, String?>(
      (state) => state.currentUser?.name,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showHomeAppBar = _selectedIndex == 0;

    return Scaffold(
      extendBody: true,
      appBar: showHomeAppBar
          ? AppBar(
              titleSpacing: 12,
              leadingWidth: 60,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 0, 10),
                child: _AppLogo(isDark: isDark),
              ),
              title: Text(
                currentUserName?.isNotEmpty == true
                    ? currentUserName!
                    : l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                _TopAction(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  onTap: () => app.setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  ),
                ),
                const SizedBox(width: 14),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: AppPanel(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          borderRadius: BorderRadius.circular(26),
          color: isDark
              ? const Color(0xFF102038).withAlpha(236)
              : Colors.white.withAlpha(236),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.homeNav,
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.auto_graph_rounded,
                  label: l10n.activityNav,
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: l10n.profileNav,
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentIndigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(70),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openCreatePost,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          label: Text(
            l10n.postFab,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/find-it-app-icon-official.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF102038),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF233955)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          'assets/find-it-symbol-transparent.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AppPanel(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0xFF102038) : Colors.white.withAlpha(218),
        borderColor: isDark ? const Color(0xFF233955) : null,
        child: Icon(
          icon,
          size: 20,
          color: isDark
              ? const Color(0xFFF2F7FF)
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.interactiveDuration,
        curve: AppMotion.standardCurve,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryBlue.withAlpha(isDark ? 42 : 20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryBlue : cs.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primaryBlue : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
