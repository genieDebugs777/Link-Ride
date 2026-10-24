import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/profile_service.dart';
import '../theme/link_ride_theme.dart';

class ChangePasswordScreen
    extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen>
      createState() =>
          _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      _currentPasswordController =
      TextEditingController();

  final TextEditingController
      _newPasswordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  final AuthStorage _authStorage =
      AuthStorage();

  final ProfileService _profileService =
      ProfileService();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  bool _isUpdatingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text ==
        _currentPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'New password must be different from current password.',
          ),
        ),
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null) {
        throw Exception(
          'Your session is no longer available. Please log in again.',
        );
      }

      await _profileService.changePassword(
        token: token,
        currentPassword:
            _currentPasswordController.text,
        newPassword:
            _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password updated successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      String message =
          error.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        message = message.substring(
          'Exception: '.length,
        );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () =>
              Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Change Password',
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _headerCard(),

                const SizedBox(height: 24),

                _sectionTitle(
                  'PASSWORD',
                ),

                _passwordCard(
                  child: Column(
                    children: [
                      _passwordField(
                        controller:
                            _currentPasswordController,
                        label:
                            'Current Password',
                        hint:
                            'Enter your current password',
                        obscureText:
                            _hideCurrentPassword,
                        onToggleVisibility:
                            () {
                          setState(() {
                            _hideCurrentPassword =
                                !_hideCurrentPassword;
                          });
                        },
                        validator:
                            (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Current password is required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      _passwordField(
                        controller:
                            _newPasswordController,
                        label:
                            'New Password',
                        hint:
                            'Enter your new password',
                        obscureText:
                            _hideNewPassword,
                        onToggleVisibility:
                            () {
                          setState(() {
                            _hideNewPassword =
                                !_hideNewPassword;
                          });
                        },
                        validator:
                            (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'New password is required';
                          }

                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      _passwordField(
                        controller:
                            _confirmPasswordController,
                        label:
                            'Confirm New Password',
                        hint:
                            'Re-enter your new password',
                        obscureText:
                            _hideConfirmPassword,
                        textInputAction:
                            TextInputAction.done,
                        onFieldSubmitted:
                            (_) {
                          if (!_isUpdatingPassword) {
                            _changePassword();
                          }
                        },
                        onToggleVisibility:
                            () {
                          setState(() {
                            _hideConfirmPassword =
                                !_hideConfirmPassword;
                          });
                        },
                        validator:
                            (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Please confirm your new password';
                          }

                          if (value !=
                              _newPasswordController
                                  .text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _securityGuidance(),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child:
                      FilledButton.icon(
                    onPressed:
                        _isUpdatingPassword
                            ? null
                            : _changePassword,
                    icon: _isUpdatingPassword
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .lock_reset_rounded,
                            size: 19,
                          ),
                    label: Text(
                      _isUpdatingPassword
                          ? 'Updating Password...'
                          : 'Update Password',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            LinkRideGradients.primarySoft,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color:
              LinkRideColors.primaryBlue
                  .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .lock_reset_rounded,
              size: 25,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure your account',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Verify your current password before choosing a new one.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          LinkRideDecorations.card(),
      child: child,
    );
  }

  Widget _passwordField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback
        onToggleVisibility,
    required String? Function(String?)
        validator,
    TextInputAction textInputAction =
        TextInputAction.next,
    ValueChanged<String>?
        onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w800,
            color:
                LinkRideColors
                    .textPrimary,
          ),
        ),

        const SizedBox(height: 7),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          textInputAction:
              textInputAction,
          onFieldSubmitted:
              onFieldSubmitted,
          style: const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
            color:
                LinkRideColors
                    .textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(
              Icons
                  .lock_outline_rounded,
              size: 20,
            ),
            suffixIcon: IconButton(
              tooltip: obscureText
                  ? 'Show password'
                  : 'Hide password',
              onPressed:
                  onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons
                        .visibility_outlined
                    : Icons
                        .visibility_off_outlined,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _securityGuidance() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.softBlue,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              LinkRideColors.primaryBlue
                  .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color:
                LinkRideColors
                    .primaryBlue,
            size: 20,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Use at least 8 characters. Your new password must also be different from your current password.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color:
                    LinkRideColors
                        .textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 3,
        bottom: 9,
      ),
      child: Text(
        title,
        style:
            const TextStyle(
          fontSize: 10.5,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 1.1,
          color:
              LinkRideColors.textMuted,
        ),
      ),
    );
  }
}