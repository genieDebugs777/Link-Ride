import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/payment_service.dart';
import '../services/ticket_service.dart';
import '../theme/link_ride_theme.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> journey;

  const PaymentScreen({
    super.key,
    required this.journey,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
  final AuthStorage _authStorage =
      AuthStorage();

  final PaymentService _paymentService =
      PaymentService();

  final TicketService _ticketService =
      TicketService();

  String _selectedMethod = 'CARD';

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final int journeyId =
        _asInt(
      widget.journey['journeyId'],
    );

    final String origin =
        widget.journey['origin']
                ?.toString() ??
            'Unknown origin';

    final String destination =
        widget.journey['destination']
                ?.toString() ??
            'Unknown destination';

    final int duration =
        _asInt(
      widget.journey[
          'estimatedDuration'],
    );

    final double cost =
        _asDouble(
      widget.journey[
          'estimatedCost'],
    );

    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Payment',
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
              _checkoutHeader(
                cost,
              ),

              const SizedBox(height: 22),

              const Text(
                'Journey Summary',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              _journeySummaryCard(
                journeyId: journeyId,
                origin: origin,
                destination:
                    destination,
                duration: duration,
                cost: cost,
              ),

              const SizedBox(height: 26),

              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Choose how you want to complete this prototype payment.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color:
                      LinkRideColors
                          .textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              RadioGroup<String>(
                groupValue: _selectedMethod,
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedMethod = value;
                  });
                },
                child: Column(
                  children: [
                    _paymentMethodCard(
                      value: 'CARD',
                      icon:
                          Icons.credit_card_rounded,
                      title: 'Card',
                      subtitle:
                          'Prototype card payment',
                      accent:
                          LinkRideColors.primaryBlue,
                    ),

                    const SizedBox(height: 10),

                    _paymentMethodCard(
                      value: 'WALLET',
                      icon: Icons
                          .account_balance_wallet_rounded,
                      title:
                          'Link Ride Wallet',
                      subtitle:
                          'Prototype wallet option',
                      accent:
                          LinkRideColors.linkGreen,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _prototypeNotice(),

              const SizedBox(height: 24),

              _payButton(
                journeyId: journeyId,
                cost: cost,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkoutHeader(
    double cost,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration:
          LinkRideDecorations.blueCard(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Complete your journey payment',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color: Colors.white
                  .withValues(alpha: 0.78),
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'R${cost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'The amount is based on the selected journey stored by Link Ride.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Colors.white
                  .withValues(alpha: 0.74),
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeySummaryCard({
    required int journeyId,
    required String origin,
    required String destination,
    required int duration,
    required double cost,
  }) {
    return Container(
      width: double.infinity,
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              14,
            ),
            decoration: BoxDecoration(
              color:
                  LinkRideColors.softBlue,
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(
                  LinkRideRadius.large,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    size: 20,
                    color:
                        LinkRideColors
                            .primaryBlue,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    'Journey #$journeyId',
                    style:
                        const TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          LinkRideColors
                              .textPrimary,
                    ),
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        LinkRideColors
                            .primaryBlue
                            .withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      LinkRideRadius.pill,
                    ),
                  ),
                  child: const Text(
                    'CHECKOUT',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 0.4,
                      color:
                          LinkRideColors
                              .primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16,
            ),
            child: Column(
              children: [
                _locationRow(
                  icon: Icons
                      .trip_origin_rounded,
                  color:
                      LinkRideColors.linkGreen,
                  label: 'FROM',
                  text: origin,
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 16,
                  ),
                  child: Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 18,
                      color:
                          LinkRideColors
                              .borderStrong,
                    ),
                  ),
                ),

                _locationRow(
                  icon: Icons
                      .location_on_rounded,
                  color:
                      LinkRideColors.primaryBlue,
                  label: 'TO',
                  text: destination,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon: Icons
                            .schedule_rounded,
                        label: 'Duration',
                        value:
                            '$duration min',
                        accent:
                            LinkRideColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _metricCard(
                        icon: Icons
                            .payments_outlined,
                        label: 'Total',
                        value:
                            'R${cost.toStringAsFixed(2)}',
                        accent:
                            LinkRideColors.linkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodCard({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    final bool selected =
        _selectedMethod == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = value;
          });
        },
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(
                    alpha: 0.055,
                  )
                : LinkRideColors.surface,
            borderRadius:
                BorderRadius.circular(
              LinkRideRadius.large,
            ),
            border: Border.all(
              color: selected
                  ? accent.withValues(
                      alpha: 0.32,
                    )
                  : LinkRideColors.border,
              width:
                  selected ? 1.3 : 1,
            ),
            boxShadow:
                selected
                    ? LinkRideShadows.soft
                    : const [],
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
                    alpha: 0.10,
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

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Radio<String>(
                value: value,
                activeColor: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prototypeNotice() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.warningSoft,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.medium,
        ),
        border: Border.all(
          color:
              LinkRideColors.warning
                  .withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .science_outlined,
              size: 20,
              color:
                  LinkRideColors.warning,
            ),
          ),

          SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Prototype payment',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'No real bank, wallet or card transaction is performed. This flow demonstrates the Link Ride payment lifecycle only.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
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

  Widget _payButton({
    required int journeyId,
    required double cost,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isProcessing
            ? null
            : () {
                _processPayment(
                  journeyId,
                );
              },
        child: AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          child: _isProcessing
              ? const Row(
                  key: ValueKey(
                    'payment-progress',
                  ),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 19,
                      height: 19,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Processing payment...',
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey(
                    'payment-label',
                  ),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons
                          .lock_outline_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pay R${cost.toStringAsFixed(2)}',
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration:
              BoxDecoration(
            color: color.withValues(
              alpha: 0.09,
            ),
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 17,
            color: color,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 0.7,
                  color:
                      LinkRideColors
                          .textMuted,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                text,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: accent,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    fontSize: 10.5,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12.5,
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

  Future<void> _processPayment(
    int journeyId,
  ) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final Map<String, dynamic> payment =
          await _paymentService
              .processPayment(
        token: token,
        journeyId: journeyId,
        paymentMethod:
            _selectedMethod,
      );

      if (!mounted) {
        return;
      }

      final String reference =
          payment['transactionReference']
                  ?.toString() ??
              'Unavailable';

      bool ticketIssued = false;

      try {
        await _ticketService.issueTicket(
          token: token,
          journeyId: journeyId,
        );

        ticketIssued = true;
      } catch (ticketError) {
        debugPrint(
          'Automatic ticket issue error: $ticketError',
        );
      }

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext dialogContext) {
          return AlertDialog(
            icon: Container(
              width: 62,
              height: 62,
              decoration:
                  const BoxDecoration(
                color:
                    LinkRideColors
                        .softGreen,
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 31,
                color:
                    LinkRideColors
                        .linkGreen,
              ),
            ),
            title: const Text(
              'Payment successful',
              textAlign:
                  TextAlign.center,
            ),
            content: Text(
              ticketIssued
                  ? 'Your journey has been paid successfully and your digital ticket is ready.\n\nReference: $reference'
                  : 'Your journey has been paid successfully. Your ticket could not be prepared automatically, but you can open the journey and continue to the ticket.\n\nReference: $reference',
              textAlign:
                  TextAlign.center,
            ),
            actionsAlignment:
                MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                child: const Text(
                  'Continue',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  int _asInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ??
              '',
        ) ??
        0;
  }

  double _asDouble(
    dynamic value,
  ) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ??
              '',
        ) ??
        0.0;
  }
}