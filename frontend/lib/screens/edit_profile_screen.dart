import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/profile_service.dart';
import '../theme/link_ride_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfileScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final AuthStorage _authStorage =
      AuthStorage();

  final ProfileService _profileService =
      ProfileService();

  bool isSaving = false;

  late final TextEditingController
      firstNameController;

  late final TextEditingController
      lastNameController;

  late final TextEditingController
      emailController;

  late final TextEditingController
      phoneNumberController;

  @override
  void initState() {
    super.initState();

    firstNameController =
        TextEditingController(
      text: widget.userProfile['firstName']
              ?.toString() ??
          '',
    );

    lastNameController =
        TextEditingController(
      text: widget.userProfile['lastName']
              ?.toString() ??
          '',
    );

    emailController =
        TextEditingController(
      text: widget.userProfile['email']
              ?.toString() ??
          '',
    );

    phoneNumberController =
        TextEditingController(
      text: widget.userProfile['phoneNumber']
              ?.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();

    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      final int? userId =
          await _authStorage.getUserId();

      if (token == null ||
          userId == null) {
        throw Exception(
          'No active user session found.',
        );
      }

      final Map<String, dynamic>
          updatedProfile =
          await _profileService
              .updateUserProfile(
        userId: userId,
        token: token,
        firstName:
            firstNameController.text.trim(),
        lastName:
            lastNameController.text.trim(),
        email:
            emailController.text.trim(),
        phoneNumber:
            phoneNumberController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        updatedProfile,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update your profile. Please try again.',
          ),
        ),
      );
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
          'Edit Profile',
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
                  'PERSONAL DETAILS',
                ),

                _formCard(
                  children: [
                    _buildField(
                      controller:
                          firstNameController,
                      label: 'First name',
                      icon: Icons
                          .person_outline_rounded,
                      textInputAction:
                          TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'First name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildField(
                      controller:
                          lastNameController,
                      label: 'Last name',
                      icon:
                          Icons.badge_outlined,
                      textInputAction:
                          TextInputAction.next,
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Last name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildField(
                      controller:
                          emailController,
                      label: 'Email address',
                      icon:
                          Icons.email_outlined,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      validator: (value) {
                        final String email =
                            value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Email address is required';
                        }

                        if (!email.contains('@') ||
                            !email.contains('.')) {
                          return 'Enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildField(
                      controller:
                          phoneNumberController,
                      label: 'Phone number',
                      icon:
                          Icons.phone_outlined,
                      keyboardType:
                          TextInputType.phone,
                      textInputAction:
                          TextInputAction.done,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _informationCard(),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child:
                      FilledButton.icon(
                    onPressed:
                        isSaving
                            ? null
                            : _saveChanges,
                    icon: isSaving
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
                                .save_outlined,
                            size: 18,
                          ),
                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : 'Save Changes',
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
    final String firstName =
        firstNameController.text.trim();

    final String lastName =
        lastNameController.text.trim();

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
            width: 56,
            height: 56,
            alignment:
                Alignment.center,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(
                firstName,
                lastName,
              ),
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color:
                    LinkRideColors
                        .primaryBlue,
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Update your details',
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
                  'Keep your Link Ride account information accurate and up to date.',
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

  Widget _formCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
    TextInputAction? textInputAction,
    String? Function(String?)?
        validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction:
          textInputAction,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight:
            FontWeight.w600,
        color:
            LinkRideColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 21,
        ),
      ),
    );
  }

  Widget _informationCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.softGreen,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              LinkRideColors.linkGreen
                  .withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .verified_user_outlined,
            size: 20,
            color:
                LinkRideColors
                    .linkGreen,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Your account status, password and account creation date cannot be changed from this form.',
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

  String _initials(
    String firstName,
    String lastName,
  ) {
    final String first =
        firstName.trim();

    final String last =
        lastName.trim();

    if (first.isEmpty &&
        last.isEmpty) {
      return 'U';
    }

    if (first.isNotEmpty &&
        last.isNotEmpty) {
      return '${first[0]}${last[0]}'
          .toUpperCase();
    }

    final String source =
        first.isNotEmpty
            ? first
            : last;

    return source[0].toUpperCase();
  }
}