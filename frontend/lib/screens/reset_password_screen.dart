import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/link_ride_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController resetCodeController = TextEditingController();

  final TextEditingController newPasswordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool _isResetting = false;

  @override
  void dispose() {
    resetCodeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateResetCode(String? value) {
    final String code = value?.trim() ?? '';

    if (code.isEmpty) {
      return 'Please enter the reset code';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Reset code must contain 6 digits';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }

    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (_isResetting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isResetting = true;
    });

    try {
      await _authService.resetPassword(
        email: widget.email,
        resetCode: resetCodeController.text.trim(),
        newPassword: newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. You can now sign in.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isResetting = false;
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
            top: -100,
            right: -90,
            child: _backgroundCircle(
              size: 250,
              color: LinkRideColors.softBlueStrong,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -110,
            child: _backgroundCircle(
              size: 290,
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

                          const SizedBox(height: 24),

                          _resetHeader(),

                          const SizedBox(height: 24),

                          _resetCard(),
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
                Icons.security_rounded,
                size: 15,
                color: LinkRideColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Secure reset',
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

  Widget _resetHeader() {
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
            Icons.password_rounded,
            size: 38,
            color: LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'Create a new password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color: LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Enter the 6-digit reset code sent to ${widget.email} and choose a new password.',
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

  Widget _resetCard() {
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
            'Reset details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LinkRideColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Enter the code from your email and choose a password you can remember.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: LinkRideColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          _fieldLabel('Reset code'),

          const SizedBox(height: 8),

          TextFormField(
            controller: resetCodeController,
            validator: _validateResetCode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: 'Enter 6-digit code',
              counterText: '',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
          ),

          const SizedBox(height: 18),

          _fieldLabel('New password'),

          const SizedBox(height: 8),

          TextFormField(
            controller: newPasswordController,
            validator: _validatePassword,
            obscureText: obscureNewPassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              hintText: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscureNewPassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    obscureNewPassword = !obscureNewPassword;
                  });
                },
                icon: Icon(
                  obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: LinkRideColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LinkRideColors.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: LinkRideColors.linkGreen,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your new password must contain at least 8 characters.',
                    style: TextStyle(
                      fontSize: 12,
                      color: LinkRideColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _fieldLabel('Confirm password'),

          const SizedBox(height: 8),

          TextFormField(
            controller: confirmPasswordController,
            validator: _validateConfirmPassword,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) {
              _resetPassword();
            },
            decoration: InputDecoration(
              hintText: 'Re-enter new password',
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(
                tooltip: obscureConfirmPassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isResetting ? null : _resetPassword,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _isResetting
                    ? const SizedBox(
                        key: ValueKey('reset-password-progress'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        key: ValueKey('reset-password-label'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Reset Password'),
                          SizedBox(width: 8),
                          Icon(Icons.check_rounded, size: 19),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: LinkRideColors.textPrimary,
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
