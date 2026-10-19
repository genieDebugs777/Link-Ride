package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.event.DisruptionEvent;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.JourneyLeg;
import za.co.linkride.link_ride_api.model.Notification;
import za.co.linkride.link_ride_api.repository.JourneyLegRepository;
import za.co.linkride.link_ride_api.repository.JourneyRepository;
import za.co.linkride.link_ride_api.repository.NotificationRepository;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final JourneyLegRepository journeyLegRepository;
    private final JourneyRepository journeyRepository;
    private final NotificationPreferenceService
            notificationPreferenceService;

    public NotificationService(
            NotificationRepository notificationRepository,
            JourneyLegRepository journeyLegRepository,
            JourneyRepository journeyRepository,
            NotificationPreferenceService notificationPreferenceService) {

        this.notificationRepository =
                notificationRepository;

        this.journeyLegRepository =
                journeyLegRepository;

        this.journeyRepository =
                journeyRepository;

        this.notificationPreferenceService =
                notificationPreferenceService;
    }

    @Transactional
    public int createNotificationsForDisruptionEvent(
            DisruptionEvent event) {

        if (event == null
                || event.getDisruptionId() == null
                || event.getRouteId() == null) {

            return 0;
        }

        String eventType =
                normalizeEventType(
                        event.getEventType()
                );

        List<JourneyLeg> affectedLegs =
                journeyLegRepository
                        .findByRouteId(
                                event.getRouteId()
                        );

        if (affectedLegs.isEmpty()) {
            return 0;
        }

        Set<Long> affectedUserIds =
                new HashSet<>();

        for (JourneyLeg leg
                : affectedLegs) {

            Journey journey =
                    journeyRepository
                            .findById(
                                    leg.getJourneyId()
                            )
                            .orElse(null);

            if (journey == null
                    || journey.getUserId() == null
                    || !isCurrentJourneyStatus(
                    journey.getJourneyStatus()
            )) {
                continue;
            }

            affectedUserIds.add(
                    journey.getUserId()
            );
        }

        int createdCount = 0;

        for (Long userId
                : affectedUserIds) {

            if (!notificationPreferenceService
                    .allowsDisruptionAlerts(
                            userId
                    )) {

                continue;
            }

            boolean alreadyExists =
                    notificationRepository
                            .existsByUserIdAndDisruptionIdAndNotificationTypeIgnoreCase(
                                    userId,
                                    event.getDisruptionId(),
                                    eventType
                            );

            if (alreadyExists) {
                continue;
            }

            Notification notification =
                    new Notification(
                            userId,
                            event.getDisruptionId(),
                            event.getRouteId(),
                            eventType,
                            normalizeSeverity(
                                    event.getSeverity()
                            ),
                            notificationTitle(
                                    event
                            ),
                            notificationMessage(
                                    event
                            ),
                            false,
                            LocalDateTime.now()
                    );

            notificationRepository.save(
                    notification
            );

            createdCount++;
        }

        return createdCount;
    }

    public List<Notification> getNotificationsForUser(
            Long userId) {

        validateUserId(
                userId
        );

        return notificationRepository
                .findByUserIdOrderByCreatedAtDesc(
                        userId
                );
    }

    public long getUnreadCount(
            Long userId) {

        validateUserId(
                userId
        );

        return notificationRepository
                .countByUserIdAndReadFalse(
                        userId
                );
    }

    @Transactional
    public Notification markAsRead(
            Long userId,
            Long notificationId) {

        validateUserId(
                userId
        );

        if (notificationId == null) {
            throw new IllegalArgumentException(
                    "Notification ID is required."
            );
        }

        Notification notification =
                notificationRepository
                        .findById(
                                notificationId
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Notification not found."
                                        )
                        );

        if (!userId.equals(
                notification.getUserId())) {

            throw new IllegalArgumentException(
                    "This notification does not belong to the authenticated user."
            );
        }

        if (!notification.isRead()) {
            notification.setRead(
                    true
            );

            notification =
                    notificationRepository
                            .save(
                                    notification
                            );
        }

        return notification;
    }

    @Transactional
    public int markAllAsRead(
            Long userId) {

        validateUserId(
                userId
        );

        List<Notification> notifications =
                notificationRepository
                        .findByUserIdOrderByCreatedAtDesc(
                                userId
                        );

        int updatedCount = 0;

        for (Notification notification
                : notifications) {

            if (notification.isRead()) {
                continue;
            }

            notification.setRead(
                    true
            );

            updatedCount++;
        }

        if (updatedCount > 0) {
            notificationRepository
                    .saveAll(
                            notifications
                    );
        }

        return updatedCount;
    }

    private boolean isCurrentJourneyStatus(
            String status) {

        if (status == null) {
            return false;
        }

        return switch (
                status.trim().toUpperCase()
                ) {
            case "SELECTED",
                 "PAID",
                 "READY",
                 "IN_PROGRESS" -> true;

            default -> false;
        };
    }

    private String normalizeEventType(
            String eventType) {

        if (eventType == null
                || eventType.isBlank()) {

            return "DISRUPTION_UPDATE";
        }

        return eventType
                .trim()
                .toUpperCase();
    }

    private String normalizeSeverity(
            String severity) {

        if (severity == null
                || severity.isBlank()) {

            return "MEDIUM";
        }

        return severity
                .trim()
                .toUpperCase();
    }

    private String notificationTitle(
            DisruptionEvent event) {

        if ("DISRUPTION_RESOLVED"
                .equalsIgnoreCase(
                        event.getEventType()
                )) {

            return "Journey disruption resolved";
        }

        return event.getTitle() == null
                || event.getTitle().isBlank()
                ? "Journey disruption alert"
                : event.getTitle().trim();
    }

    private String notificationMessage(
            DisruptionEvent event) {

        String routeText =
                "Route #"
                        + event.getRouteId();

        if ("DISRUPTION_RESOLVED"
                .equalsIgnoreCase(
                        event.getEventType()
                )) {

            return routeText
                    + " is no longer marked as disrupted.";
        }

        String description =
                event.getDescription() == null
                        || event.getDescription().isBlank()
                        ? "A transport disruption may affect your journey."
                        : event.getDescription().trim();

        return routeText
                + ": "
                + description;
    }

    private void validateUserId(
            Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }
    }
}
