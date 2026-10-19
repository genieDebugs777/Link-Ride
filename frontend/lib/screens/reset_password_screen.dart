import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String? developmentResetCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.developmentResetCode,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final AuthService _authService =
      AuthService();

  final TextEditingController
      resetCodeController =
      TextEditingController();

  final TextEditingController
      newPasswordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool _isResetting = false;

  static const Color primaryBlue =
      Color(0xFF003F73);

  static const Color fieldColour =
      Color(0xFFF3F5F7);

  static const Color textPrimary =
      Color(0xFF17212B);

  static const Color textSecondary =
      Color(0xFF667085);

  @override
  void initState() {
    super.initState();

    if (widget.developmentResetCode !=
        null) {
      resetCodeController.text =
          widget.developmentResetCode!;
    }
  }

  @override
  void dispose() {
    resetCodeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  String? _validateResetCode(
    String? value,
  ) {
    final String code =
        value?.trim() ?? '';

    if (code.isEmpty) {
      return 'Please enter the reset code';
    }

    if (!RegExp(r'^\d{6}$')
        .hasMatch(code)) {
      return 'Reset code must contain 6 digits';
    }

    return null;
  }

  String? _validatePassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please enter a new password';
    }

    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your new password';
    }

    if (value !=
        newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context)
        .unfocus();

    if (_isResetting) {
      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isResetting = true;
    });

    try {
      await _authService.resetPassword(
        email: widget.email,
        resetCode:
            resetCodeController.text
                .trim(),
        newPassword:
            newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset successfully. You can now sign in.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isResetting = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF98A2B3),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: textSecondary,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldColour,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color: primaryBlue,
          width: 1.5,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color: Color(0xFFD92D20),
          width: 1.2,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color: Color(0xFFD92D20),
          width: 1.5,
        ),
      ),
      errorStyle:
          const TextStyle(
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () =>
              FocusScope.of(context)
                  .unfocus(),
          child:
              SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 18,
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
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      Align(
                        alignment:
                            Alignment
                                .centerLeft,
                        child:
                            IconButton(
                          onPressed: () =>
                              Navigator.pop(
                            context,
                          ),
                          icon:
                              const Icon(
                            Icons
                                .arrow_back_rounded,
                            color:
                                primaryBlue,
                          ),
                        ),
                      ),

                      Center(
                        child:
                            Image.asset(
                          'assets/link_ride_logo.png',
                          width: 210,
                          height: 105,
                          fit: BoxFit
                              .contain,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(
                        'Reset your password',
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          fontSize: 27,
                          fontWeight:
                              FontWeight
                                  .w800,
                          letterSpacing:
                              -0.4,
                          color:
                              primaryBlue,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Enter the one-time reset code for ${widget.email} and choose a new password.',
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color:
                              textSecondary,
                        ),
                      ),

                      if (widget
                              .developmentResetCode !=
                          null) ...[
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFFFF8E8,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                          child:
                              const Text(
                            'Prototype mode: the development reset code is shown directly in the app. A production release would send it securely by email.',
                            style:
                                TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color:
                                  textSecondary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 26,
                      ),

                      const Text(
                        'Reset Code',
                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              textPrimary,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      TextFormField(
                        controller:
                            resetCodeController,
                        validator:
                            _validateResetCode,
                        keyboardType:
                            TextInputType
                                .number,
                        textInputAction:
                            TextInputAction
                                .next,
                        decoration:
                            _fieldDecoration(
                          hint:
                              'Enter 6-digit code',
                          icon: Icons
                              .pin_outlined,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(
                        'New Password',
                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              textPrimary,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      TextFormField(
                        controller:
                            newPasswordController,
                        validator:
                            _validatePassword,
                        obscureText:
                            obscureNewPassword,
                        textInputAction:
                            TextInputAction
                                .next,
                        decoration:
                            _fieldDecoration(
                          hint:
                              'Enter new password',
                          icon: Icons
                              .lock_outline_rounded,
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(
                                () {
                                  obscureNewPassword =
                                      !obscureNewPassword;
                                },
                              );
                            },
                            icon: Icon(
                              obscureNewPassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                              size: 20,
                              color:
                                  textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(
                        'Confirm Password',
                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              textPrimary,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      TextFormField(
                        controller:
                            confirmPasswordController,
                        validator:
                            _validateConfirmPassword,
                        obscureText:
                            obscureConfirmPassword,
                        textInputAction:
                            TextInputAction
                                .done,
                        onFieldSubmitted:
                            (_) {
                          _resetPassword();
                        },
                        decoration:
                            _fieldDecoration(
                          hint:
                              'Confirm new password',
                          icon: Icons
                              .lock_outline_rounded,
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(
                                () {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                },
                              );
                            },
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                              size: 20,
                              color:
                                  textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 26,
                      ),

                      SizedBox(
                        height: 54,
                        child:
                            ElevatedButton(
                          onPressed:
                              _isResetting
                                  ? null
                                  : _resetPassword,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                primaryBlue,
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),
                          ),
                          child:
                              _isResetting
                                  ? const SizedBox(
                                      width:
                                          20,
                                      height:
                                          20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                        color:
                                            Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Reset Password',
                                      style:
                                          TextStyle(
                                        fontSize:
                                            15,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
