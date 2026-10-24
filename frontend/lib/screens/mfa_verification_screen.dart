import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/link_ride_theme.dart';

class MfaVerificationScreen extends StatefulWidget {
  final String email;

  const MfaVerificationScreen({super.key, required this.email});

  @override
  State<MfaVerificationScreen> createState() => _MfaVerificationScreenState();
}

class _MfaVerificationScreenState extends State<MfaVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController codeController = TextEditingController();

  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  String? _validateCode(String? value) {
    final String code = value?.trim() ?? '';

    if (code.isEmpty) {
      return 'Please enter the sign-in code';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Sign-in code must contain 6 digits';
    }

    return null;
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();

    if (_isVerifying) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final Map<String, dynamic> response = await _authService.verifyMfa(
        email: widget.email,
        code: codeController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, response);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _resend() async {
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.resendMfaCode(email: widget.email);

      if (!mounted) {
        return;
      }

      codeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new sign-in code has been sent.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: _backgroundCircle(
              size: 250,
              color: LinkRideColors.softBlueStrong,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _backgroundCircle(
              size: 280,
              color: LinkRideColors.softGreenStrong,
            ),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _topBar(),
                          const SizedBox(height: 30),
                          _header(),
                          const SizedBox(height: 26),
                          _verificationCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        _circleIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: LinkRideColors.softBlue,
            borderRadius: BorderRadius.circular(LinkRideRadius.pill),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 15,
                color: LinkRideColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Two-step sign in',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: LinkRideColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: LinkRideColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: LinkRideShadows.elevated,
          ),
          child: const Icon(
            Icons.security_rounded,
            size: 40,
            color: LinkRideColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Confirm it’s you',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color: LinkRideColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password was accepted. We sent a 6-digit sign-in code to\n${widget.email}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _verificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        borderRadius: BorderRadius.circular(LinkRideRadius.extraLarge),
        border: Border.all(color: LinkRideColors.border),
        boxShadow: LinkRideShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign-in code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LinkRideColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Enter the one-time code from your email to finish signing in.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: LinkRideColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: codeController,
            validator: _validateCode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              color: LinkRideColors.primaryBlue,
            ),
            onFieldSubmitted: (_) {
              _verify();
            },
            decoration: const InputDecoration(
              hintText: '000000',
              counterText: '',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isVerifying ? null : _verify,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isVerifying
                  ? const SizedBox(
                      key: ValueKey('mfa-progress'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      key: ValueKey('mfa-label'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm Sign In'),
                        SizedBox(width: 8),
                        Icon(Icons.verified_user_rounded, size: 19),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Didn’t receive the code?',
                style: TextStyle(
                  fontSize: 13,
                  color: LinkRideColors.textSecondary,
                ),
              ),
              const SizedBox(width: 5),
              TextButton(
                onPressed: _isResending ? null : _resend,
                child: Text(_isResending ? 'Sending...' : 'Resend'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LinkRideColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LinkRideColors.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 17,
                  color: LinkRideColors.linkGreen,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sign-in codes expire after 10 minutes and can only be used once. Five incorrect attempts invalidate the code.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: LinkRideColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: LinkRideColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: LinkRideColors.border),
            ),
            child: Icon(icon, size: 21, color: LinkRideColors.primaryBlue),
          ),
        ),
      ),
    );
  }

  Widget _backgroundCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
