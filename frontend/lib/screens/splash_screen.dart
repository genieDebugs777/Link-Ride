import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../theme/link_ride_theme.dart';
import 'authentication_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthStorage _authStorage = AuthStorage();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    final String? token = await _authStorage.getToken();
    final String? firstName = await _authStorage.getFirstName();

    final String role = (await _authStorage.getRole()) ?? 'COMMUTER';

    if (!mounted) {
      return;
    }

    if (token != null &&
        token.isNotEmpty &&
        firstName != null &&
        firstName.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainNavigationScreen(firstName: firstName, role: role),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            child: _decorativeCircle(
              size: 260,
              color: LinkRideColors.softBlueStrong,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _decorativeCircle(
              size: 280,
              color: LinkRideColors.softGreenStrong,
            ),
          ),
          Positioned(
            top: 110,
            left: 32,
            child: _decorativeCircle(
              size: 54,
              color: LinkRideColors.primaryBlue.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: 150,
            right: 28,
            child: _decorativeCircle(
              size: 38,
              color: LinkRideColors.linkGreen.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 142,
                          height: 142,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: LinkRideColors.surface,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: LinkRideShadows.elevated,
                          ),
                          child: Image.asset(
                            'assets/link_ride_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Link Ride',
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
                          'One Journey. Every Connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: LinkRideColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 34),
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: LinkRideColors.primaryBlue,
                          ),
                        ),
                      ],
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

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
