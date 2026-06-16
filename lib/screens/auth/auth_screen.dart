import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/otp_screen.dart';
import 'package:flutter_application/utils/app_route.dart';
import 'package:flutter_application/utils/phone_input_formatter.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum _AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _sName = TextEditingController();
  final _sPhone = TextEditingController();
  final _sEmail = TextEditingController();
  final _sAge = TextEditingController();
  String? _sGender;

  final _lPhone = TextEditingController();

  var _formKeySignup = GlobalKey<FormState>();
  var _formKeyLogin = GlobalKey<FormState>();

  bool _loading = false;
  _AuthMode _authMode = _AuthMode.login;
  bool _authModeMovesForward = true;

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

  void _setAuthMode(_AuthMode mode) {
    if (_authMode == mode) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _authModeMovesForward = mode.index > _authMode.index;
      _authMode = mode;
      // Recreate the incoming pane's form key so it doesn't collide with the
      // still-animating-out pane that holds the old key instance.
      if (mode == _AuthMode.login) {
        _formKeyLogin = GlobalKey<FormState>();
      } else {
        _formKeySignup = GlobalKey<FormState>();
      }
    });
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

  String _extractLocalPhoneDigits(String fieldValue) {
    final digits = fieldValue.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('964') && digits.length == 13) {
      return digits.substring(3);
    }
    if (digits.startsWith('0') && digits.length == 11) {
      return digits.substring(1);
    }
    return digits;
  }

  String _toE164(String fieldValue) {
    final localDigits = _extractLocalPhoneDigits(fieldValue);
    return '+964$localDigits';
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
          _showMessage(localizeAppError(error, context.l10n), isError: true);
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
          _showMessage(localizeAppError(error, context.l10n), isError: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 40 + bottomInset),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 22),
                    _buildHero(l10n),
                    const SizedBox(height: 18),
                    AppPanel(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      borderRadius: BorderRadius.circular(32),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModeSwitcher(l10n),
                          const SizedBox(height: 20),
                          AnimatedSize(
                            duration: AppMotion.authModeDuration,
                            curve: AppMotion.standardCurve,
                            alignment: Alignment.topCenter,
                            child: ClipRect(
                              child: AnimatedSwitcher(
                                duration: AppMotion.authModeDuration,
                                switchInCurve: AppMotion.enterCurve,
                                switchOutCurve: AppMotion.exitCurve,
                                layoutBuilder:
                                    (currentChild, previousChildren) {
                                      return Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          ...previousChildren,
                                          // ignore: use_null_aware_elements
                                          if (currentChild != null)
                                            currentChild,
                                        ],
                                      );
                                    },
                                transitionBuilder: (child, animation) {
                                  final isIncoming =
                                      child.key ==
                                      ValueKey<_AuthMode>(_authMode);
                                  final horizontalSign = isRtl ? -1.0 : 1.0;
                                  final enterFrom = Offset(
                                    (_authModeMovesForward ? 0.09 : -0.09) *
                                        horizontalSign,
                                    0,
                                  );
                                  final exitTo = Offset(
                                    (_authModeMovesForward ? -0.05 : 0.05) *
                                        horizontalSign,
                                    0,
                                  );
                                  final slide =
                                      Tween<Offset>(
                                        begin: isIncoming
                                            ? enterFrom
                                            : Offset.zero,
                                        end: isIncoming ? Offset.zero : exitTo,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: AppMotion.standardCurve,
                                          reverseCurve: AppMotion.exitCurve,
                                        ),
                                      );
                                  final scale =
                                      Tween<double>(
                                        begin: isIncoming ? 0.985 : 1,
                                        end: isIncoming ? 1 : 0.992,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: AppMotion.standardCurve,
                                          reverseCurve: AppMotion.exitCurve,
                                        ),
                                      );
                                  final fade = CurvedAnimation(
                                    parent: animation,
                                    curve: isIncoming
                                        ? AppMotion.enterCurve
                                        : AppMotion.exitCurve,
                                    reverseCurve: AppMotion.exitCurve,
                                  );
                                  return FadeTransition(
                                    opacity: fade,
                                    child: SlideTransition(
                                      position: slide,
                                      child: ScaleTransition(
                                        scale: scale,
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey<_AuthMode>(_authMode),
                                  child: _authMode == _AuthMode.login
                                      ? _buildLoginPane(l10n)
                                      : _buildSignupPane(l10n),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: AppPanel(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(18),
        child: Icon(
          Icons.arrow_back_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildHero(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      borderRadius: BorderRadius.circular(30),
      borderColor: isDark
          ? Colors.white.withAlpha(18)
          : Colors.white.withAlpha(220),
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF122640).withAlpha(242),
                const Color(0xFF0D1E34).withAlpha(228),
              ]
            : [Colors.white.withAlpha(238), AppColors.mistBlue.withAlpha(115)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withAlpha(40)
              : AppColors.primaryBlue.withAlpha(18),
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withAlpha(12),
                        AppColors.primaryBlue.withAlpha(10),
                      ]
                    : [
                        AppColors.primaryBlue.withAlpha(12),
                        Colors.white.withAlpha(200),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(18)
                    : Colors.white.withAlpha(220),
              ),
            ),
            child: Image.asset(
              'assets/find-it-symbol-transparent.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tagline,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(7) : AppColors.bgGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(12)
              : Theme.of(context).colorScheme.outlineVariant.withAlpha(180),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 6.0;
          final segmentWidth = (constraints.maxWidth - gap) / 2;

          return SizedBox(
            height: 52,
            child: Stack(
              children: [
                AnimatedPositionedDirectional(
                  duration: AppMotion.authModeDuration,
                  curve: AppMotion.standardCurve,
                  start: _authMode == _AuthMode.login ? 0 : segmentWidth + gap,
                  top: 0,
                  width: segmentWidth,
                  height: 52,
                  child: DecoratedBox(
                    key: const ValueKey('auth_mode_indicator'),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withAlpha(34),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        key: const ValueKey('auth_mode_login'),
                        label: l10n.loginTab,
                        icon: Icons.login_rounded,
                        selected: _authMode == _AuthMode.login,
                        onTap: () => _setAuthMode(_AuthMode.login),
                      ),
                    ),
                    const SizedBox(width: gap),
                    Expanded(
                      child: _ModeButton(
                        key: const ValueKey('auth_mode_signup'),
                        label: l10n.signupTab,
                        icon: Icons.person_add_alt_1_rounded,
                        selected: _authMode == _AuthMode.signup,
                        onTap: () => _setAuthMode(_AuthMode.signup),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginPane(AppLocalizations l10n) {
    return Form(
      key: _formKeyLogin,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaneIntro(
              title: l10n.loginTab,
              description: l10n.enterCodeSentTo,
              icon: Icons.shield_rounded,
            ),
            _buildPhoneField(
              controller: _lPhone,
              l10n: l10n,
              isRequired: true,
              onSubmitted: (_) => _doLogin(),
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.verified_user_rounded,
              text: l10n.verifyPhone,
            ),
            const SizedBox(height: 22),
            _buildSubmitButton(l10n.sendOtp, _doLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupPane(AppLocalizations l10n) {
    return Form(
      key: _formKeySignup,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaneIntro(
              title: l10n.signupTab,
              description: l10n.shareDetails,
              icon: Icons.person_add_alt_1_rounded,
            ),
            _buildTextField(
              controller: _sName,
              label: l10n.namePlaceholder,
              icon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? l10n.nameTooShort : null,
            ),
            const SizedBox(height: 14),
            _buildPhoneField(
              controller: _sPhone,
              l10n: l10n,
              isRequired: true,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),
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
              autofillHints: const [AutofillHints.email],
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

  Widget _buildPaneIntro({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.primaryBlue.withAlpha(18)
                  : AppColors.primaryBlue.withAlpha(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required AppLocalizations l10n,
    bool isRequired = false,
    Iterable<String>? autofillHints,
    void Function(String)? onSubmitted,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      inputFormatters: [PhoneInputFormatter()],
      validator: (value) {
        final localDigits = _extractLocalPhoneDigits(value ?? '');
        if (localDigits.isEmpty) {
          return isRequired ? l10n.phoneRequired : null;
        }
        if (!_phoneReg.hasMatch(localDigits)) return l10n.phoneInvalid;
        return null;
      },
      decoration: InputDecoration(
        hintText: l10n.phonePlaceholder,
        prefixIconConstraints: const BoxConstraints(minWidth: 106),
        prefixIcon: SizedBox(
          width: 106,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '+964',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: cs.outlineVariant),
            ],
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
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    super.key,
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
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: AppMotion.interactiveDuration,
              curve: AppMotion.standardCurve,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : cs.onSurface,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: AppMotion.interactiveDuration,
                    switchInCurve: AppMotion.enterCurve,
                    switchOutCurve: AppMotion.exitCurve,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Icon(
                      icon,
                      key: ValueKey<bool>(selected),
                      size: 18,
                      color: selected ? Colors.white : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(12)
              : AppColors.primaryBlue.withAlpha(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withAlpha(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
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
        duration: AppMotion.interactiveDuration,
        curve: AppMotion.standardCurve,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
