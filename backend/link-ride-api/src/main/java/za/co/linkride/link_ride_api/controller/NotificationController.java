package za.co.linkride.link_ride_api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.model.Notification;
import za.co.linkride.link_ride_api.model.NotificationPreference;
import za.co.linkride.link_ride_api.dto.NotificationPreferencesRequest;
import za.co.linkride.link_ride_api.service.NotificationService;
import za.co.linkride.link_ride_api.service.NotificationPreferenceService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final NotificationPreferenceService
            notificationPreferenceService;

    public NotificationController(
            NotificationService notificationService,
            NotificationPreferenceService notificationPreferenceService) {

        this.notificationService =
                notificationService;

        this.notificationPreferenceService =
                notificationPreferenceService;
    }

    @GetMapping("/preferences")
    public ResponseEntity<?>
    getPreferences(
            Authentication authentication) {

        Long userId =
                authenticatedUserId(
                        authentication
                );

        if (userId == null) {
            return ResponseEntity
                    .status(401)
                    .build();
        }

        return ResponseEntity.ok(
                notificationPreferenceService
                        .getPreferences(
                                userId
                        )
        );
    }

    @PutMapping("/preferences")
    public ResponseEntity<?>
    savePreferences(
            @RequestBody NotificationPreferencesRequest request,
            Authentication authentication) {

        Long userId =
                authenticatedUserId(
                        authentication
                );

        if (userId == null) {
            return ResponseEntity
                    .status(401)
                    .build();
        }

        NotificationPreference saved =
                notificationPreferenceService
                        .savePreferences(
                                userId,
                                request
                        );

        return ResponseEntity.ok(
                saved
        );
    }

    @GetMapping("/mine")
    public ResponseEntity<?>
    getMyNotifications(
            Authentication authentication) {

        Long userId =
                authenticatedUserId(
                        authentication
                );

        if (userId == null) {
            return ResponseEntity
                    .status(401)
                    .build();
        }

        List<Notification> notifications =
                notificationService
                        .getNotificationsForUser(
                                userId
                        );

        return ResponseEntity.ok(
                notifications
        );
    }

    @GetMapping("/unread-count")
    public ResponseEntity<?>
    getUnreadCount(
            Authentication authentication) {

        Long userId =
                authenticatedUserId(
                        authentication
                );

        if (userId == null) {
            return ResponseEntity
                    .status(401)
                    .build();
        }

        return ResponseEntity.ok(
                Map.of(
                        "unreadCount",
                        notificationService
                                .getUnreadCount(
                                        userId
                                )
                )
        );
    }

    @PutMapping("/{notificationId}/read")
    public ResponseEntity<?>
    markAsRead(
            @PathVariable
            Long notificationId,
            Authentication authentication) {

        Long userId =
                authenticatedUserId(
                        authentication
                );

        if (userId == null) {
            return ResponseEntity
                    .status(401)
                    .build();
        }

        try {
            return ResponseEntity.ok(
                    notificationService
                            .markAsRead(
                                    userId,
                                    notificationId
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

    @PutMapping("/read-all")
    public ResponseEntity<?>
    markAllAsRead(
            Authentication authentication) {

        Long userId =
                authenticatedUserId(
                        authentication
                );

        if (userId == null) {
            return ResponseEntity
                    .status(401)
                    .build();
        }

        int updated =
                notificationService
                        .markAllAsRead(
                                userId
                        );

        return ResponseEntity.ok(
                Map.of(
                        "updated",
                        updated
                )
        );
    }

    private Long authenticatedUserId(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

            return null;
        }

        Object details =
                authentication.getDetails();

        if (details instanceof Long userId) {
            return userId;
        }

        return null;
    }
}
