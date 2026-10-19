package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.Payment;
import za.co.linkride.link_ride_api.repository.JourneyRepository;
import za.co.linkride.link_ride_api.repository.PaymentRepository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final JourneyRepository journeyRepository;

    public PaymentService(
            PaymentRepository paymentRepository,
            JourneyRepository journeyRepository) {

        this.paymentRepository =
                paymentRepository;

        this.journeyRepository =
                journeyRepository;
    }

    // ============================================================
    // PROCESS PAYMENT
    // ============================================================

    /*
     * Prototype payment flow:
     *
     * SELECTED journey
     *      ↓
     * simulated successful payment
     *      ↓
     * Payment = SUCCESS
     * Journey = PAID
     *
     * No real banking/card provider is used at this stage.
     */
    @Transactional
    public Payment processPayment(
            Long userId,
            Long journeyId,
            String paymentMethod) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        if (journeyId == null) {
            throw new IllegalArgumentException(
                    "Journey ID is required."
            );
        }

        if (paymentMethod == null
                || paymentMethod.isBlank()) {

            throw new IllegalArgumentException(
                    "Payment method is required."
            );
        }

        Journey journey =
                journeyRepository
                        .findById(journeyId)
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Journey not found."
                                        )
                        );

        if (!userId.equals(
                journey.getUserId())) {

            throw new IllegalArgumentException(
                    "This journey does not belong to the authenticated user."
            );
        }

        String journeyStatus =
                journey.getJourneyStatus();

        if (journeyStatus == null
                || !journeyStatus.equalsIgnoreCase(
                "SELECTED"
        )) {

            throw new IllegalArgumentException(
                    "Only a SELECTED journey can be paid."
            );
        }

        Double amount =
                journey.getEstimatedCost();

        if (amount == null
                || amount < 0) {

            throw new IllegalArgumentException(
                    "Journey has an invalid payment amount."
            );
        }

        Optional<Payment> existingPayment =
                paymentRepository
                        .findTopByJourneyIdOrderByCreatedAtDesc(
                                journeyId
                        );

        if (existingPayment.isPresent()
                && "SUCCESS".equalsIgnoreCase(
                existingPayment
                        .get()
                        .getPaymentStatus()
        )) {

            throw new IllegalArgumentException(
                    "This journey has already been paid."
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        String transactionReference =
                generateTransactionReference();

        Payment payment =
                new Payment(
                        journeyId,
                        userId,
                        amount,
                        paymentMethod
                                .trim()
                                .toUpperCase(),
                        "SUCCESS",
                        transactionReference,
                        now,
                        now
                );

        Payment savedPayment =
                paymentRepository.save(
                        payment
                );

        journey.setJourneyStatus(
                "PAID"
        );

        journeyRepository.save(
                journey
        );

        return savedPayment;
    }

    // ============================================================
    // READ
    // ============================================================

    public Optional<Payment>
    getLatestPaymentForJourney(
            Long journeyId) {

        return paymentRepository
                .findTopByJourneyIdOrderByCreatedAtDesc(
                        journeyId
                );
    }

    // ============================================================
    // TRANSACTION REFERENCE
    // ============================================================

    private String generateTransactionReference() {

        String reference;

        do {
            reference =
                    "LR-"
                            + UUID.randomUUID()
                            .toString()
                            .replace("-", "")
                            .substring(0, 12)
                            .toUpperCase();

        } while (
                paymentRepository
                        .existsByTransactionReference(
                                reference
                        )
        );

        return reference;
    }
}