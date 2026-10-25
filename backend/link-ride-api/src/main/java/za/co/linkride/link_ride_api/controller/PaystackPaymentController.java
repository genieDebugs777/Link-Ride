package za.co.linkride.link_ride_api.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.dto.PaystackInitializeRequest;
import za.co.linkride.link_ride_api.dto.PaystackInitializeResponse;
import za.co.linkride.link_ride_api.dto.PaystackVerifyResponse;
import za.co.linkride.link_ride_api.service.PaystackPaymentService;

@RestController
@RequestMapping("/api/payments/paystack")
public class PaystackPaymentController {

    private final PaystackPaymentService paystackPaymentService;

    public PaystackPaymentController(
            PaystackPaymentService paystackPaymentService) {

        this.paystackPaymentService =
                paystackPaymentService;
    }

    @PostMapping("/initialize")
    public ResponseEntity<?> initialize(
            @RequestBody PaystackInitializeRequest request,
            Authentication authentication) {

        try {
            Long userId =
                    authenticatedUserId(
                            authentication
                    );

            PaystackInitializeResponse response =
                    paystackPaymentService
                            .initializePayment(
                                    userId,
                                    request.getJourneyId()
                            );

            return ResponseEntity.ok(
                    response
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );

        } catch (IllegalStateException error) {

            return ResponseEntity
                    .status(
                            HttpStatus.SERVICE_UNAVAILABLE
                    )
                    .body(
                            error.getMessage()
                    );
        }
    }

    @PostMapping("/verify/{reference}")
    public ResponseEntity<?> verify(
            @PathVariable String reference,
            Authentication authentication) {

        try {
            Long userId =
                    authenticatedUserId(
                            authentication
                    );

            PaystackVerifyResponse response =
                    paystackPaymentService
                            .verifyPayment(
                                    userId,
                                    reference
                            );

            return ResponseEntity.ok(
                    response
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );

        } catch (IllegalStateException error) {

            return ResponseEntity
                    .status(
                            HttpStatus.SERVICE_UNAVAILABLE
                    )
                    .body(
                            error.getMessage()
                    );
        }
    }

    private Long authenticatedUserId(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

            throw new IllegalArgumentException(
                    "Authentication is required."
            );
        }

        Object details =
                authentication.getDetails();

        if (!(details instanceof Long userId)) {

            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        return userId;
    }
}
