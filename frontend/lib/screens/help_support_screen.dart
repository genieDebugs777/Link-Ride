import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({
    super.key,
  });

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen> {
  int? _expandedFaqIndex;

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      question: 'How do I plan a journey?',
      answer:
          'Enter your origin and destination from the Home screen and search '
          'for available journeys. Link Ride can present journey options '
          'across supported transport services so you can compare and select '
          'the option that suits your trip.',
    ),
    _FaqItem(
      question:
          'Where can I find my digital ticket?',
      answer:
          'After a supported journey payment is completed successfully, '
          'Link Ride can provide a digital ticket or journey confirmation. '
          'Your available tickets can be accessed from the Tickets section '
          'of the app.',
    ),
    _FaqItem(
      question:
          'What happens if a transport service is disrupted?',
      answer:
          'Link Ride is designed to provide service updates and disruption '
          'alerts when information is available from connected transport '
          'providers. These updates help you stay informed about changes '
          'that may affect your journey.',
    ),
    _FaqItem(
      question:
          'How does Link Ride handle payments?',
      answer:
          'Link Ride is designed to support integrated journey payments '
          'through its payment services. Payment information is processed '
          'as part of the selected journey flow, with confirmation or '
          'failure feedback shown to the user.',
    ),
    _FaqItem(
      question:
          'How do I change my account information?',
      answer:
          'Open Profile and select Edit Profile to update supported personal '
          'details. Password changes are handled separately through the '
          'Change Password option under Profile.',
    ),
  ];

  void _openHelpTopic({
    required String title,
    required IconData icon,
    required String intro,
    required List<_HelpStep> steps,
    String? note,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _HelpTopicScreen(
          title: title,
          icon: icon,
          intro: intro,
          steps: steps,
          note: note,
        ),
      ),
    );
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
          'Help & Support',
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
              _helpHero(),

              const SizedBox(height: 24),

              _sectionTitle(
                'HELP CENTRE',
              ),

              _helpCard(
                icon:
                    Icons.route_outlined,
                accent:
                    LinkRideColors.primaryBlue,
                title:
                    'Journey Planning',
                description:
                    'Learn about searching, comparing and selecting journeys.',
                onTap: () {
                  _openHelpTopic(
                    title:
                        'Journey Planning',
                    icon:
                        Icons.route_outlined,
                    intro:
                        'Use Link Ride to plan a connected public-transport journey across the supported prototype network.',
                    steps: const [
                      _HelpStep(
                        title:
                            '1. Choose where you are starting',
                        body:
                            'On Home, use your current device location or type in and select a supported stop manually in the FROM field.',
                      ),
                      _HelpStep(
                        title:
                            '2. Choose your destination',
                        body:
                            'Type at least two characters in the TO field and select a stop from the Link Ride suggestions. The planner uses stops from the controlled transport network.',
                      ),
                      _HelpStep(
                        title:
                            '3. Find journey options',
                        body:
                            'Tap Find Journey. Link Ride compares sensible routes and can combine walking, train, bus and minibus-taxi legs where appropriate.',
                      ),
                      _HelpStep(
                        title:
                            '4. Compare the options',
                        body:
                            'Journey cards show estimated duration, cost and transfers. Ranking tags such as FASTEST, CHEAPEST, BALANCED and FEWEST TRANSFERS help you compare alternatives.',
                      ),
                      _HelpStep(
                        title:
                            '5. Select your journey',
                        body:
                            'Open the option you prefer and select it. Only the chosen journey is saved to your account; planning searches themselves are temporary.',
                      ),
                      _HelpStep(
                        title:
                            'Journey preferences',
                        body:
                            'Profile > Journey Preferences lets you choose a priority, preferred transport modes and whether you prefer fewer transfers.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),

              _helpCard(
                icon: Icons
                    .confirmation_number_outlined,
                accent:
                    LinkRideColors.linkGreen,
                title:
                    'Payments & Tickets',
                description:
                    'Understand journey payments, confirmations and digital tickets.',
                onTap: () {
                  _openHelpTopic(
                    title:
                        'Payments & Tickets',
                    icon: Icons
                        .confirmation_number_outlined,
                    intro:
                        'After selecting a journey, Link Ride guides you through payment and digital ticketing for that journey.',
                    steps: const [
                      _HelpStep(
                        title:
                            '1. Pay for the selected journey',
                        body:
                            'Open the selected journey and continue to payment. The backend uses the journey amount as the source of truth and records the payment result.',
                      ),
                      _HelpStep(
                        title:
                            '2. Ticket creation',
                        body:
                            'After a successful payment, Link Ride automatically attempts to issue a digital ticket for the journey.',
                      ),
                      _HelpStep(
                        title:
                            '3. Find your ticket',
                        body:
                            'Open the Tickets tab or use My Ticket on Home. An ISSUED ticket is ready to use, while an ACTIVE ticket belongs to a journey that has already started.',
                      ),
                      _HelpStep(
                        title:
                            '4. Start and complete a journey',
                        body:
                            'Starting the journey activates the ticket. When the journey is completed, the journey moves to history and the ticket becomes USED.',
                      ),
                      _HelpStep(
                        title:
                            'If something does not update',
                        body:
                            'Return to the relevant tab or pull to refresh so Link Ride can fetch the latest journey, payment and ticket state from the backend.',
                      ),
                    ],
                    note:
                        'Link Ride is a prototype. Its payment experience demonstrates the application flow and should not be treated as a production financial service.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _helpCard(
                icon:
                    Icons.shield_outlined,
                accent:
                    const Color(
                  0xFF6C63B8,
                ),
                title:
                    'Account & Security',
                description:
                    'Get guidance on your profile, password and account security.',
                onTap: () {
                  _openHelpTopic(
                    title:
                        'Account & Security',
                    icon:
                        Icons.shield_outlined,
                    intro:
                        'Manage your Link Ride profile and account security from the Profile section.',
                    steps: const [
                      _HelpStep(
                        title:
                            'Create and sign in to an account',
                        body:
                            'New commuters can register from the sign-in screen. Existing commuters sign in using their registered email address and password.',
                      ),
                      _HelpStep(
                        title:
                            'Update personal details',
                        body:
                            'Open Profile > Edit Profile to change supported account details. Personal Details shows the information currently linked to your account.',
                      ),
                      _HelpStep(
                        title:
                            'Change your password',
                        body:
                            'When signed in, use Profile > Change Password. You will need your current password before a new password is accepted.',
                      ),
                      _HelpStep(
                        title:
                            'Forgotten password',
                        body:
                            'From the sign-in screen, choose Forgot password? The prototype creates a one-time reset code that expires after a short period and can only be used once.',
                      ),
                      _HelpStep(
                        title:
                            'Session security',
                        body:
                            'Protected Link Ride requests use your authenticated session. Logging out clears the stored session from the device.',
                      ),
                    ],
                    note:
                        'Prototype limitation: password-reset codes are shown directly in the app for demonstration. A production release should send them securely by email or another verified channel.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _helpCard(
                icon: Icons
                    .notifications_none_rounded,
                accent:
                    LinkRideColors.warning,
                title:
                    'Notifications & Service Updates',
                description:
                    'Learn about journey notifications and transport service updates.',
                onTap: () {
                  _openHelpTopic(
                    title:
                        'Notifications & Service Updates',
                    icon: Icons
                        .notifications_none_rounded,
                    intro:
                        'Link Ride can surface transport disruptions and notify commuters when an affected route is part of a current journey.',
                    steps: const [
                      _HelpStep(
                        title:
                            'Live transport updates',
                        body:
                            'The Home screen shows active service disruptions reported in the prototype transport network.',
                      ),
                      _HelpStep(
                        title:
                            'Journey-specific disruption alerts',
                        body:
                            'When a disruption affects a route used by one of your current journeys, Link Ride can create an in-app notification for your account.',
                      ),
                      _HelpStep(
                        title:
                            'Notification bell',
                        body:
                            'The bell on Home shows the unread count. Open it to view notification details, mark an individual item as read or mark all notifications as read.',
                      ),
                      _HelpStep(
                        title:
                            'Notification preferences',
                        body:
                            'Open Profile > Notification Preferences to control the update categories you want to receive. Service disruption alerts can be enabled or disabled.',
                      ),
                      _HelpStep(
                        title:
                            'Resolved disruptions',
                        body:
                            'When a disruption is resolved, Link Ride updates the service state so the active disruption no longer appears as an ongoing issue.',
                      ),
                    ],
                    note:
                        'Link Ride currently provides in-app notifications. Production push notifications can be added in a future release.',
                  );
                },
              ),

              const SizedBox(height: 26),

              _sectionTitle(
                'FREQUENTLY ASKED QUESTIONS',
              ),

              _faqCard(),

              const SizedBox(height: 26),

              _sectionTitle(
                'CONTACT SUPPORT',
              ),

              _supportCard(),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'For account and app guidance, use the help topics and FAQs above.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpHero() {
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
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .support_agent_rounded,
              size: 27,
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
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Find guidance for using Link Ride and answers to common questions.',
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

  Widget _helpCard({
    required IconData icon,
    required Color accent,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
          width: double.infinity,
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color:
                LinkRideColors.surface,
            borderRadius:
                BorderRadius.circular(
              LinkRideRadius.large,
            ),
            border: Border.all(
              color:
                  LinkRideColors.border,
            ),
            boxShadow:
                LinkRideShadows.soft,
          ),
          child: Row(
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

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style:
                          const TextStyle(
                        fontSize: 11.8,
                        height: 1.4,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons
                    .chevron_right_rounded,
                size: 21,
                color:
                    LinkRideColors
                        .textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqCard() {
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
            children:
                List.generate(
              _faqs.length,
              (index) {
                final _FaqItem faq =
                    _faqs[index];

                final bool isExpanded =
                    _expandedFaqIndex ==
                        index;

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedFaqIndex =
                              isExpanded
                                  ? null
                                  : index;
                        });
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          16,
                          14,
                          16,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    LinkRideColors
                                        .softBlue,
                                shape:
                                    BoxShape
                                        .circle,
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .question_mark_rounded,
                                size: 16,
                                color:
                                    LinkRideColors
                                        .primaryBlue,
                              ),
                            ),

                            const SizedBox(
                              width: 11,
                            ),

                            Expanded(
                              child: Text(
                                faq.question,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      13.5,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color:
                                      LinkRideColors
                                          .textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Icon(
                              isExpanded
                                  ? Icons
                                      .keyboard_arrow_up_rounded
                                  : Icons
                                      .keyboard_arrow_down_rounded,
                              color:
                                  LinkRideColors
                                      .primaryBlue,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    AnimatedCrossFade(
                      firstChild:
                          const SizedBox
                              .shrink(),
                      secondChild:
                          Padding(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          57,
                          0,
                          18,
                          16,
                        ),
                        child: Align(
                          alignment:
                              Alignment
                                  .centerLeft,
                          child: Text(
                            faq.answer,
                            style:
                                const TextStyle(
                              fontSize:
                                  12.3,
                              height: 1.5,
                              color:
                                  LinkRideColors
                                      .textSecondary,
                            ),
                          ),
                        ),
                      ),
                      crossFadeState:
                          isExpanded
                              ? CrossFadeState
                                  .showSecond
                              : CrossFadeState
                                  .showFirst,
                      duration:
                          const Duration(
                        milliseconds:
                            180,
                      ),
                    ),

                    if (index !=
                        _faqs.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color:
                            LinkRideColors
                                .border,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _supportCard() {
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
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .support_agent_rounded,
            color:
                LinkRideColors
                    .primaryBlue,
            size: 23,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Need more help?',
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
                  'Link Ride is currently a prototype. Dedicated customer-support channels are not yet available.',
                  style: TextStyle(
                    fontSize: 12,
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

class _HelpTopicScreen
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final String intro;
  final List<_HelpStep> steps;
  final String? note;

  const _HelpTopicScreen({
    required this.title,
    required this.icon,
    required this.intro,
    required this.steps,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      appBar: AppBar(
        title: Text(title),
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
              _topicHero(),

              const SizedBox(height: 20),

              ...List.generate(
                steps.length,
                (index) => Padding(
                  padding:
                      EdgeInsets.only(
                    bottom:
                        index ==
                                steps.length -
                                    1
                            ? 0
                            : 11,
                  ),
                  child:
                      _stepCard(
                    step:
                        steps[index],
                    index: index,
                  ),
                ),
              ),

              if (note != null) ...[
                const SizedBox(height: 18),
                _noteCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _topicHero() {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color:
                  LinkRideColors
                      .primaryBlue,
              size: 25,
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
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  intro,
                  style:
                      const TextStyle(
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

  Widget _stepCard({
    required _HelpStep step,
    required int index,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          LinkRideDecorations.card(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  LinkRideColors.softBlue,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              '${index + 1}',
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
                color:
                    LinkRideColors
                        .primaryBlue,
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
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

                const SizedBox(height: 5),

                Text(
                  step.body,
                  style:
                      const TextStyle(
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

  Widget _noteCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.softBlue,
        borderRadius:
            BorderRadius.circular(16),
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
          const Icon(
            Icons.info_outline_rounded,
            color:
                LinkRideColors
                    .primaryBlue,
            size: 20,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              note!,
              style:
                  const TextStyle(
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
}

class _HelpStep {
  final String title;
  final String body;

  const _HelpStep({
    required this.title,
    required this.body,
  });
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });
}