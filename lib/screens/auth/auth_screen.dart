import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/otp_screen.dart';
import 'package:flutter_application/utils/app_route.dart';
import 'package:flutter_application/utils/phone_input_formatter.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int _tab = 0; // 0 = login, 1 = signup

  final _sName = TextEditingController();
  final _sPhone = TextEditingController();
  final _sEmail = TextEditingController();
  final _sAge = TextEditingController();
  String? _sGender;

  final _lPhone = TextEditingController();

  final _formKeySignup = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();

  bool _loading = false;

  final _phoneReg = RegExp(r'^7\d{9}$');
  final _emailReg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  @override
  void dispose() {
    _sName.dispose();
    _sPhone.dispose();
    _sEmail.dispose();
    _sAge.dispose();
    _lPhone.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.lostPrimary
            : AppColors.primaryBlueDark,
      ),
    );
  }

  String _toE164(String fieldValue) {
    final digits = fieldValue.replaceAll(RegExp(r'\s'), '');
    return '+964$digits';
  }

  Future<void> _doSignup() async {
    if (!_formKeySignup.currentState!.validate()) return;
    if (_sGender == null) {
      _showMessage(context.l10n.genderRequired, isError: true);
      return;
    }

    final app = Provider.of<AppState>(context, listen: false);
    final phone = _toE164(_sPhone.text.trim());

    setState(() => _loading = true);

    await app.initiateOtpSignup(
      name: _sName.text.trim(),
      phone: phone,
      email: _sEmail.text.trim().isEmpty ? null : _sEmail.text.trim(),
      gender: _sGender,
      age: int.tryParse(_sAge.text.trim()),
      onCodeSent: (error) {
        if (!mounted) return;
        setState(() => _loading = false);
        if (error == null) {
          Navigator.of(context).push(
            smoothRoute(
              builder: (_) => OtpScreen(
                phone: phone,
                name: _sName.text.trim(),
                email: _sEmail.text.trim().isEmpty ? null : _sEmail.text.trim(),
              ),
            ),
          );
        } else if (error.isNotEmpty) {
          _showMessage(error, isError: true);
        }
      },
    );
  }

  Future<void> _doLogin() async {
    if (!_formKeyLogin.currentState!.validate()) return;

    final app = Provider.of<AppState>(context, listen: false);
    final phone = _toE164(_lPhone.text.trim());

    setState(() => _loading = true);
    await app.initiateOtpLogin(
      phone: phone,
      onCodeSent: (error) {
        if (!mounted) return;
        setState(() => _loading = false);
        if (error == null) {
          Navigator.of(context).push(
            smoothRoute(
              builder: (_) => OtpScreen(phone: phone, name: '', email: null),
            ),
          );
        } else if (error.isNotEmpty) {
          _showMessage(error, isError: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: AppPanel(
                        padding: const EdgeInsets.all(12),
                        borderRadius: BorderRadius.circular(18),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Hero panel
                    AppPanel(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      clipBehavior: Clip.antiAlias,
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [
                                Color(0xFF0B1F3C),
                                Color(0xFF113463),
                                Color(0xFF0C697F),
                              ]
                            : const [
                                AppColors.heroNavy,
                                AppColors.heroBlue,
                                AppColors.heroTeal,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.loginOrSignup,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.tagline,
                            style: GoogleFonts.manrope(
                              color: Colors.white.withAlpha(180),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Segmented toggle
                    _SegmentedToggle(
                      selected: _tab,
                      loginLabel: l10n.loginTab,
                      signupLabel: l10n.signupTab,
                      onTap: (i) => setState(() => _tab = i),
                    ),
                    const SizedBox(height: 16),
                    // Animated content switch
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final fade = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );
                        final slide =
                            Tween(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            );
                        return FadeTransition(
                          opacity: fade,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _tab == 0
                          ? _buildLoginPane(l10n, key: const ValueKey(0))
                          : _buildSignupPane(l10n, key: const ValueKey(1)),
                    ),
                  ],
                ),
              ),
              if (_loading)
                ColoredBox(
                  color: Colors.black.withAlpha(50),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPane(AppLocalizations l10n, {Key? key}) {
    return AppPanel(
      key: key,
      child: Form(
        key: _formKeyLogin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.loginTab,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enterCodeSentTo,
              style: GoogleFonts.manrope(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildPhoneField(
              controller: _lPhone,
              l10n: l10n,
              isRequired: true,
              onSubmitted: (_) => _doLogin(),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              icon: Icons.verified_user_rounded,
              text: l10n.verifyPhone,
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(l10n.sendOtp, _doLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupPane(AppLocalizations l10n, {Key? key}) {
    return AppPanel(
      key: key,
      child: Form(
        key: _formKeySignup,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.signupTab,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.shareDetails,
              style: GoogleFonts.manrope(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _sName,
              label: l10n.namePlaceholder,
              icon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? l10n.nameTooShort : null,
            ),
            const SizedBox(height: 14),
            _buildPhoneField(controller: _sPhone, l10n: l10n, isRequired: true),
            const SizedBox(height: 14),
            _buildSectionLabel(l10n.genderLabel),
            const SizedBox(height: 10),
            _buildGenderSelector(l10n),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _sAge,
              label: l10n.ageLabel,
              icon: Icons.cake_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.ageRequired;
                final age = int.tryParse(v.trim());
                if (age == null || age < 13 || age > 100) {
                  return l10n.ageInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _sEmail,
              label: l10n.emailPlaceholder,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _doSignup(),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    !_emailReg.hasMatch(v.trim())) {
                  return l10n.emailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _buildSubmitButton(l10n.sendOtp, _doSignup),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required AppLocalizations l10n,
    bool isRequired = false,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      inputFormatters: [PhoneInputFormatter()],
      validator: (value) {
        final clean = (value ?? '').replaceAll(RegExp(r'\s'), '');
        if (clean.isEmpty) {
          return isRequired ? l10n.phoneRequired : null;
        }
        if (!_phoneReg.hasMatch(clean)) return l10n.phoneInvalid;
        return null;
      },
      decoration: InputDecoration(
        labelText: l10n.phonePlaceholder,
        prefixIconConstraints: const BoxConstraints(minWidth: 92),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Center(
            widthFactor: 1,
            child: Text(
              '+964',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _GenderChip(
            label: l10n.genderMale,
            icon: Icons.male_rounded,
            selected: _sGender == 'male',
            onTap: () => setState(() => _sGender = 'male'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GenderChip(
            label: l10n.genderFemale,
            icon: Icons.female_rounded,
            selected: _sGender == 'female',
            onTap: () => setState(() => _sGender = 'female'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentIndigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha(62),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Segmented toggle ─────────────────────────────────────────────────────────

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.selected,
    required this.loginLabel,
    required this.signupLabel,
    required this.onTap,
  });

  final int selected;
  final String loginLabel;
  final String signupLabel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          _ToggleTab(
            label: loginLabel,
            selected: selected == 0,
            onTap: () => onTap(0),
          ),
          _ToggleTab(
            label: signupLabel,
            selected: selected == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(46),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : cs.onSurfaceVariant,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

// ── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : AppColors.infoBox,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(12)
              : AppColors.primaryBlue.withAlpha(18),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gender chip ──────────────────────────────────────────────────────────────

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                )
              : null,
          color: selected
              ? null
              : isDark
              ? Colors.white.withAlpha(8)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : isDark
                ? Colors.white.withAlpha(14)
                : AppColors.borderGray,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withAlpha(44),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
