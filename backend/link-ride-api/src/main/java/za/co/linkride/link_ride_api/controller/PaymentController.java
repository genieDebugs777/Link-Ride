package za.co.linkride.link_ride_api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.dto.ProcessPaymentRequest;
import za.co.linkride.link_ride_api.model.Payment;
import za.co.linkride.link_ride_api.service.PaymentService;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(
            PaymentService paymentService) {

        this.paymentService =
                paymentService;
    }

    @PostMapping("/process")
    public ResponseEntity<?> processPayment(
            @RequestBody ProcessPaymentRequest request,
            Authentication authentication) {

        try {
            if (authentication == null
                    || !authentication.isAuthenticated()) {

                return ResponseEntity
                        .status(401)
                        .body(
                                "Authentication is required."
                        );
            }

            Long userId =
                    (Long) authentication
                            .getDetails();

            Payment payment =
                    paymentService
                            .processPayment(
                                    userId,
                                    request.getJourneyId(),
                                    request.getPaymentMethod()
                            );

            return ResponseEntity.ok(
                    payment
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }
}