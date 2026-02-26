import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _leadingIcon(IconData icon, Color bg, Color fg) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: fg),
  );

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    leading: _leadingIcon(icon, iconBg, iconFg),
    title: Text(
      title,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
    ),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      color: AppColors.iconGray,
    ),
    onTap: onTap,
  );

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<void> _showChangeNameDialog(BuildContext context) async {
    final app = Provider.of<AppState>(context, listen: false);
    final controller = TextEditingController(text: app.currentUser?.name ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        bool loading = false;
        String? error;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(
                'Change Name',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Your name',
                  errorText: error,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: GoogleFonts.inter()),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final name = controller.text.trim();
                          if (name.length < 2) {
                            setState(
                              () => error = 'Enter at least 2 characters',
                            );
                            return;
                          }
                          setState(() {
                            loading = true;
                            error = null;
                          });
                          final navigator = Navigator.of(ctx);
                          final err = await app.updateUserName(name);
                          if (err != null) {
                            setState(() {
                              loading = false;
                              error = err;
                            });
                          } else {
                            navigator.pop();
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final app = Provider.of<AppState>(context, listen: false);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                color: AppColors.lostPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;
    await app.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final app = Provider.of<AppState>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete your account and all your posts. '
          'This cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: AppColors.lostPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final err = await app.deleteAccount();

    if (!context.mounted) return;

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err, style: GoogleFonts.inter()),
          backgroundColor: AppColors.lostPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Use typed primitives — avoids the _dependents.isEmpty assertion that
    // fires when `dynamic` is used and auth state changes during navigation.
    final userName = context.select<AppState, String>(
      (app) => app.currentUser?.name ?? '',
    );
    final userPhone = context.select<AppState, String>(
      (app) => app.currentUser?.phone ?? '',
    );

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.inter())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User info header ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.skyTop, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName.isNotEmpty ? userName : 'Unknown',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userPhone,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Account section ───────────────────────────────────────
          Text(
            'Account',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              children: [
                _tile(
                  icon: Icons.edit_rounded,
                  iconBg: AppColors.infoBox,
                  iconFg: AppColors.primaryBlue,
                  title: 'Change Name',
                  subtitle: 'Update your display name',
                  onTap: () => _showChangeNameDialog(context),
                ),

                const Divider(height: 1, color: AppColors.borderGray),

                _tile(
                  icon: Icons.logout,
                  iconBg: AppColors.lostLight,
                  iconFg: AppColors.lostPrimary,
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  onTap: () => _logout(context),
                ),

                const Divider(height: 1, color: AppColors.borderGray),

                _tile(
                  icon: Icons.delete_forever_rounded,
                  iconBg: AppColors.lostLight,
                  iconFg: AppColors.lostDark,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your account and posts',
                  onTap: () => _deleteAccount(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── App version footer ────────────────────────────────────
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              final version = snap.data != null
                  ? 'Find It  v${snap.data!.version}'
                  : '';
              return Center(
                child: Text(
                  version,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
