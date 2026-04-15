import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/activity_screen.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'package:flutter_application/screens/post/create_post_sheet.dart';
import 'package:flutter_application/screens/profile_screen.dart';
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
      MaterialPageRoute(
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
    final app = context.watch<AppState>();
    final isDark = app.themeMode == ThemeMode.dark;
    final currentUser = app.currentUser;
    final showHomeAppBar = _selectedIndex == 0;

    return Scaffold(
      extendBody: true,
      appBar: showHomeAppBar
          ? AppBar(
              toolbarHeight: 86,
              titleSpacing: 10,
              leadingWidth: 76,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 0, 14),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withAlpha(58),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'F',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser?.name.isNotEmpty == true
                        ? currentUser!.name
                        : l10n.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    l10n.tagline,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withAlpha(190)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            Color(0xFF09192F),
                            Color(0xFF0D213A),
                            Color(0xFF08111E),
                          ]
                        : const [
                            Color(0xFFF5FAFF),
                            Color(0xFFEAF4FF),
                            Color(0xFFF7FBFF),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                const SizedBox(width: 8),
                _TopAction(icon: Icons.add_rounded, onTap: _openCreatePost),
                const SizedBox(width: 18),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: AppPanel(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          borderRadius: BorderRadius.circular(30),
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
              color: AppColors.primaryBlue.withAlpha(84),
              blurRadius: 26,
              offset: const Offset(0, 14),
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
        padding: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withAlpha(10)
            : Colors.white.withAlpha(218),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : cs.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
