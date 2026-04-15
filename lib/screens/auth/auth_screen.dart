import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/otp_screen.dart';
import 'package:flutter_application/utils/phone_input_formatter.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:flutter_application/widgets/lang_toggle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            MaterialPageRoute(
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
            MaterialPageRoute(
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
      resizeToAvoidBottomInset: false,
      body: AppBackdrop(
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 28 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const Center(child: LangToggle()),
                        const SizedBox(height: 20),
                        AppPanel(
                          padding: EdgeInsets.zero,
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
                          child: Stack(
                            children: [
                              Positioned(
                                top: -32,
                                right: -10,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withAlpha(16),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.loginOrSignup,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.tagline,
                                      style: GoogleFonts.manrope(
                                        color: Colors.white.withAlpha(204),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _HeroPill(
                                          icon: Icons.login_rounded,
                                          label: l10n.loginTab,
                                        ),
                                        _HeroPill(
                                          icon: Icons.person_add_alt_1_rounded,
                                          label: l10n.signupTab,
                                        ),
                                        _HeroPill(
                                          icon: Icons.sms_rounded,
                                          label: l10n.sendOtp,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppPanel(
                          padding: const EdgeInsets.all(10),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.accentIndigo,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withAlpha(52),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            dividerColor: Colors.transparent,
                            labelColor: Colors.white,
                            unselectedLabelColor: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            labelStyle: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                            unselectedLabelStyle: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            tabs: [
                              Tab(text: l10n.loginTab),
                              Tab(text: l10n.signupTab),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 620,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLoginPane(l10n),
                              _buildSignupPane(l10n),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildLoginPane(AppLocalizations l10n) {
    return AppPanel(
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
            const Spacer(),
            _buildSubmitButton(l10n.sendOtp, _doLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupPane(AppLocalizations l10n) {
    return AppPanel(
      child: Form(
        key: _formKeySignup,
        child: SingleChildScrollView(
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
                validator: (v) => (v == null || v.trim().length < 2)
                    ? l10n.nameTooShort
                    : null,
              ),
              const SizedBox(height: 14),
              _buildPhoneField(
                controller: _sPhone,
                l10n: l10n,
                isRequired: true,
              ),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
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
        duration: const Duration(milliseconds: 220),
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
                    color: AppColors.primaryBlue.withAlpha(50),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
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
