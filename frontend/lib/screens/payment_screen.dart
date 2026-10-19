import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/payment_service.dart';
import '../services/ticket_service.dart';

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
  static const Color primaryBlue =
      Color(0xFF003F73);

  static const Color linkGreen =
      Color(0xFF4A9B45);

  static const Color background =
      Color(0xFFF7F9FB);

  static const Color textPrimary =
      Color(0xFF17212B);

  static const Color textSecondary =
      Color(0xFF667085);

  static const Color cardBorder =
      Color(0xFFE4E9EE);

  final AuthStorage _authStorage =
      AuthStorage();

  final PaymentService _paymentService =
      PaymentService();

  final TicketService _ticketService =
      TicketService();

  String _selectedMethod =
      'CARD';

  bool _isProcessing =
      false;

  @override
  Widget build(
    BuildContext context,
  ) {
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
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor:
            Colors.white,

        surfaceTintColor:
            Colors.white,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
            );
          },

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: primaryBlue,
          ),
        ),

        title: const Text(
          'Payment',

          style: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Journey Summary',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      textPrimary,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _journeySummaryCard(
                journeyId:
                    journeyId,
                origin:
                    origin,
                destination:
                    destination,
                duration:
                    duration,
                cost:
                    cost,
              ),

              const SizedBox(
                height: 24,
              ),

              const Text(
                'Payment Method',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      textPrimary,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _paymentMethodCard(
                value:
                    'CARD',
                icon:
                    Icons.credit_card_rounded,
                title:
                    'Card',
                subtitle:
                    'Prototype card payment',
              ),

              const SizedBox(
                height: 10,
              ),

              _paymentMethodCard(
                value:
                    'WALLET',
                icon:
                    Icons.account_balance_wallet_rounded,
                title:
                    'Link Ride Wallet',
                subtitle:
                    'Prototype wallet option',
              ),

              const SizedBox(
                height: 24,
              ),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      primaryBlue
                          .withValues(
                    alpha: 0.05,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),

                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons
                          .info_outline_rounded,
                      size: 20,
                      color:
                          primaryBlue,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'This is a prototype payment flow. No real bank or card transaction is performed.',

                        style:
                            TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color:
                              textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width:
                    double.infinity,

                height: 50,

                child:
                    ElevatedButton(
                  onPressed:
                      _isProcessing
                          ? null
                          : () =>
                              _processPayment(
                                journeyId,
                              ),

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primaryBlue,

                    foregroundColor:
                        Colors.white,

                    disabledBackgroundColor:
                        primaryBlue
                            .withValues(
                      alpha: 0.55,
                    ),

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color:
                                    Colors.white,
                              ),
                            )
                          : Text(
                              'Pay R${cost.toStringAsFixed(2)}',

                              style:
                                  const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
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
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius
                .circular(
          20,
        ),

        border:
            Border.all(
          color:
              cardBorder,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'Journey #$journeyId',

            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
              color:
                  textPrimary,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          _locationRow(
            icon:
                Icons.trip_origin_rounded,
            color:
                linkGreen,
            text:
                origin,
          ),

          Padding(
            padding:
                const EdgeInsets.only(
              left: 7,
            ),

            child: Container(
              width: 2,
              height: 18,
              color:
                  cardBorder,
            ),
          ),

          _locationRow(
            icon:
                Icons.location_on_rounded,
            color:
                primaryBlue,
            text:
                destination,
          ),

          const SizedBox(
            height: 16,
          ),

          const Divider(
            height: 1,
            color:
                cardBorder,
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              Expanded(
                child: _metric(
                  icon:
                      Icons
                          .schedule_rounded,
                  value:
                      '$duration min',
                ),
              ),

              Expanded(
                child: _metric(
                  icon:
                      Icons
                          .payments_outlined,
                  value:
                      'R${cost.toStringAsFixed(2)}',
                ),
              ),
            ],
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
  }) {
    final bool selected =
        _selectedMethod ==
            value;

    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod =
                value;
          });
        },

        borderRadius:
            BorderRadius
                .circular(
          18,
        ),

        child: Ink(
          padding:
              const EdgeInsets.all(
            16,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            borderRadius:
                BorderRadius
                    .circular(
              18,
            ),

            border:
                Border.all(
              color:
                  selected
                      ? primaryBlue
                      : cardBorder,
              width:
                  selected
                      ? 1.5
                      : 1,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration:
                    BoxDecoration(
                  color:
                      primaryBlue
                          .withValues(
                    alpha: 0.08,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,
                  color:
                      primaryBlue,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,

                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,

                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color:
                            textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              RadioGroup<String>(
                groupValue: _selectedMethod,

                onChanged: (String? newValue) {
                  if (newValue == null) {
                    return;
                  }

                  setState(() {
                    _selectedMethod = newValue;
                  });
                },

                child: Radio<String>(
                    value: value,
                    activeColor: primaryBlue,
                ),
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
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color:
              color,
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Text(
            text,

            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color:
                  textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metric({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Icon(
          icon,
          size: 16,
          color:
              primaryBlue,
        ),

        const SizedBox(
          width: 6,
        ),

        Text(
          value,

          style:
              const TextStyle(
            fontSize: 12.5,
            fontWeight:
                FontWeight.w700,
            color:
                textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment(
    int journeyId,
  ) async {
    setState(() {
      _isProcessing =
          true;
    });

    try {
      final String? token =
          await _authStorage
              .getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final Map<String, dynamic>
          payment =
          await _paymentService
              .processPayment(
        token:
            token,
        journeyId:
            journeyId,
        paymentMethod:
            _selectedMethod,
      );

      if (!mounted) {
        return;
      }

      final String reference =
          payment[
                      'transactionReference']
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
        context:
            context,

        barrierDismissible:
            false,

        builder:
            (BuildContext context) {
          return AlertDialog(
            icon:
                const Icon(
              Icons
                  .check_circle_rounded,
              color:
                  linkGreen,
              size: 46,
            ),

            title:
                const Text(
              'Payment successful',
            ),

            content:
                Text(
              ticketIssued
                  ? 'Your journey has been paid successfully and your digital ticket is ready.\n\nReference: $reference'
                  : 'Your journey has been paid successfully. Your ticket could not be prepared automatically, but you can open the journey and continue to the ticket.\n\nReference: $reference',
            ),

            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },

                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      primaryBlue,
                ),

                child:
                    const Text(
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
          _isProcessing =
              false;
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