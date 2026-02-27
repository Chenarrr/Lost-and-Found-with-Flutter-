import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
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
    final l10n = context.l10n;
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
                l10n.changeName,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.yourName,
                  errorText: error,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel, style: GoogleFonts.inter()),
                ),
                TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final name = controller.text.trim();
                          if (name.length < 2) {
                            setState(() => error = l10n.nameTooShort);
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
                          l10n.save,
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

  Future<void> _showLanguageDialog(BuildContext context) async {
    final l10n = context.l10n;
    final app = Provider.of<AppState>(context, listen: false);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          l10n.language,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: l10n.english,
              isSelected: app.locale.languageCode == 'en',
              onTap: () {
                app.setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: l10n.arabic,
              isSelected: app.locale.languageCode == 'ar',
              onTap: () {
                app.setLocale(const Locale('ar'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = context.l10n;
    final app = Provider.of<AppState>(context, listen: false);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          l10n.logout,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.logoutConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.logout,
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
    final l10n = context.l10n;
    final app = Provider.of<AppState>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          l10n.deleteAccount,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.deleteAccountConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
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

    if (err == 'requires-recent-login') {
      await _showReauthDialog(context);
      return;
    }

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

  Future<void> _showReauthDialog(BuildContext context) async {
    final l10n = context.l10n;
    final app = Provider.of<AppState>(context, listen: false);
    final phone = app.currentUser?.phone ?? '';
    final codeController = TextEditingController();
    final outerNavigator = Navigator.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool sending = false;
        bool codeSent = false;
        bool deleting = false;
        String? error;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(
                l10n.reauthTitle,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reauthBody(phone), style: GoogleFonts.inter()),
                  if (codeSent) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: l10n.verifyCode,
                        hintText: l10n.codeInvalid,
                        counterText: '',
                      ),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: GoogleFonts.inter(
                        color: AppColors.lostPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: (sending || deleting)
                      ? null
                      : () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel, style: GoogleFonts.inter()),
                ),
                if (!codeSent)
                  TextButton(
                    onPressed: sending
                        ? null
                        : () async {
                            setState(() {
                              sending = true;
                              error = null;
                            });
                            await app.startReauthOtp((err) {
                              if (err != null) {
                                setState(() {
                                  sending = false;
                                  error = err;
                                });
                              } else {
                                setState(() {
                                  sending = false;
                                  codeSent = true;
                                });
                              }
                            });
                          },
                    child: sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            l10n.sendOtp,
                            style: GoogleFonts.inter(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  )
                else
                  TextButton(
                    onPressed: deleting
                        ? null
                        : () async {
                            final code = codeController.text.trim();
                            if (code.length != 6) {
                              setState(() => error = l10n.codeInvalid);
                              return;
                            }
                            setState(() {
                              deleting = true;
                              error = null;
                            });
                            final dialogNavigator = Navigator.of(ctx);
                            final deleteErr = await app.reauthWithOtpAndDelete(
                              code,
                            );
                            if (deleteErr != null) {
                              setState(() {
                                deleting = false;
                                error = deleteErr;
                              });
                            } else {
                              dialogNavigator.pop();
                              outerNavigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                    child: deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            l10n.confirmDelete,
                            style: GoogleFonts.inter(
                              color: AppColors.lostPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userName = context.select<AppState, String>(
      (app) => app.currentUser?.name ?? '',
    );
    final userPhone = context.select<AppState, String>(
      (app) => app.currentUser?.phone ?? '',
    );
    final currentLangCode = context.select<AppState, String>(
      (app) => app.locale.languageCode,
    );
    final currentLangLabel = currentLangCode == 'ar'
        ? l10n.arabic
        : l10n.english;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: GoogleFonts.inter()),
      ),
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
            l10n.account,
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
                  title: l10n.changeName,
                  subtitle: l10n.updateDisplayName,
                  onTap: () => _showChangeNameDialog(context),
                ),

                const Divider(height: 1, color: AppColors.borderGray),

                _tile(
                  icon: Icons.logout,
                  iconBg: AppColors.lostLight,
                  iconFg: AppColors.lostPrimary,
                  title: l10n.logout,
                  subtitle: l10n.signOutDevice,
                  onTap: () => _logout(context),
                ),

                const Divider(height: 1, color: AppColors.borderGray),

                _tile(
                  icon: Icons.delete_forever_rounded,
                  iconBg: AppColors.lostLight,
                  iconFg: AppColors.lostDark,
                  title: l10n.deleteAccount,
                  subtitle: l10n.permanentlyRemove,
                  onTap: () => _deleteAccount(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Preferences section ───────────────────────────────────
          Text(
            l10n.preferences,
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
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.skyTop,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              title: Text(
                l10n.language,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                currentLangLabel,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.iconGray,
              ),
              onTap: () => _showLanguageDialog(context),
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoBox : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
