import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/auth/otp_screen.dart';
import 'package:flutter_application/widgets/phone_input_formatter.dart';
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

  final _lIdentifier = TextEditingController();

  final _formKeySignup = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();

  bool _loading = false;

  final _phoneReg = RegExp(r'^0\d{10}$');
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
    _lIdentifier.dispose();
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

  Future<void> _doSignup() async {
    if (!_formKeySignup.currentState!.validate()) return;
    final app = Provider.of<AppState>(context, listen: false);
    final phone = _sPhone.text.trim().replaceAll(RegExp(r'\s'), '');

    setState(() => _loading = true);

    await app.initiateOtpSignup(
      name: _sName.text.trim(),
      phone: phone,
      email: _sEmail.text.trim().isEmpty ? null : _sEmail.text.trim(),
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
                password: '', // unused
                demoCode: '', // no demo code anymore
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
    final phone = _lIdentifier.text.trim();

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
              builder: (_) => OtpScreen(
                phone: phone,
                name: '',
                email: null,
                password: '',
                demoCode: '', // no demo code anymore
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login or Signup', style: GoogleFonts.inter()),
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
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(child: Text('Login', style: GoogleFonts.inter())),
                      Tab(child: Text('Signup', style: GoogleFonts.inter())),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 16),
                        child: Form(
                          key: _formKeyLogin,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _lIdentifier,
                                label: 'Phone (0750 222 34 44)',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [PhoneInputFormatter()],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _doLogin(),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _doLogin,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    'Send OTP',
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 16),
                        child: Form(
                          key: _formKeySignup,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _sName,
                                label: 'Name',
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 2) {
                                    return 'Enter at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _sPhone,
                                label: 'Phone (0750 222 34 44)',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [PhoneInputFormatter()],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Phone is required';
                                  }
                                  final clean = value.replaceAll(
                                    RegExp(r'\s'),
                                    '',
                                  );
                                  if (!_phoneReg.hasMatch(clean)) {
                                    return 'Enter 11 digits: 0750 222 34 44';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _sEmail,
                                label: 'Email (optional)',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _doSignup(),
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty &&
                                      !_emailReg.hasMatch(value.trim())) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _doSignup,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    'Send OTP',
                                    style: GoogleFonts.inter(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
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
              color: Colors.black.withAlpha(35),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
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
}
