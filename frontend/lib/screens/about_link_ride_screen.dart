import 'package:flutter/material.dart';

class AboutLinkRideScreen extends StatelessWidget {
  const AboutLinkRideScreen({super.key});

  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);
  static const Color lightBlue = Color(0xFFEAF3F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        title: const Text(
          'About Link Ride',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────────────── BRANDING ─────────────────

              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/link_ride_header_logo.png',
                      height: 72,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'One Journey. Every Connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Linking transport. Simplifying journeys.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ───────────────── ABOUT ─────────────────

              _sectionTitle('ABOUT'),

              _informationCard(
                icon: Icons.directions_transit_rounded,
                title: 'What is Link Ride?',
                description:
                    'Link Ride is an urban mobility platform designed to '
                    'connect fragmented public transport services into one '
                    'more connected journey experience. It brings journey '
                    'planning, transport information, payments, digital '
                    'tickets and notifications together through a single '
                    'mobile experience.',
              ),

              const SizedBox(height: 22),

              // ───────────────── PURPOSE ─────────────────

              _sectionTitle('OUR PURPOSE'),

              _informationCard(
                icon: Icons.hub_outlined,
                title: 'One connected journey',
                description:
                    'Public transport journeys can involve multiple services '
                    'that operate independently. Link Ride aims to make those '
                    'connections easier for commuters by providing a unified '
                    'way to discover, understand and manage multi-modal '
                    'journeys.',
              ),

              const SizedBox(height: 22),

              // ───────────────── PROTOTYPE ─────────────────

              _sectionTitle('PROTOTYPE SCOPE'),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      color: primaryBlue,
                      size: 23,
                    ),

                    SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proof of concept',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'This version of Link Ride is a Gauteng-focused '
                            'prototype demonstrating how formal and informal '
                            'transport services could be connected through an '
                            'interoperable mobility platform.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ───────────────── APP INFORMATION ─────────────────

              _sectionTitle('APP INFORMATION'),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    _detailTile(
                      icon: Icons.apps_rounded,
                      title: 'Application',
                      value: 'Link Ride',
                    ),

                    _divider(),

                    _detailTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      value: '1.0.0',
                    ),

                    _divider(),

                    _detailTile(
                      icon: Icons.school_outlined,
                      title: 'Project status',
                      value: 'Academic Prototype',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'Link Ride • One Journey. Every Connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 9,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _informationCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryBlue,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: primaryBlue,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFEEF1F4),
      ),
    );
  }
}