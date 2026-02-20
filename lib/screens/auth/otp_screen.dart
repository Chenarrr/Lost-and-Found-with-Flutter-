import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/routes/main_page.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.name,
    this.email,
    required this.password,
    required this.demoCode,
  });

  final String phone;
  final String name;
  final String? email;
  final String password;
  final String demoCode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }

    final app = Provider.of<AppState>(context, listen: false);
    if (!app.verifyOtp(widget.phone, code)) {
      setState(() => _error = 'Invalid code. Please try again.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    await app.signup(
      name: widget.name,
      phone: widget.phone,
      email: widget.email,
      password: widget.password,
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Phone', style: GoogleFonts.inter()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bannerBg,
                border: Border.all(color: AppColors.bannerBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo mode — no real SMS sent',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.bannerText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your OTP code:',
                    style: GoogleFonts.inter(
                      color: AppColors.bannerText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.demoCode,
                    style: GoogleFonts.inter(
                      color: AppColors.bannerText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Enter the 6-digit code sent to',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.phone,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: GoogleFonts.inter(
                fontSize: 28,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: GoogleFonts.inter(
                  letterSpacing: 10,
                  color: AppColors.placeholderGray,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify & Create Account',
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
