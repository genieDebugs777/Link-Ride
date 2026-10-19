import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);
  static const Color lightBlue = Color(0xFFEAF3F8);

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
      question: 'Where can I find my digital ticket?',
      answer:
          'After a supported journey payment is completed successfully, '
          'Link Ride can provide a digital ticket or journey confirmation. '
          'Your available tickets can be accessed from the Tickets section '
          'of the app.',
    ),
    _FaqItem(
      question: 'What happens if a transport service is disrupted?',
      answer:
          'Link Ride is designed to provide service updates and disruption '
          'alerts when information is available from connected transport '
          'providers. These updates help you stay informed about changes '
          'that may affect your journey.',
    ),
    _FaqItem(
      question: 'How does Link Ride handle payments?',
      answer:
          'Link Ride is designed to support integrated journey payments '
          'through its payment services. Payment information is processed '
          'as part of the selected journey flow, with confirmation or '
          'failure feedback shown to the user.',
    ),
    _FaqItem(
      question: 'How do I change my account information?',
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
        builder: (context) => _HelpTopicScreen(
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
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        title: const Text(
          'Help & Support',
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
              const Text(
                'How can we help?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Find guidance for using Link Ride and answers to common questions.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 26),

              _sectionTitle('HELP CENTRE'),

              _helpCard(
                icon: Icons.route_outlined,
                title: 'Journey Planning',
                description:
                    'Learn about searching, comparing and selecting journeys.',
                onTap: () {
                  _openHelpTopic(
                    title: 'Journey Planning',
                    icon: Icons.route_outlined,
                    intro:
                        'Use Link Ride to plan a connected public-transport journey across the supported prototype network.',
                    steps: const [
                      _HelpStep(
                        title: '1. Choose where you are starting',
                        body:
                            'On Home, use your current device location or type in and select a supported stop manually in the FROM field.',
                      ),
                      _HelpStep(
                        title: '2. Choose your destination',
                        body:
                            'Type at least two characters in the TO field and select a stop from the Link Ride suggestions. The planner uses stops from the controlled transport network.',
                      ),
                      _HelpStep(
                        title: '3. Find journey options',
                        body:
                            'Tap Find Journey. Link Ride compares sensible routes and can combine walking, train, bus and minibus-taxi legs where appropriate.',
                      ),
                      _HelpStep(
                        title: '4. Compare the options',
                        body:
                            'Journey cards show estimated duration, cost and transfers. Ranking tags such as FASTEST, CHEAPEST, BALANCED and FEWEST TRANSFERS help you compare alternatives.',
                      ),
                      _HelpStep(
                        title: '5. Select your journey',
                        body:
                            'Open the option you prefer and select it. Only the chosen journey is saved to your account; planning searches themselves are temporary.',
                      ),
                      _HelpStep(
                        title: 'Journey preferences',
                        body:
                            'Profile > Journey Preferences lets you choose a priority, preferred transport modes and whether you prefer fewer transfers.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),

              _helpCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Payments & Tickets',
                description:
                    'Understand journey payments, confirmations and digital tickets.',
                onTap: () {
                  _openHelpTopic(
                    title: 'Payments & Tickets',
                    icon: Icons.confirmation_number_outlined,
                    intro:
                        'After selecting a journey, Link Ride guides you through payment and digital ticketing for that journey.',
                    steps: const [
                      _HelpStep(
                        title: '1. Pay for the selected journey',
                        body:
                            'Open the selected journey and continue to payment. The backend uses the journey amount as the source of truth and records the payment result.',
                      ),
                      _HelpStep(
                        title: '2. Ticket creation',
                        body:
                            'After a successful payment, Link Ride automatically attempts to issue a digital ticket for the journey.',
                      ),
                      _HelpStep(
                        title: '3. Find your ticket',
                        body:
                            'Open the Tickets tab or use My Ticket on Home. An ISSUED ticket is ready to use, while an ACTIVE ticket belongs to a journey that has already started.',
                      ),
                      _HelpStep(
                        title: '4. Start and complete a journey',
                        body:
                            'Starting the journey activates the ticket. When the journey is completed, the journey moves to history and the ticket becomes USED.',
                      ),
                      _HelpStep(
                        title: 'If something does not update',
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
                icon: Icons.shield_outlined,
                title: 'Account & Security',
                description:
                    'Get guidance on your profile, password and account security.',
                onTap: () {
                  _openHelpTopic(
                    title: 'Account & Security',
                    icon: Icons.shield_outlined,
                    intro:
                        'Manage your Link Ride profile and account security from the Profile section.',
                    steps: const [
                      _HelpStep(
                        title: 'Create and sign in to an account',
                        body:
                            'New commuters can register from the sign-in screen. Existing commuters sign in using their registered email address and password.',
                      ),
                      _HelpStep(
                        title: 'Update personal details',
                        body:
                            'Open Profile > Edit Profile to change supported account details. Personal Details shows the information currently linked to your account.',
                      ),
                      _HelpStep(
                        title: 'Change your password',
                        body:
                            'When signed in, use Profile > Change Password. You will need your current password before a new password is accepted.',
                      ),
                      _HelpStep(
                        title: 'Forgotten password',
                        body:
                            'From the sign-in screen, choose Forgot password? The prototype creates a one-time reset code that expires after a short period and can only be used once.',
                      ),
                      _HelpStep(
                        title: 'Session security',
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
                icon: Icons.notifications_none_rounded,
                title: 'Notifications & Service Updates',
                description:
                    'Learn about journey notifications and transport service updates.',
                onTap: () {
                  _openHelpTopic(
                    title: 'Notifications & Service Updates',
                    icon: Icons.notifications_none_rounded,
                    intro:
                        'Link Ride can surface transport disruptions and notify commuters when an affected route is part of a current journey.',
                    steps: const [
                      _HelpStep(
                        title: 'Live transport updates',
                        body:
                            'The Home screen shows active service disruptions reported in the prototype transport network.',
                      ),
                      _HelpStep(
                        title: 'Journey-specific disruption alerts',
                        body:
                            'When a disruption affects a route used by one of your current journeys, Link Ride can create an in-app notification for your account.',
                      ),
                      _HelpStep(
                        title: 'Notification bell',
                        body:
                            'The bell on Home shows the unread count. Open it to view notification details, mark an individual item as read or mark all notifications as read.',
                      ),
                      _HelpStep(
                        title: 'Notification preferences',
                        body:
                            'Open Profile > Notification Preferences to control the update categories you want to receive. Service disruption alerts can be enabled or disabled.',
                      ),
                      _HelpStep(
                        title: 'Resolved disruptions',
                        body:
                            'When a disruption is resolved, Link Ride updates the service state so the active disruption no longer appears as an ongoing issue.',
                      ),
                    ],
                    note:
                        'Link Ride currently provides in-app notifications. Production push notifications can be added in a future release.',
                  );
                },
              ),

              const SizedBox(height: 28),

              _sectionTitle('FREQUENTLY ASKED QUESTIONS'),

              Container(
                width: double.infinity,
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
                child: Column(
                  children: List.generate(
                    _faqs.length,
                    (index) {
                      final _FaqItem faq = _faqs[index];
                      final bool isExpanded =
                          _expandedFaqIndex == index;

                      return Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                _expandedFaqIndex =
                                    isExpanded ? null : index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: primaryBlue,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                44,
                                17,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  faq.answer,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            ),

                          if (index != _faqs.length - 1)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEEF1F4),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              _sectionTitle('CONTACT SUPPORT'),

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
                      Icons.support_agent_rounded,
                      color: primaryBlue,
                      size: 23,
                    ),

                    SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need more help?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Link Ride is currently a prototype. Dedicated '
                            'customer-support channels are not yet available.',
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

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  'For account and app guidance, use the help topics and FAQs above.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
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

  Widget _helpCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _HelpTopicScreen extends StatelessWidget {
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

  static const Color primaryBlue = Color(0xFF003F73);
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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: primaryBlue,
                  size: 27,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                intro,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(
                steps.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == steps.length - 1 ? 0 : 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index].title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[index].body,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          note!,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
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