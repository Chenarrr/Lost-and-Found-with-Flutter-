import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/settings_screen.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:flutter_application/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

String _memberSince(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.year}';
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final app = Provider.of<AppState>(context);
    final user = app.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackdrop(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: AppPanel(
                  child: Text(
                    l10n.pleaseLogInProfile,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final userPosts = app.posts
        .where((post) => post.userId == user.id)
        .toList();
    final lostCount = userPosts
        .where((post) => post.type == PostType.lost)
        .length;
    final foundCount = userPosts.length - lostCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: AppPanel(
                padding: const EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(18),
                child: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 150),
          children: [
            AppPanel(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              gradient: const LinearGradient(
                colors: [
                  AppColors.heroNavy,
                  AppColors.heroBlue,
                  AppColors.heroTeal,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withAlpha(24),
                            ),
                          ),
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.primaryBlue,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user.phone,
                                style: GoogleFonts.manrope(
                                  color: Colors.white.withAlpha(204),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ProfilePill(
                          icon: Icons.calendar_today_rounded,
                          label: l10n.memberSince(_memberSince(user.createdAt)),
                        ),
                        if (user.email?.isNotEmpty == true)
                          _ProfilePill(
                            icon: Icons.alternate_email_rounded,
                            label: user.email!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory_2_rounded,
                    iconColor: AppColors.primaryBlue,
                    iconBg: AppColors.infoBox,
                    count: userPosts.length,
                    label: l10n.posts,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.search_rounded,
                    iconColor: AppColors.lostPrimary,
                    iconBg: AppColors.lostLight,
                    count: lostCount,
                    label: l10n.typeLost,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.foundPrimary,
                    iconBg: AppColors.foundLight,
                    count: foundCount,
                    label: l10n.typeFound,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  l10n.yourPosts,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                AppPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: Text(
                    l10n.totalPosts(userPosts.length),
                    style: GoogleFonts.manrope(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (userPosts.isEmpty)
              AppPanel(
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(16),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primaryBlue,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.noItemsPosted,
                      style: GoogleFonts.manrope(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...userPosts.map(
                (post) => PostCard(key: ValueKey(post.id), post: post),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconBg = isDark ? iconColor.withAlpha(32) : iconBg;

    return AppPanel(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: effectiveIconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
