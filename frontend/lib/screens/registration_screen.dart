import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/link_ride_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState
    extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }

    final List<String> parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.length < 2) {
      return 'Please enter your first and last name';
    }

    return null;
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please create a password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> createAccount() async {
    FocusScope.of(context).unfocus();

    if (_isCreatingAccount) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final List<String> nameParts =
        fullNameController.text
            .trim()
            .split(RegExp(r'\s+'))
            .where(
              (part) => part.isNotEmpty,
            )
            .toList();

    final String firstName = nameParts.first;

    final String lastName =
        nameParts.skip(1).join(' ');

    setState(() {
      _isCreatingAccount = true;
    });

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) {
        return;
      }

      final String registeredEmail =
          emailController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. You can now sign in.',
          ),
        ),
      );

      Navigator.pop(
        context,
        registeredEmail,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCreatingAccount = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
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
              size: 260,
              color: LinkRideColors.softBlueStrong,
            ),
          ),
          Positioned(
            bottom: -130,
            left: -110,
            child: _backgroundCircle(
              size: 300,
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
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _topBar(),

                          const SizedBox(height: 12),

                          _brandHeader(),

                          const SizedBox(height: 26),

                          _registrationCard(),

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
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: LinkRideColors.softBlue,
            borderRadius:
                BorderRadius.circular(
              LinkRideRadius.pill,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                size: 15,
                color:
                    LinkRideColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                'Create account',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color:
                      LinkRideColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _brandHeader() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: LinkRideColors.surface,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow:
                LinkRideShadows.elevated,
          ),
          child: Image.asset(
            'assets/link_ride_logo.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Join Link Ride',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color:
                LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Create your account and keep every journey, ticket and travel update connected.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color:
                LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _registrationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color: LinkRideColors.border,
        ),
        boxShadow: LinkRideShadows.soft,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Your details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  LinkRideColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Use your everyday contact details to create your Link Ride account.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color:
                  LinkRideColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          _fieldLabel('Full name'),

          const SizedBox(height: 8),

          TextFormField(
            controller: fullNameController,
            validator: validateName,
            textInputAction:
                TextInputAction.next,
            textCapitalization:
                TextCapitalization.words,
            autofillHints: const [
              AutofillHints.name,
            ],
            decoration:
                const InputDecoration(
              hintText:
                  'First and last name',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
              ),
            ),
          ),

          const SizedBox(height: 18),

          _fieldLabel('Email address'),

          const SizedBox(height: 8),

          TextFormField(
            controller: emailController,
            validator: validateEmail,
            keyboardType:
                TextInputType.emailAddress,
            textInputAction:
                TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
            ],
            decoration:
                const InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
              ),
            ),
          ),

          const SizedBox(height: 18),

          _fieldLabel('Password'),

          const SizedBox(height: 8),

          TextFormField(
            controller: passwordController,
            validator: validatePassword,
            obscureText: obscurePassword,
            textInputAction:
                TextInputAction.next,
            autofillHints: const [
              AutofillHints.newPassword,
            ],
            decoration: InputDecoration(
              hintText: 'Create a password',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
              ),
              suffixIcon: IconButton(
                tooltip: obscurePassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    obscurePassword =
                        !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color:
                  LinkRideColors.surfaceSoft,
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: LinkRideColors.border,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons
                      .verified_user_outlined,
                  size: 16,
                  color:
                      LinkRideColors.linkGreen,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use at least 8 characters.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          LinkRideColors
                              .textSecondary,
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
            controller:
                confirmPasswordController,
            validator:
                validateConfirmPassword,
            obscureText:
                obscureConfirmPassword,
            textInputAction:
                TextInputAction.done,
            autofillHints: const [
              AutofillHints.newPassword,
            ],
            onFieldSubmitted: (_) {
              createAccount();
            },
            decoration: InputDecoration(
              hintText:
                  'Re-enter your password',
              prefixIcon: const Icon(
                Icons
                    .lock_reset_outlined,
              ),
              suffixIcon: IconButton(
                tooltip:
                    obscureConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                onPressed: () {
                  setState(() {
                    obscureConfirmPassword =
                        !obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons
                          .visibility_off_outlined,
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _isCreatingAccount
                      ? null
                      : createAccount,
              child: AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                child: _isCreatingAccount
                    ? const SizedBox(
                        key: ValueKey(
                          'register-progress',
                        ),
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        key: ValueKey(
                          'register-label',
                        ),
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Text(
                            'Create Account',
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 19,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color:
                    LinkRideColors.textMuted,
              ),
              SizedBox(width: 6),
              Text(
                'Your account details are handled securely',
                style: TextStyle(
                  fontSize: 11.5,
                  color:
                      LinkRideColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signInPrompt() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            fontSize: 13,
            color:
                LinkRideColors.textSecondary,
          ),
        ),

        const SizedBox(width: 5),

        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius:
              BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 5,
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color:
                    LinkRideColors.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color:
            LinkRideColors.textPrimary,
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
          customBorder:
              const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    LinkRideColors.border,
              ),
            ),
            child: Icon(
              icon,
              size: 21,
              color:
                  LinkRideColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _backgroundCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}