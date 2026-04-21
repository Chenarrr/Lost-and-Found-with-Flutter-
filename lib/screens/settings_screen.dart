import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/welcome_screen.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _leadingIcon(IconData icon, Color bg, Color fg) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: fg, size: 20),
  );

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adaptedBg = isDark ? iconFg.withAlpha(40) : iconBg;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      leading: _leadingIcon(icon, adaptedBg, iconFg),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.manrope(
          color: cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<void> _showChangeNameDialog(BuildContext context) async {
    final l10n = context.l10n;
    final app = Provider.of<AppState>(context, listen: false);
    final controller = TextEditingController(text: app.currentUser?.name ?? '');

    await showDialog<void>(
      context: context,
      animationStyle: AppMotion.dialogStyle,
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
                          if (!ctx.mounted) return;
                          if (err != null) {
                            setState(() {
                              loading = false;
                              error = localizeAppError(err, l10n);
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
      animationStyle: AppMotion.dialogStyle,
      builder: (dialogCtx) => AlertDialog(
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
                Navigator.of(dialogCtx).pop();
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: l10n.arabic,
              isSelected: app.locale.languageCode == 'ar',
              onTap: () {
                app.setLocale(const Locale('ar'));
                Navigator.of(dialogCtx).pop();
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: l10n.kurdish,
              isSelected: app.locale.languageCode == 'ckb',
              onTap: () {
                app.setLocale(const Locale('ckb'));
                Navigator.of(dialogCtx).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
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
      animationStyle: AppMotion.dialogStyle,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          l10n.logout,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.logoutConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
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
      animationStyle: AppMotion.dialogStyle,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          l10n.deleteAccount,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.deleteAccountConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
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
          content: Text(
            localizeAppError(err, l10n),
            style: GoogleFonts.inter(),
          ),
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
      animationStyle: AppMotion.dialogStyle,
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
                              if (!ctx.mounted) return;
                              if (err == null) {
                                setState(() {
                                  sending = false;
                                  codeSent = true;
                                });
                              } else if (err.isNotEmpty) {
                                setState(() {
                                  sending = false;
                                  error = localizeAppError(err, l10n);
                                });
                              } else {
                                // empty = user cancelled reCAPTCHA
                                setState(() => sending = false);
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
                            if (!ctx.mounted) return;
                            if (deleteErr != null) {
                              setState(() {
                                deleting = false;
                                error = localizeAppError(deleteErr, l10n);
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
    final cs = Theme.of(context).colorScheme;
    final app = context.read<AppState>();
    final userName = context.select<AppState, String>(
      (state) => state.currentUser?.name ?? '',
    );
    final userPhone = context.select<AppState, String>(
      (state) => state.currentUser?.phone ?? '',
    );
    final currentLangCode = context.select<AppState, String>(
      (state) => state.locale.languageCode,
    );
    final currentLangLabel = currentLangCode == 'ar'
        ? l10n.arabic
        : currentLangCode == 'ckb'
        ? l10n.kurdish
        : l10n.english;
    final displayUserName = localizedUserName(userName, l10n);
    final isDark =
        context.select<AppState, ThemeMode>((state) => state.themeMode) ==
        ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: AppBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
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
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayUserName.isNotEmpty
                              ? displayUserName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppColors.primaryBlue,
                            fontSize: 24,
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
                            displayUserName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userPhone,
                            style: GoogleFonts.manrope(
                              color: Colors.white.withAlpha(204),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_appVersion.isNotEmpty)
                            Text(
                              l10n.appVersionLabel(_appVersion),
                              style: GoogleFonts.manrope(
                                color: Colors.white.withAlpha(190),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppPanel(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _leadingIcon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  isDark
                      ? AppColors.primaryBlue.withAlpha(40)
                      : AppColors.infoBox,
                  AppColors.primaryBlue,
                ),
                title: Text(
                  l10n.darkMode,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  l10n.preferences,
                  style: GoogleFonts.manrope(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) =>
                      app.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.account,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            AppPanel(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  _tile(
                    context,
                    icon: Icons.edit_rounded,
                    iconBg: AppColors.infoBox,
                    iconFg: AppColors.primaryBlue,
                    title: l10n.changeName,
                    subtitle: l10n.updateDisplayName,
                    onTap: () => _showChangeNameDialog(context),
                  ),
                  Divider(height: 1, color: cs.outlineVariant),
                  _tile(
                    context,
                    icon: Icons.logout_rounded,
                    iconBg: AppColors.lostLight,
                    iconFg: AppColors.lostPrimary,
                    title: l10n.logout,
                    subtitle: l10n.signOutDevice,
                    onTap: () => _logout(context),
                  ),
                  Divider(height: 1, color: cs.outlineVariant),
                  _tile(
                    context,
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
            Text(
              l10n.preferences,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            AppPanel(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                leading: _leadingIcon(
                  Icons.language_rounded,
                  isDark
                      ? AppColors.primaryBlue.withAlpha(40)
                      : AppColors.skyTop,
                  AppColors.primaryBlue,
                ),
                title: Text(
                  l10n.language,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  currentLangLabel,
                  style: GoogleFonts.manrope(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: () => _showLanguageDialog(context),
              ),
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : cs.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : cs.onSurface,
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
