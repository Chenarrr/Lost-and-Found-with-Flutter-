import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/phone_input_formatter.dart';
import 'package:flutter_application/routes/main_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // signup
  final _sName = TextEditingController();
  final _sPhone = TextEditingController();
  final _sEmail = TextEditingController();
  final _sPassword = TextEditingController();

  // login
  final _lIdentifier = TextEditingController();
  final _lPassword = TextEditingController();

  final _formKeySignup = GlobalKey<FormState>();
  final _formKeyLogin = GlobalKey<FormState>();
  bool _loading = false;

  // Updated: Accept 11-digit format (0750 222 34 44)
  final phoneReg = RegExp(r'^0\d{10}$');
  final emailReg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _doSignup() async {
    if (!_formKeySignup.currentState!.validate()) return;
    setState(() => _loading = true);
    final app = Provider.of<AppState>(context, listen: false);
    final err = await app.signup(
      name: _sName.text.trim(),
      phone: _sPhone.text.trim(),
      email: _sEmail.text.trim().isEmpty ? null : _sEmail.text.trim(),
      password: _sPassword.text,
    );
    setState(() => _loading = false);
    if (err == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (r) => false,
        );
      }
    } else {
      _showError(err);
    }
  }

  Future<void> _doLogin() async {
    if (!_formKeyLogin.currentState!.validate()) return;
    setState(() => _loading = true);
    final app = Provider.of<AppState>(context, listen: false);
    final err = await app.login(
      identifier: _lIdentifier.text.trim(),
      password: _lPassword.text,
    );
    setState(() => _loading = false);
    if (err == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (r) => false,
        );
      }
    } else {
      _showError(err);
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red[400]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login or Signup', style: GoogleFonts.inter()),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    tabs: [
                      Tab(child: Text('Login', style: GoogleFonts.inter())),
                      Tab(child: Text('Signup', style: GoogleFonts.inter())),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Login
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16),
                          child: Form(
                            key: _formKeyLogin,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _lIdentifier,
                                  label: 'Phone (0750 222 34 44) or Email',
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _lPassword,
                                  label: 'Password',
                                  obscure: true,
                                  validator: (v) {
                                    if (v == null || v.length < 6) {
                                      return 'Minimum 6 chars';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _doLogin,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.inter(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Signup
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16),
                          child: Form(
                            key: _formKeySignup,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _sName,
                                  label: 'Name',
                                  validator: (v) {
                                    if (v == null || v.trim().length < 2) {
                                      return 'Enter at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _sPhone,
                                  label: 'Phone (0750 222 34 44)',
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Phone is required';
                                    }
                                    final clean = v.replaceAll(
                                      RegExp(r'\s'),
                                      '',
                                    );
                                    if (!phoneReg.hasMatch(clean)) {
                                      return 'Enter 11 digits: 0750 222 34 44';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _sEmail,
                                  label: 'Email (optional)',
                                  validator: (v) {
                                    if (v != null &&
                                        v.isNotEmpty &&
                                        !emailReg.hasMatch(v)) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _sPassword,
                                  label: 'Password',
                                  obscure: true,
                                  validator: (v) {
                                    if (v == null || v.length < 6) {
                                      return 'Minimum 6 chars';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _doSignup,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: Text(
                                      'Create account',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      inputFormatters: label.contains('Phone') ? [PhoneInputFormatter()] : [],
      keyboardType: label.contains('Phone')
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
