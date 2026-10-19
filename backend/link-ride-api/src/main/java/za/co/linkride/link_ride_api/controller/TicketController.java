package za.co.linkride.link_ride_api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.dto.IssueTicketRequest;
import za.co.linkride.link_ride_api.model.Ticket;
import za.co.linkride.link_ride_api.service.TicketService;

@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    private final TicketService ticketService;

    public TicketController(
            TicketService ticketService) {

        this.ticketService =
                ticketService;
    }

    @GetMapping("/mine")
    public ResponseEntity<?> getMyTickets(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

            return ResponseEntity
                    .status(401)
                    .body(
                            "Authentication is required."
                    );
        }

        Object details =
                authentication.getDetails();

        if (!(details instanceof Long userId)) {

            return ResponseEntity
                    .status(401)
                    .body(
                            "Authentication is required."
                    );
        }

        return ResponseEntity.ok(
                ticketService
                        .getTicketsForUser(
                                userId
                        )
        );
    }

    @GetMapping("/current")
    public ResponseEntity<?> getCurrentTicket(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

            return ResponseEntity
                    .status(401)
                    .body(
                            "Authentication is required."
                    );
        }

        Object details =
                authentication.getDetails();

        if (!(details instanceof Long userId)) {

            return ResponseEntity
                    .status(401)
                    .body(
                            "Authentication is required."
                    );
        }

        return ticketService
                .getCurrentTicket(
                        userId
                )
                .<ResponseEntity<?>>map(
                        ResponseEntity::ok
                )
                .orElseGet(
                        () ->
                                ResponseEntity
                                        .notFound()
                                        .build()
                );
    }

    @PostMapping("/issue")
    public ResponseEntity<?> issueTicket(
            @RequestBody IssueTicketRequest request,
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

            Ticket ticket =
                    ticketService
                            .issueTicket(
                                    userId,
                                    request.getJourneyId()
                            );

            return ResponseEntity.ok(
                    ticket
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }

    @PostMapping("/activate")
    public ResponseEntity<?> activateTicket(
            @RequestBody IssueTicketRequest request,
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

            Ticket ticket =
                    ticketService
                            .activateTicket(
                                    userId,
                                    request.getJourneyId()
                            );

            return ResponseEntity.ok(
                    ticket
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }

    @PostMapping("/complete")
    public ResponseEntity<?> completeJourney(
            @RequestBody IssueTicketRequest request,
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

            Ticket ticket =
                    ticketService
                            .completeJourney(
                                    userId,
                                    request.getJourneyId()
                            );

            return ResponseEntity.ok(
                    ticket
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