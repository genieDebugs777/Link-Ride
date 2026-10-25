package za.co.linkride.link_ride_api.service;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;
import za.co.linkride.link_ride_api.dto.PaystackInitializeResponse;
import za.co.linkride.link_ride_api.dto.PaystackVerifyResponse;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.Payment;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.repository.JourneyRepository;
import za.co.linkride.link_ride_api.repository.PaymentRepository;
import za.co.linkride.link_ride_api.repository.UserRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class PaystackPaymentService {

    private static final String PAYSTACK_BASE_URL =
            "https://api.paystack.co";

    private static final String CURRENCY =
            "ZAR";

    private final PaymentRepository paymentRepository;
    private final JourneyRepository journeyRepository;
    private final UserRepository userRepository;
    private final RestClient restClient;

    public PaystackPaymentService(
            PaymentRepository paymentRepository,
            JourneyRepository journeyRepository,
            UserRepository userRepository) {

        this.paymentRepository =
                paymentRepository;

        this.journeyRepository =
                journeyRepository;

        this.userRepository =
                userRepository;

        this.restClient =
                RestClient.builder()
                        .baseUrl(PAYSTACK_BASE_URL)
                        .build();
    }

    @Transactional
    public PaystackInitializeResponse initializePayment(
            Long userId,
            Long journeyId) {

        String secretKey =
                getTestSecretKey();

        Journey journey =
                requirePayableJourney(
                        userId,
                        journeyId
                );

        User user =
                userRepository
                        .findById(userId)
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Authenticated user was not found."
                                        )
                        );

        long amountInCents =
                toSubunit(
                        journey.getEstimatedCost()
                );

        String reference =
                generateTransactionReference();

        Map<String, Object> requestBody =
                new LinkedHashMap<>();

        requestBody.put(
                "email",
                user.getEmail()
        );

        requestBody.put(
                "amount",
                amountInCents
        );

        requestBody.put(
                "currency",
                CURRENCY
        );

        requestBody.put(
                "reference",
                reference
        );

        Map<?, ?> gatewayResponse;

        try {
            gatewayResponse =
                    restClient
                            .post()
                            .uri("/transaction/initialize")
                            .header(
                                    "Authorization",
                                    "Bearer " + secretKey
                            )
                            .contentType(
                                    MediaType.APPLICATION_JSON
                            )
                            .body(requestBody)
                            .retrieve()
                            .body(Map.class);

        } catch (Exception error) {
            throw new IllegalStateException(
                    "Unable to initialize Paystack test transaction.",
                    error
            );
        }

        if (gatewayResponse == null
                || !Boolean.TRUE.equals(
                gatewayResponse.get("status"))) {

            throw new IllegalStateException(
                    "Paystack did not initialize the transaction."
            );
        }

        Map<?, ?> data =
                asMap(
                        gatewayResponse.get("data"),
                        "Paystack returned an invalid initialization response."
                );

        String authorizationUrl =
                requireText(
                        data.get("authorization_url"),
                        "Paystack authorization URL is missing."
                );

        String accessCode =
                requireText(
                        data.get("access_code"),
                        "Paystack access code is missing."
                );

        String gatewayReference =
                requireText(
                        data.get("reference"),
                        "Paystack transaction reference is missing."
                );

        if (!reference.equals(
                gatewayReference)) {

            throw new IllegalStateException(
                    "Paystack returned an unexpected transaction reference."
            );
        }

        Payment pendingPayment =
                new Payment(
                        journeyId,
                        userId,
                        journey.getEstimatedCost(),
                        "PAYSTACK",
                        "PENDING",
                        reference,
                        LocalDateTime.now(),
                        null
                );

        paymentRepository.save(
                pendingPayment
        );

        return new PaystackInitializeResponse(
                authorizationUrl,
                accessCode,
                reference,
                amountInCents,
                CURRENCY
        );
    }

    @Transactional
    public PaystackVerifyResponse verifyPayment(
            Long userId,
            String reference) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        if (reference == null
                || reference.isBlank()) {

            throw new IllegalArgumentException(
                    "Payment reference is required."
            );
        }

        String secretKey =
                getTestSecretKey();

        Payment payment =
                paymentRepository
                        .findByTransactionReference(
                                reference.trim()
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Payment reference was not found."
                                        )
                        );

        if (!userId.equals(
                payment.getUserId())) {

            throw new IllegalArgumentException(
                    "This payment does not belong to the authenticated user."
            );
        }

        Journey journey =
                journeyRepository
                        .findById(
                                payment.getJourneyId()
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Journey for this payment was not found."
                                        )
                        );

        Map<?, ?> gatewayResponse;

        try {
            gatewayResponse =
                    restClient
                            .get()
                            .uri(
                                    "/transaction/verify/{reference}",
                                    reference.trim()
                            )
                            .header(
                                    "Authorization",
                                    "Bearer " + secretKey
                            )
                            .retrieve()
                            .body(Map.class);

        } catch (Exception error) {
            throw new IllegalStateException(
                    "Unable to verify Paystack test transaction.",
                    error
            );
        }

        if (gatewayResponse == null
                || !Boolean.TRUE.equals(
                gatewayResponse.get("status"))) {

            throw new IllegalStateException(
                    "Paystack could not verify the transaction."
            );
        }

        Map<?, ?> data =
                asMap(
                        gatewayResponse.get("data"),
                        "Paystack returned an invalid verification response."
                );

        String gatewayStatus =
                requireText(
                        data.get("status"),
                        "Paystack transaction status is missing."
                )
                        .toLowerCase();

        String gatewayReference =
                requireText(
                        data.get("reference"),
                        "Paystack transaction reference is missing."
                );

        if (!reference.trim()
                .equals(gatewayReference)) {

            throw new IllegalStateException(
                    "Paystack verification reference does not match."
            );
        }

        long expectedAmount =
                toSubunit(
                        payment.getAmount()
                );

        long gatewayAmount =
                asLong(
                        data.get("amount"),
                        "Paystack transaction amount is missing."
                );

        if (gatewayAmount
                != expectedAmount) {

            throw new IllegalStateException(
                    "Paystack amount does not match the Link Ride journey amount."
            );
        }

        Object currencyValue =
                data.get("currency");

        if (currencyValue != null
                && !CURRENCY.equalsIgnoreCase(
                currencyValue.toString())) {

            throw new IllegalStateException(
                    "Paystack currency does not match the Link Ride transaction currency."
            );
        }

        if ("success".equals(
                gatewayStatus)) {

            payment.setPaymentStatus(
                    "SUCCESS"
            );

            if (payment.getPaidAt()
                    == null) {

                payment.setPaidAt(
                        LocalDateTime.now()
                );
            }

            Payment savedPayment =
                    paymentRepository.save(
                            payment
                    );

            if ("SELECTED".equalsIgnoreCase(
                    journey.getJourneyStatus())) {

                journey.setJourneyStatus(
                        "PAID"
                );

                journeyRepository.save(
                        journey
                );
            }

            return new PaystackVerifyResponse(
                    gatewayStatus,
                    true,
                    savedPayment
            );
        }

        payment.setPaymentStatus(
                gatewayStatus.toUpperCase()
        );

        Payment savedPayment =
                paymentRepository.save(
                        payment
                );

        return new PaystackVerifyResponse(
                gatewayStatus,
                false,
                savedPayment
        );
    }

    private Journey requirePayableJourney(
            Long userId,
            Long journeyId) {

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

        if (!"SELECTED".equalsIgnoreCase(
                journey.getJourneyStatus())) {

            throw new IllegalArgumentException(
                    "Only a SELECTED journey can be paid."
            );
        }

        Double amount =
                journey.getEstimatedCost();

        if (amount == null
                || amount <= 0) {

            throw new IllegalArgumentException(
                    "Journey has an invalid payment amount."
            );
        }

        Optional<Payment> existingPayment =
                paymentRepository
                        .findTopByJourneyIdOrderByCreatedAtDesc(
                                journeyId
                        );

        if (existingPayment.isPresent()) {

            String paymentStatus =
                    existingPayment
                            .get()
                            .getPaymentStatus();

            if ("SUCCESS".equalsIgnoreCase(
                    paymentStatus)) {

                throw new IllegalArgumentException(
                        "This journey has already been paid."
                );
            }

            if ("PENDING".equalsIgnoreCase(
                    paymentStatus)) {

                throw new IllegalArgumentException(
                        "This journey already has a pending Paystack transaction."
                );
            }
        }

        return journey;
    }

    private long toSubunit(
            Double amount) {

        return BigDecimal
                .valueOf(amount)
                .multiply(
                        BigDecimal.valueOf(100)
                )
                .setScale(
                        0,
                        RoundingMode.HALF_UP
                )
                .longValueExact();
    }

    private String getTestSecretKey() {

        String secretKey =
                System.getenv(
                        "PAYSTACK_SECRET_KEY"
                );

        if (secretKey == null
                || secretKey.isBlank()) {

            throw new IllegalStateException(
                    "PAYSTACK_SECRET_KEY is not configured."
            );
        }

        String cleanedKey =
                secretKey.trim();

        if (!cleanedKey.startsWith(
                "sk_test_")) {

            throw new IllegalStateException(
                    "Phase 7 only accepts a Paystack test secret key."
            );
        }

        return cleanedKey;
    }

    private String generateTransactionReference() {

        String reference;

        do {
            reference =
                    "LRPAY-"
                            + UUID.randomUUID()
                            .toString()
                            .replace("-", "")
                            .substring(0, 16)
                            .toUpperCase();

        } while (
                paymentRepository
                        .existsByTransactionReference(
                                reference
                        )
        );

        return reference;
    }

    private Map<?, ?> asMap(
            Object value,
            String message) {

        if (!(value instanceof Map<?, ?> map)) {
            throw new IllegalStateException(
                    message
            );
        }

        return map;
    }

    private String requireText(
            Object value,
            String message) {

        if (value == null
                || value.toString().isBlank()) {

            throw new IllegalStateException(
                    message
            );
        }

        return value
                .toString()
                .trim();
    }

    private long asLong(
            Object value,
            String message) {

        if (value instanceof Number number) {
            return number.longValue();
        }

        if (value != null) {
            try {
                return Long.parseLong(
                        value.toString()
                );

            } catch (NumberFormatException ignored) {
            }
        }

        throw new IllegalStateException(
                message
        );
    }
}
