import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/otp_screen.dart';
import 'package:flutter_application/utils/phone_input_formatter.dart';
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

  // Signup fields
  final _sName = TextEditingController();
  final _sPhone = TextEditingController();
  final _sEmail = TextEditingController();
  final _sAge = TextEditingController();
  String? _sGender; // 'male' | 'female'

  // Login field
  final _lPhone = TextEditingController();

  final _formKeySignup = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();

  bool _loading = false;

  // 10 digits starting with 7
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
        if (error != null) {
          _showMessage(error, isError: true);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phone: phone,
                name: _sName.text.trim(),
                email: _sEmail.text.trim().isEmpty ? null : _sEmail.text.trim(),
              ),
            ),
          );
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
        if (error != null) {
          _showMessage(error, isError: true);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpScreen(phone: phone, name: '', email: null),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginOrSignup, style: GoogleFonts.inter()),
        actions: const [LangToggle(), SizedBox(width: 12)],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderGray),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentIndigo],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.inter(),
                    tabs: [
                      Tab(text: l10n.loginTab),
                      Tab(text: l10n.signupTab),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildLoginForm(l10n), _buildSignupForm(l10n)],
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            ColoredBox(
              color: Colors.black.withAlpha(35),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  // ── Login form ────────────────────────────────────────────────────────────

  Widget _buildLoginForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Form(
        key: _formKeyLogin,
        child: Column(
          children: [
            _buildPhoneField(
              controller: _lPhone,
              l10n: l10n,
              isRequired: true,
              onSubmitted: (_) => _doLogin(),
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(l10n.sendOtp, _doLogin),
          ],
        ),
      ),
    );
  }

  // ── Signup form ───────────────────────────────────────────────────────────

  Widget _buildSignupForm(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Form(
        key: _formKeySignup,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _sName,
              label: l10n.namePlaceholder,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? l10n.nameTooShort : null,
            ),
            const SizedBox(height: 14),
            _buildPhoneField(controller: _sPhone, l10n: l10n, isRequired: true),
            const SizedBox(height: 14),
            _buildSectionLabel(l10n.genderLabel),
            const SizedBox(height: 8),
            _buildGenderSelector(l10n),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _sAge,
              label: l10n.ageLabel,
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

  // ── Shared widgets ────────────────────────────────────────────────────────

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
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        prefixIcon: Container(
          alignment: Alignment.center,
          width: 64,
          child: Text(
            '+964',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(AppLocalizations l10n) {
    return Row(
      children: [
        _GenderChip(
          label: l10n.genderMale,
          icon: Icons.male_rounded,
          selected: _sGender == 'male',
          onTap: () => setState(() => _sGender = 'male'),
        ),
        const SizedBox(width: 12),
        _GenderChip(
          label: l10n.genderFemale,
          icon: Icons.female_rounded,
          selected: _sGender == 'female',
          onTap: () => setState(() => _sGender = 'female'),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 16)),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.infoBox : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.borderGray,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
