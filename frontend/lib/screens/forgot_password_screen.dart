import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/link_ride_theme.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    final RegExp emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Future<void> sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (_isSending) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final String email = emailController.text.trim();

      final Map<String, dynamic> response = await _authService
          .requestPasswordReset(email: email);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'If that email is linked to a Link Ride account, reset instructions have been sent.',
          ),
        ),
      );

      final bool? resetCompleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: email),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSending = false;
      });

      if (resetCompleted == true) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -110,
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

                          const SizedBox(height: 28),

                          _recoveryHeader(),

                          const SizedBox(height: 28),

                          _recoveryCard(),

                          const SizedBox(height: 20),

                          _signInPrompt(),
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
                Icons.lock_reset_rounded,
                size: 15,
                color: LinkRideColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Account recovery',
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

  Widget _recoveryHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: LinkRideGradients.primarySoft,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: LinkRideColors.border),
            boxShadow: LinkRideShadows.soft,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 38,
            color: LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Reset your password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color: LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 9),

        const Text(
          'Enter the email linked to your Link Ride account and we’ll guide you through the reset process.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _recoveryCard() {
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
            'Account email',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LinkRideColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'We use this address to locate your Link Ride account.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: LinkRideColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Email address',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: LinkRideColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: emailController,
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) {
              sendResetLink();
            },
            decoration: const InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: LinkRideColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LinkRideColors.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: LinkRideColors.primaryBlue,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'We’ll send a one-time reset code to this email address if it is linked to a Link Ride account.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: LinkRideColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSending ? null : sendResetLink,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isSending
                    ? const SizedBox(
                        key: ValueKey('reset-request-progress'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        key: ValueKey('reset-request-label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 19),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Remember your password?',
          style: TextStyle(fontSize: 13, color: LinkRideColors.textSecondary),
        ),

        const SizedBox(width: 5),

        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: LinkRideColors.primaryBlue,
              ),
            ),
          ),
        ),
      ],
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
