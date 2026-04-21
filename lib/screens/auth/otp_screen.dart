import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/navigation/main_page.dart';
import 'package:flutter_application/screens/auth/profile_setup_screen.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.name,
    this.email,
  });

  final String phone;
  final String name;
  final String? email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  int _secondsLeft = 60;
  bool _resendLoading = false;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _resendTimer?.cancel();
    _secondsLeft = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _error = context.l10n.codeInvalid);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final app = Provider.of<AppState>(context, listen: false);
    final errorMsg = await app.verifyOtpAndLogin(code);

    if (!mounted) return;

    if (errorMsg != null) {
      setState(() {
        _error = localizeAppError(errorMsg, context.l10n);
        _loading = false;
      });
      return;
    }

    if (widget.name.isNotEmpty) {
      // New signup — walk through onboarding
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(name: widget.name),
        ),
        (route) => false,
      );
    } else {
      // Returning user — go straight to app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resendLoading = true;
      _error = null;
    });

    final app = Provider.of<AppState>(context, listen: false);

    await app.resendOtp((error) {
      if (!mounted) return;
      setState(() => _resendLoading = false);
      if (error != null && error.isNotEmpty) {
        setState(() => _error = localizeAppError(error, context.l10n));
      } else if (error == null) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.newCodeSent,
              style: GoogleFonts.manrope(),
            ),
            backgroundColor: AppColors.primaryBlueDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.revealDuration,
                curve: AppMotion.standardCurve,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 26 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: AppPanel(
                          padding: const EdgeInsets.all(12),
                          borderRadius: BorderRadius.circular(18),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPanel(
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.heroNavy,
                          AppColors.heroBlue,
                          AppColors.heroTeal,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(16),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.lock_person_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              l10n.verifyPhone,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.enterCodeSentTo,
                              style: GoogleFonts.manrope(
                                color: Colors.white.withAlpha(204),
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(14),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withAlpha(14),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.phone_android_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.phone,
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.verifyCode,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.codeInvalid,
                            style: GoogleFonts.manrope(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 34,
                              letterSpacing: 12,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '------',
                              hintStyle: GoogleFonts.spaceGrotesk(
                                letterSpacing: 12,
                                color: AppColors.placeholderGray,
                                fontWeight: FontWeight.w700,
                              ),
                              counterText: '',
                              errorText: _error,
                            ),
                            onChanged: (_) => setState(() => _error = null),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _verify,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.accentIndigo,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withAlpha(
                                        56,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          l10n.verifyCode,
                                          style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withAlpha(8)
                                  : AppColors.infoBox,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withAlpha(14)
                                    : AppColors.primaryBlue.withAlpha(18),
                              ),
                            ),
                            child: Center(
                              child: _resendLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : _secondsLeft > 0
                                  ? Text(
                                      l10n.resendCountdown(_secondsLeft),
                                      style: GoogleFonts.manrope(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: _resend,
                                      child: Text(
                                        l10n.resendCode,
                                        style: GoogleFonts.manrope(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w800,
                                        ),
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
            ),
          ),
        ),
      ),
    );
  }
}
