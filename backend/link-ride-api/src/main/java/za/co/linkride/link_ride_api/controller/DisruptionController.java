package za.co.linkride.link_ride_api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.dto.CreateDisruptionRequest;
import za.co.linkride.link_ride_api.model.Disruption;
import za.co.linkride.link_ride_api.service.DisruptionService;

import java.util.List;

@RestController
@RequestMapping("/api/disruptions")
public class DisruptionController {

    private final DisruptionService disruptionService;

    public DisruptionController(
            DisruptionService disruptionService) {

        this.disruptionService =
                disruptionService;
    }

    // AUTHENTICATED USERS - ACTIVE DISRUPTIONS
    @GetMapping("/active")
    public ResponseEntity<List<Disruption>>
    getActiveDisruptions(
            Authentication authentication) {

        if (!isAuthenticated(
                authentication
        )) {

            return ResponseEntity
                    .status(401)
                    .build();
        }

        return ResponseEntity.ok(
                disruptionService
                        .getActiveDisruptions()
        );
    }

    // AUTHENTICATED USERS - ROUTE DISRUPTIONS
    @GetMapping("/route/{routeId}")
    public ResponseEntity<?>
    getDisruptionsForRoute(
            @PathVariable Long routeId,
            @RequestParam(
                    name = "activeOnly",
                    defaultValue = "false"
            )
            boolean activeOnly,
            Authentication authentication) {

        if (!isAuthenticated(
                authentication
        )) {

            return ResponseEntity
                    .status(401)
                    .build();
        }

        try {
            if (activeOnly) {

                return ResponseEntity.ok(
                        disruptionService
                                .getActiveDisruptionsForRoute(
                                        routeId
                                )
                );
            }

            return ResponseEntity.ok(
                    disruptionService
                            .getDisruptionsForRoute(
                                    routeId
                            )
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }

    // AUTHENTICATED USERS - OWN JOURNEY DISRUPTIONS
    @GetMapping("/journey/{journeyId}")
    public ResponseEntity<?>
    getDisruptionsForJourney(
            @PathVariable Long journeyId,
            Authentication authentication) {

        if (!isAuthenticated(
                authentication
        )) {

            return ResponseEntity
                    .status(401)
                    .build();
        }

        Object details =
                authentication.getDetails();

        if (!(details instanceof Long userId)) {

            return ResponseEntity
                    .status(401)
                    .build();
        }

        try {
            return ResponseEntity.ok(
                    disruptionService
                            .getActiveDisruptionsForJourney(
                                    userId,
                                    journeyId
                            )
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }

    // OPERATOR / ADMIN - CREATE DISRUPTION
    @PostMapping
    public ResponseEntity<?>
    createDisruption(
            @RequestBody
            CreateDisruptionRequest request,
            Authentication authentication) {

        if (!hasAnyRole(
                authentication,
                "ROLE_OPERATOR",
                "ROLE_ADMIN"
        )) {

            return ResponseEntity
                    .status(403)
                    .body(
                            "Operator or administrator access is required."
                    );
        }

        try {
            Disruption disruption =
                    disruptionService
                            .createDisruption(
                                    request
                            );

            return ResponseEntity.ok(
                    disruption
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }

    // OPERATOR / ADMIN - RESOLVE DISRUPTION
    @PutMapping("/{id}/resolve")
    public ResponseEntity<?>
    resolveDisruption(
            @PathVariable Long id,
            Authentication authentication) {

        if (!hasAnyRole(
                authentication,
                "ROLE_OPERATOR",
                "ROLE_ADMIN"
        )) {

            return ResponseEntity
                    .status(403)
                    .body(
                            "Operator or administrator access is required."
                    );
        }

        try {
            return ResponseEntity.ok(
                    disruptionService
                            .resolveDisruption(
                                    id
                            )
            );

        } catch (IllegalArgumentException error) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            error.getMessage()
                    );
        }
    }

    private boolean isAuthenticated(
            Authentication authentication) {

        if (authentication == null ||
                !authentication.isAuthenticated()) {

            return false;
        }

        Object details =
                authentication.getDetails();

        return details instanceof Long;
    }

    private boolean hasAnyRole(
            Authentication authentication,
            String... roles) {

        if (!isAuthenticated(
                authentication
        )) {

            return false;
        }

        for (String role : roles) {

            boolean hasRole =
                    authentication
                            .getAuthorities()
                            .stream()
                            .anyMatch(
                                    authority ->
                                            role.equals(
                                                    authority.getAuthority()
                                            )
                            );

            if (hasRole) {
                return true;
            }
        }

        return false;
    }
}
