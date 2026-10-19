package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.dto.ActiveJourneyResponse;
import za.co.linkride.link_ride_api.dto.JourneyLegOptionResponse;
import za.co.linkride.link_ride_api.dto.SelectJourneyRequest;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.JourneyLeg;
import za.co.linkride.link_ride_api.repository.JourneyLegRepository;
import za.co.linkride.link_ride_api.repository.JourneyRepository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class JourneyService {

    private final JourneyRepository journeyRepository;
    private final JourneyLegRepository journeyLegRepository;

    public JourneyService(
            JourneyRepository journeyRepository,
            JourneyLegRepository journeyLegRepository) {

        this.journeyRepository =
                journeyRepository;

        this.journeyLegRepository =
                journeyLegRepository;
    }

    // ============================================================
    // CREATE
    // ============================================================

    public Journey createJourney(
            Journey journey) {

        return journeyRepository.save(
                journey
        );
    }

    // ============================================================
    // SELECT / PERSIST PLANNED JOURNEY
    // ============================================================

    /*
     * Only a commuter-selected journey is persisted.
     *
     * Generated alternatives from /plan remain
     * temporary and are never written to the DB.
     */
    @Transactional
    public Journey selectJourney(
            Long userId,
            SelectJourneyRequest request) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        if (request == null) {
            throw new IllegalArgumentException(
                    "Journey selection request is required."
            );
        }

        List<JourneyLegOptionResponse> requestedLegs =
                request.getLegs();

        if (requestedLegs == null
                || requestedLegs.isEmpty()) {

            throw new IllegalArgumentException(
                    "Selected journey must contain at least one leg."
            );
        }

        JourneyLegOptionResponse firstLeg =
                requestedLegs.get(0);

        JourneyLegOptionResponse lastLeg =
                requestedLegs.get(
                        requestedLegs.size() - 1
                );

        String origin =
                firstLeg.getStartLocationName();

        String destination =
                lastLeg.getEndLocationName();

        if (origin == null
                || origin.isBlank()
                || destination == null
                || destination.isBlank()) {

            throw new IllegalArgumentException(
                    "Selected journey must contain valid origin and destination names."
            );
        }

        Journey journey =
                new Journey(
                        userId,
                        origin,
                        destination,
                        LocalDateTime.now(),
                        request.getTotalDurationMinutes(),
                        request.getTotalCost(),
                        "SELECTED"
                );

        Journey savedJourney =
                journeyRepository.save(
                        journey
                );

        List<JourneyLeg> journeyLegs =
                new ArrayList<>();

        for (JourneyLegOptionResponse leg
                : requestedLegs) {

            JourneyLeg journeyLeg =
                    new JourneyLeg(
                            savedJourney.getJourneyId(),
                            leg.getRouteId(),
                            leg.getStartLocationName(),
                            leg.getEndLocationName(),
                            leg.getStartLatitude(),
                            leg.getStartLongitude(),
                            leg.getEndLatitude(),
                            leg.getEndLongitude(),
                            leg.getTransportMode(),
                            leg.getLegOrder(),
                            leg.getDurationMinutes(),
                            leg.getCost()
                    );

            journeyLegs.add(
                    journeyLeg
            );
        }

        journeyLegRepository.saveAll(
                journeyLegs
        );

        return savedJourney;
    }

    // ============================================================
    // READ
    // ============================================================

    public List<Journey> getAllJourneys() {

        return journeyRepository.findAll();
    }

    public Optional<Journey> getJourneyById(
            Long journeyId) {

        return journeyRepository.findById(
                journeyId
        );
    }

    public List<Journey> getJourneysByUserId(
            Long userId) {

        return journeyRepository
                .findByUserIdOrderBySearchDateTimeDesc(
                        userId
                );
    }

    // ============================================================
    // READ - ACTIVE JOURNEY WITH ORDERED LEGS
    // ============================================================

    public ActiveJourneyResponse getActiveJourney(
            Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        List<Journey> journeys =
                journeyRepository
                        .findByUserIdOrderBySearchDateTimeDesc(
                                userId
                        );

        Journey activeJourney =
                journeys.stream()
                        .filter(
                                journey ->
                                        journey.getJourneyStatus() != null
                                                && journey.getJourneyStatus()
                                                .equalsIgnoreCase(
                                                        "IN_PROGRESS"
                                                )
                        )
                        .findFirst()
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "No active journey found."
                                        )
                        );

        List<JourneyLeg> orderedLegs =
                journeyLegRepository
                        .findByJourneyIdOrderByLegOrderAsc(
                                activeJourney.getJourneyId()
                        );

        if (orderedLegs.isEmpty()) {
            throw new IllegalArgumentException(
                    "Active journey has no persisted journey legs."
            );
        }

        return new ActiveJourneyResponse(
                activeJourney,
                orderedLegs
        );
    }

    // ============================================================
    // UPDATE
    // ============================================================

    public Journey updateJourney(
            Long journeyId,
            Journey updatedJourney) {

        Journey existingJourney =
                journeyRepository
                        .findById(
                                journeyId
                        )
                        .orElseThrow(
                                () ->
                                        new RuntimeException(
                                                "Journey not found with ID: "
                                                        + journeyId
                                        )
                        );

        existingJourney.setUserId(
                updatedJourney.getUserId()
        );

        existingJourney.setOrigin(
                updatedJourney.getOrigin()
        );

        existingJourney.setDestination(
                updatedJourney.getDestination()
        );

        existingJourney.setSearchDateTime(
                updatedJourney.getSearchDateTime()
        );

        existingJourney.setEstimatedDuration(
                updatedJourney.getEstimatedDuration()
        );

        existingJourney.setEstimatedCost(
                updatedJourney.getEstimatedCost()
        );

        existingJourney.setJourneyStatus(
                updatedJourney.getJourneyStatus()
        );

        return journeyRepository.save(
                existingJourney
        );
    }

    // ============================================================
    // DELETE
    // ============================================================

    @Transactional
    public void deleteJourney(
            Long journeyId) {

        if (!journeyRepository.existsById(
                journeyId)) {

            throw new RuntimeException(
                    "Journey not found with ID: "
                            + journeyId
            );
        }

        List<JourneyLeg> journeyLegs =
                journeyLegRepository
                        .findByJourneyIdOrderByLegOrderAsc(
                                journeyId
                        );

        if (!journeyLegs.isEmpty()) {
            journeyLegRepository.deleteAll(
                    journeyLegs
            );
        }

        journeyRepository.deleteById(
                journeyId
        );
    }
}