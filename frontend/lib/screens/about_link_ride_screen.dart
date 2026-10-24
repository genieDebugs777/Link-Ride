import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';

class AboutLinkRideScreen extends StatelessWidget {
  const AboutLinkRideScreen({
    super.key,
  });

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
          'About Link Ride',
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
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _brandHero(),

              const SizedBox(height: 24),

              _sectionTitle(
                'ABOUT',
              ),

              _informationCard(
                icon: Icons
                    .directions_transit_rounded,
                accent:
                    LinkRideColors
                        .primaryBlue,
                title:
                    'What is Link Ride?',
                description:
                    'Link Ride is an urban mobility platform designed to '
                    'connect fragmented public transport services into one '
                    'more connected journey experience. It brings journey '
                    'planning, transport information, payments, digital '
                    'tickets and notifications together through a single '
                    'mobile experience.',
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'OUR PURPOSE',
              ),

              _informationCard(
                icon:
                    Icons.hub_outlined,
                accent:
                    LinkRideColors
                        .linkGreen,
                title:
                    'One connected journey',
                description:
                    'Public transport journeys can involve multiple services '
                    'that operate independently. Link Ride aims to make those '
                    'connections easier for commuters by providing a unified '
                    'way to discover, understand and manage multi-modal '
                    'journeys.',
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'PROTOTYPE SCOPE',
              ),

              _prototypeCard(),

              const SizedBox(height: 22),

              _sectionTitle(
                'APP INFORMATION',
              ),

              _appInformationCard(),

              const SizedBox(height: 26),

              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandHero() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          LinkRideDecorations.blueCard(),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -48,
            child: Container(
              width: 140,
              height: 140,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.06,
                ),
                shape:
                    BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              Container(
                width: double.infinity,
                alignment:
                    Alignment.center,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Image.asset(
                  'assets/link_ride_header_logo.png',
                  height: 68,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'One Journey. Every Connection.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.2,
                  color:
                      Colors.white,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Linking transport. Simplifying journeys.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white
                      .withValues(
                    alpha: 0.75,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    LinkRideRadius.pill,
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .school_outlined,
                      size: 15,
                      color:
                          Colors.white,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'ACADEMIC PROTOTYPE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing:
                            0.6,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _informationCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          LinkRideDecorations.card(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  accent.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style:
                      const TextStyle(
                    fontSize: 12.3,
                    height: 1.5,
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

  Widget _prototypeCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons.science_outlined,
              color:
                  LinkRideColors
                      .primaryBlue,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Proof of concept',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'This version of Link Ride is a Gauteng-focused prototype demonstrating how formal and informal transport services could be connected through an interoperable mobility platform.',
                  style: TextStyle(
                    fontSize: 12.2,
                    height: 1.5,
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

  Widget _appInformationCard() {
    return Container(
      width: double.infinity,
      decoration:
          LinkRideDecorations.card(),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              _detailTile(
                icon:
                    Icons.apps_rounded,
                accent:
                    LinkRideColors
                        .primaryBlue,
                title: 'Application',
                value: 'Link Ride',
              ),

              _divider(),

              _detailTile(
                icon: Icons
                    .info_outline_rounded,
                accent:
                    const Color(
                  0xFF6C63B8,
                ),
                title: 'Version',
                value: '1.0.0',
              ),

              _divider(),

              _detailTile(
                icon:
                    Icons.school_outlined,
                accent:
                    LinkRideColors
                        .linkGreen,
                title:
                    'Project status',
                value:
                    'Academic Prototype',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required Color accent,
    required String title,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  accent.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return const Center(
      child: Column(
        children: [
          Icon(
            Icons
                .directions_transit_rounded,
            size: 20,
            color:
                LinkRideColors
                    .primaryBlue,
          ),

          SizedBox(height: 7),

          Text(
            'Link Ride',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          SizedBox(height: 3),

          Text(
            'One Journey. Every Connection.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color:
                  LinkRideColors
                      .textMuted,
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

  Widget _divider() {
    return const Padding(
      padding:
          EdgeInsets.only(
        left: 72,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color:
            LinkRideColors.border,
      ),
    );
  }
}