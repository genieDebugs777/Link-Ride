package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.dto.CreateDisruptionRequest;
import za.co.linkride.link_ride_api.model.Disruption;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.JourneyLeg;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.messaging.DisruptionEventPublisher;
import za.co.linkride.link_ride_api.repository.DisruptionRepository;
import za.co.linkride.link_ride_api.repository.JourneyLegRepository;
import za.co.linkride.link_ride_api.repository.JourneyRepository;
import za.co.linkride.link_ride_api.repository.RouteRepository;
import za.co.linkride.link_ride_api.repository.TransportProviderRepository;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class DisruptionService {

    private final DisruptionRepository disruptionRepository;
    private final RouteRepository routeRepository;
    private final TransportProviderRepository transportProviderRepository;
    private final JourneyRepository journeyRepository;
    private final JourneyLegRepository journeyLegRepository;
    private final DisruptionEventPublisher disruptionEventPublisher;

    public DisruptionService(
            DisruptionRepository disruptionRepository,
            RouteRepository routeRepository,
            TransportProviderRepository transportProviderRepository,
            JourneyRepository journeyRepository,
            JourneyLegRepository journeyLegRepository,
            DisruptionEventPublisher disruptionEventPublisher) {

        this.disruptionRepository =
                disruptionRepository;

        this.routeRepository =
                routeRepository;

        this.transportProviderRepository =
                transportProviderRepository;

        this.journeyRepository =
                journeyRepository;

        this.journeyLegRepository =
                journeyLegRepository;

        this.disruptionEventPublisher =
                disruptionEventPublisher;
    }

    @Transactional
    public Disruption createDisruption(
            CreateDisruptionRequest request) {

        if (request == null) {
            throw new IllegalArgumentException(
                    "Disruption request is required."
            );
        }

        if (request.getRouteId() == null) {
            throw new IllegalArgumentException(
                    "Route ID is required."
            );
        }

        Route route =
                routeRepository
                        .findById(
                                request.getRouteId()
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Route not found."
                                        )
                        );

        Long providerId =
                route.getProviderId();

        if (providerId == null
                || !transportProviderRepository
                .existsById(providerId)) {

            throw new IllegalArgumentException(
                    "Transport provider for route was not found."
            );
        }

        String disruptionType =
                normalizeRequired(
                        request.getDisruptionType(),
                        "Disruption type is required."
                );

        String severity =
                normalizeRequired(
                        request.getSeverity(),
                        "Severity is required."
                );

        String title =
                requireText(
                        request.getTitle(),
                        "Title is required."
                );

        String description =
                requireText(
                        request.getDescription(),
                        "Description is required."
                );

        validateDisruptionType(
                disruptionType
        );

        validateSeverity(
                severity
        );

        LocalDateTime startDateTime =
                request.getStartDateTime() == null
                        ? LocalDateTime.now()
                        : request.getStartDateTime();

        LocalDateTime expectedEndDateTime =
                request.getExpectedEndDateTime();

        if (expectedEndDateTime != null
                && expectedEndDateTime
                .isBefore(startDateTime)) {

            throw new IllegalArgumentException(
                    "Expected end date/time cannot be before the start date/time."
            );
        }

        Disruption disruption =
                new Disruption(
                        route.getRouteId(),
                        providerId,
                        disruptionType,
                        severity,
                        title,
                        description,
                        "ACTIVE",
                        startDateTime,
                        expectedEndDateTime,
                        LocalDateTime.now()
                );

        Disruption savedDisruption =
                disruptionRepository.save(
                        disruption
                );

        disruptionEventPublisher
                .publishCreated(
                        savedDisruption
                );

        return savedDisruption;
    }

    public List<Disruption> getActiveDisruptions() {

        return disruptionRepository
                .findByDisruptionStatusIgnoreCaseOrderByCreatedAtDesc(
                        "ACTIVE"
                );
    }

    public List<Disruption> getDisruptionsForRoute(
            Long routeId) {

        if (routeId == null) {
            throw new IllegalArgumentException(
                    "Route ID is required."
            );
        }

        if (!routeRepository.existsById(
                routeId)) {

            throw new IllegalArgumentException(
                    "Route not found."
            );
        }

        return disruptionRepository
                .findByRouteIdOrderByCreatedAtDesc(
                        routeId
                );
    }

    public List<Disruption> getActiveDisruptionsForRoute(
            Long routeId) {

        if (routeId == null) {
            throw new IllegalArgumentException(
                    "Route ID is required."
            );
        }

        if (!routeRepository.existsById(
                routeId)) {

            throw new IllegalArgumentException(
                    "Route not found."
            );
        }

        return disruptionRepository
                .findByRouteIdAndDisruptionStatusIgnoreCaseOrderByCreatedAtDesc(
                        routeId,
                        "ACTIVE"
                );
    }

    public List<Disruption> getActiveDisruptionsForJourney(
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
                        .findById(
                                journeyId
                        )
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

        List<JourneyLeg> journeyLegs =
                journeyLegRepository
                        .findByJourneyIdOrderByLegOrderAsc(
                                journeyId
                        );

        if (journeyLegs.isEmpty()) {
            return List.of();
        }

        Set<Long> routeIds =
                new HashSet<>();

        for (JourneyLeg journeyLeg
                : journeyLegs) {

            Long routeId =
                    journeyLeg.getRouteId();

            if (routeId != null) {
                routeIds.add(
                        routeId
                );
            }
        }

        if (routeIds.isEmpty()) {
            return List.of();
        }

        return getActiveDisruptions()
                .stream()
                .filter(
                        disruption ->
                                disruption.getRouteId() != null
                                        && routeIds.contains(
                                        disruption.getRouteId()
                                )
                )
                .toList();
    }

    @Transactional
    public Disruption resolveDisruption(
            Long disruptionId) {

        if (disruptionId == null) {
            throw new IllegalArgumentException(
                    "Disruption ID is required."
            );
        }

        Disruption disruption =
                disruptionRepository
                        .findById(
                                disruptionId
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Disruption not found."
                                        )
                        );

        if ("RESOLVED".equalsIgnoreCase(
                disruption.getDisruptionStatus())) {

            return disruption;
        }

        disruption.setDisruptionStatus(
                "RESOLVED"
        );

        Disruption savedDisruption =
                disruptionRepository.save(
                        disruption
                );

        disruptionEventPublisher
                .publishResolved(
                        savedDisruption
                );

        return savedDisruption;
    }

    private String normalizeRequired(
            String value,
            String message) {

        String normalized =
                requireText(
                        value,
                        message
                )
                        .trim()
                        .toUpperCase();

        return normalized;
    }

    private String requireText(
            String value,
            String message) {

        if (value == null
                || value.isBlank()) {

            throw new IllegalArgumentException(
                    message
            );
        }

        return value.trim();
    }

    private void validateDisruptionType(
            String disruptionType) {

        if (!List.of(
                "DELAY",
                "CANCELLATION",
                "SERVICE_SUSPENSION",
                "ROUTE_CHANGE",
                "STATION_CLOSURE",
                "OTHER"
        ).contains(disruptionType)) {

            throw new IllegalArgumentException(
                    "Unsupported disruption type."
            );
        }
    }

    private void validateSeverity(
            String severity) {

        if (!List.of(
                "LOW",
                "MEDIUM",
                "HIGH",
                "CRITICAL"
        ).contains(severity)) {

            throw new IllegalArgumentException(
                    "Unsupported disruption severity."
            );
        }
    }
}
