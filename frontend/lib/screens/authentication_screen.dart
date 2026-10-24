import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../theme/link_ride_theme.dart';
import 'forgot_password_screen.dart';
import 'main_navigation_screen.dart';
import 'registration_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final AuthStorage _authStorage = AuthStorage();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool obscurePassword = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (_isSigningIn) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      final Map<String, dynamic> response =
          await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final String token =
          response['token'] as String;

      final String firstName =
          response['user']['firstName'] as String;

      final int userId =
          response['user']['userId'] as int;

      await _authStorage.saveToken(token);
      await _authStorage.saveFirstName(firstName);
      await _authStorage.saveUserId(userId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome back, $firstName!',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(
            firstName: firstName,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningIn = false;
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

  void forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ForgotPasswordScreen(),
      ),
    );
  }

  Future<void> createAccount() async {
    final String? registeredEmail =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RegistrationScreen(),
      ),
    );

    if (!mounted ||
        registeredEmail == null ||
        registeredEmail.isEmpty) {
      return;
    }

    setState(() {
      emailController.text = registeredEmail;
      passwordController.clear();
    });

    passwordFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -100,
            child: _backgroundCircle(
              size: 250,
              color: LinkRideColors.softBlueStrong,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -90,
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
                padding: const EdgeInsets.fromLTRB(
                  22,
                  24,
                  22,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _brandHeader(),

                          const SizedBox(height: 28),

                          _loginCard(),

                          const SizedBox(height: 22),

                          _accountPrompt(),
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

  Widget _brandHeader() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LinkRideColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: LinkRideShadows.elevated,
          ),
          child: Image.asset(
            'assets/link_ride_logo.png',
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Sign in to keep your journeys, tickets and travel updates in one place.',
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

  Widget _loginCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        borderRadius: BorderRadius.circular(
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
            'Sign in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LinkRideColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Enter your account details below.',
            style: TextStyle(
              fontSize: 13,
              color: LinkRideColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          _fieldLabel('Email address'),

          const SizedBox(height: 8),

          TextFormField(
            controller: emailController,
            focusNode: emailFocusNode,
            validator: validateEmail,
            keyboardType:
                TextInputType.emailAddress,
            textInputAction:
                TextInputAction.next,
            autofillHints: const [
              AutofillHints.email,
            ],
            onFieldSubmitted: (_) {
              passwordFocusNode.requestFocus();
            },
            decoration: const InputDecoration(
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
            focusNode: passwordFocusNode,
            validator: validatePassword,
            obscureText: obscurePassword,
            textInputAction:
                TextInputAction.done,
            autofillHints: const [
              AutofillHints.password,
            ],
            onFieldSubmitted: (_) {
              login();
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
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

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: forgotPassword,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Forgot password?',
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _isSigningIn ? null : login,
              child: AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 180),
                child: _isSigningIn
                    ? const SizedBox(
                        key: ValueKey(
                          'login-progress',
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
                          'login-label',
                        ),
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text('Sign In'),
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

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: LinkRideColors.softBlue,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color:
                      LinkRideColors.primaryBlue,
                ),
                SizedBox(width: 7),
                Text(
                  'Secure authenticated sign in',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        LinkRideColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountPrompt() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: LinkRideColors.surface
            .withValues(alpha: 0.84),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        border: Border.all(
          color: LinkRideColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Flexible(
            child: Text(
              'New to Link Ride?',
              style: TextStyle(
                fontSize: 13,
                color:
                    LinkRideColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: 5),

          InkWell(
            onTap: createAccount,
            borderRadius:
                BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              child: Text(
                'Create Account',
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