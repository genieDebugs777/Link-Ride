package za.co.linkride.link_ride_api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.dto.JourneyLegOptionResponse;
import za.co.linkride.link_ride_api.dto.JourneyOptionResponse;
import za.co.linkride.link_ride_api.dto.PlanJourneyRequest;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.repository.StopRepository;
import za.co.linkride.link_ride_api.repository.RouteRepository;
import za.co.linkride.link_ride_api.service.CandidateJourneyFilterService;
import za.co.linkride.link_ride_api.service.CandidateJourneyService;
import za.co.linkride.link_ride_api.service.JourneyLegBuilderService;
import za.co.linkride.link_ride_api.service.JourneyPlanningService;
import za.co.linkride.link_ride_api.service.JourneyService;
import za.co.linkride.link_ride_api.service.JourneyTransferService;
import org.springframework.security.core.Authentication;
import za.co.linkride.link_ride_api.dto.SelectJourneyRequest;
import za.co.linkride.link_ride_api.dto.ActiveJourneyResponse;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/api/journeys")
public class JourneyController {

    private final JourneyService journeyService;
    private final StopRepository stopRepository;
    private final RouteRepository routeRepository;
    private final JourneyPlanningService journeyPlanningService;
    private final JourneyLegBuilderService journeyLegBuilderService;
    private final JourneyTransferService journeyTransferService;
    private final CandidateJourneyService candidateJourneyService;
    private final CandidateJourneyFilterService candidateJourneyFilterService;

    public JourneyController(
            JourneyService journeyService,
            StopRepository stopRepository,
            RouteRepository routeRepository,
            JourneyPlanningService journeyPlanningService,
            JourneyLegBuilderService journeyLegBuilderService,
            JourneyTransferService journeyTransferService,
            CandidateJourneyService candidateJourneyService,
            CandidateJourneyFilterService candidateJourneyFilterService) {

        this.journeyService =
                journeyService;

        this.stopRepository =
                stopRepository;

        this.routeRepository =
                routeRepository;

        this.journeyPlanningService =
                journeyPlanningService;

        this.journeyLegBuilderService =
                journeyLegBuilderService;

        this.journeyTransferService =
                journeyTransferService;

        this.candidateJourneyService =
                candidateJourneyService;

        this.candidateJourneyFilterService =
                candidateJourneyFilterService;
    }

    // ============================================================
    // CREATE
    // ============================================================

    @PostMapping
    public Journey createJourney(
            @RequestBody Journey journey) {

        return journeyService.createJourney(
                journey
        );
    }

    // ============================================================
    // READ - ALL JOURNEYS
    // ============================================================

    @GetMapping
    public List<Journey> getAllJourneys() {

        return journeyService.getAllJourneys();
    }

    // ============================================================
    // READ - JOURNEY BY ID
    // ============================================================

    @GetMapping("/{id}")
    public ResponseEntity<Journey> getJourneyById(
            @PathVariable Long id) {

        return journeyService
                .getJourneyById(id)
                .map(
                        ResponseEntity::ok
                )
                .orElseGet(
                        () ->
                                ResponseEntity
                                        .notFound()
                                        .build()
                );
    }

    // ============================================================
    // READ - JOURNEYS BY USER
    // ============================================================

    @GetMapping("/user/{userId}")
    public List<Journey> getJourneysByUserId(
            @PathVariable Long userId) {

        return journeyService
                .getJourneysByUserId(
                        userId
                );
    }

    // ============================================================
// READ - AUTHENTICATED USER'S JOURNEYS
// ============================================================

    @GetMapping("/mine")
    public ResponseEntity<List<Journey>> getMyJourneys(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

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

        return ResponseEntity.ok(
                journeyService.getJourneysByUserId(
                        userId
                )
        );
    }

    // ============================================================
// READ - AUTHENTICATED USER'S ACTIVE JOURNEY
// ============================================================

    @GetMapping("/active")
    public ResponseEntity<?> getActiveJourney(
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

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

            ActiveJourneyResponse activeJourney =
                    journeyService
                            .getActiveJourney(
                                    userId
                            );

            return ResponseEntity.ok(
                    activeJourney
            );

        } catch (IllegalArgumentException exception) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            exception.getMessage()
                    );
        }
    }

    // ============================================================
    // STOP AUTOCOMPLETE
    // ============================================================

    @GetMapping("/stops/search")
    public List<Stop> searchStops(
            @RequestParam(name = "query")
            String query) {

        String cleanedQuery =
                query.trim();

        if (cleanedQuery.length() < 2) {
            return List.of();
        }

        return stopRepository
                .findTop10ByStopNameContainingIgnoreCaseOrderByStopNameAsc(
                        cleanedQuery
                );
    }

    // ============================================================
    // MAIN JOURNEY PLANNING ENDPOINT
    // ============================================================

    /*
     * FINAL JOURNEY-OPTIONS PIPELINE
     *
     * 1. Generate diverse feasible journey families.
     *
     * 2. Remove duplicate / pointless / unreasonable
     *    journey variants.
     *
     * 3. Convert every surviving path into commuter-facing journey legs.
     *
     * 4. Rank the complete option set.
     *
     * 5. Apply one or more tags:
     *
     *    FASTEST
     *    CHEAPEST
     *    BALANCED
     *    FEWEST_TRANSFERS
     *
     * 6. Return every sensible journey alternative.
     *
     * Nothing is persisted here.
     */
    @PostMapping("/plan")
    public ResponseEntity<List<JourneyOptionResponse>>
    planJourney(
            @RequestBody PlanJourneyRequest request) {

        List<JourneyPlanningService.PlannedPath>
                generatedCandidates =
                candidateJourneyService
                        .generateCandidates(
                                request.getOriginLatitude(),
                                request.getOriginLongitude(),
                                request.getDestinationStopId()
                        );

        List<JourneyPlanningService.PlannedPath>
                meaningfulCandidates =
                candidateJourneyFilterService
                        .filterMeaningfulCandidates(
                                generatedCandidates
                        );

        meaningfulCandidates =
                applyTransportPreferences(
                        meaningfulCandidates,
                        request
                );

        if (meaningfulCandidates.isEmpty()) {

            return ResponseEntity
                    .notFound()
                    .build();
        }

        List<JourneyOptionResponse> options =
                new ArrayList<>();

        for (JourneyPlanningService.PlannedPath
                candidate : meaningfulCandidates) {

            options.add(
                    buildJourneyOption(
                            List.of(),
                            candidate
                    )
            );
        }

        applyRankingTags(
                options
        );

        sortJourneyOptions(
                options,
                request
        );

        return ResponseEntity.ok(
                options
        );
    }

    // ============================================================
// SELECT / PERSIST JOURNEY
// ============================================================

    @PostMapping("/select")
    public ResponseEntity<Journey> selectJourney(
            @RequestBody SelectJourneyRequest request,
            Authentication authentication) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

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

            Journey savedJourney =
                    journeyService.selectJourney(
                            userId,
                            request
                    );

            return ResponseEntity.ok(
                    savedJourney
            );

        } catch (IllegalArgumentException exception) {

            return ResponseEntity
                    .badRequest()
                    .build();
        }
    }

    // ============================================================
    // CANDIDATE DEBUG ENDPOINT
    // ============================================================

    /*
     * Shows the sensible journey families before
     * ranking tags are applied.
     *
     * Nothing is persisted.
     */
    @PostMapping("/plan/candidates/debug")
    public ResponseEntity<List<JourneyOptionResponse>>
    planCandidatesDebug(
            @RequestBody PlanJourneyRequest request) {

        List<JourneyPlanningService.PlannedPath>
                generatedCandidates =
                candidateJourneyService
                        .generateCandidates(
                                request.getOriginLatitude(),
                                request.getOriginLongitude(),
                                request.getDestinationStopId()
                        );

        List<JourneyPlanningService.PlannedPath>
                meaningfulCandidates =
                candidateJourneyFilterService
                        .filterMeaningfulCandidates(
                                generatedCandidates
                        );

        if (meaningfulCandidates.isEmpty()) {

            return ResponseEntity
                    .notFound()
                    .build();
        }

        List<JourneyOptionResponse> candidates =
                new ArrayList<>();

        for (JourneyPlanningService.PlannedPath
                candidate : meaningfulCandidates) {

            candidates.add(
                    buildJourneyOption(
                            List.of(),
                            candidate
                    )
            );
        }

        return ResponseEntity.ok(
                candidates
        );
    }

    // ============================================================
    // EXISTING SINGLE-STRATEGY DEBUG ENDPOINTS
    // ============================================================

    @PostMapping("/plan/debug")
    public ResponseEntity<JourneyOptionResponse>
    planFastestDebug(
            @RequestBody PlanJourneyRequest request) {

        return journeyPlanningService
                .findFastestPath(
                        request.getOriginLatitude(),
                        request.getOriginLongitude(),
                        request.getDestinationStopId()
                )
                .map(
                        plannedPath ->
                                ResponseEntity.ok(
                                        buildJourneyOption(
                                                List.of(
                                                        "FASTEST"
                                                ),
                                                plannedPath
                                        )
                                )
                )
                .orElseGet(
                        () ->
                                ResponseEntity
                                        .notFound()
                                        .build()
                );
    }

    @PostMapping("/plan/cheapest/debug")
    public ResponseEntity<JourneyOptionResponse>
    planCheapestDebug(
            @RequestBody PlanJourneyRequest request) {

        return journeyPlanningService
                .findCheapestPath(
                        request.getOriginLatitude(),
                        request.getOriginLongitude(),
                        request.getDestinationStopId()
                )
                .map(
                        plannedPath ->
                                ResponseEntity.ok(
                                        buildJourneyOption(
                                                List.of(
                                                        "CHEAPEST"
                                                ),
                                                plannedPath
                                        )
                                )
                )
                .orElseGet(
                        () ->
                                ResponseEntity
                                        .notFound()
                                        .build()
                );
    }

    @PostMapping("/plan/fewest-transfers/debug")
    public ResponseEntity<JourneyOptionResponse>
    planFewestTransfersDebug(
            @RequestBody PlanJourneyRequest request) {

        return journeyPlanningService
                .findFewestTransfersPath(
                        request.getOriginLatitude(),
                        request.getOriginLongitude(),
                        request.getDestinationStopId()
                )
                .map(
                        plannedPath ->
                                ResponseEntity.ok(
                                        buildJourneyOption(
                                                List.of(
                                                        "FEWEST_TRANSFERS"
                                                ),
                                                plannedPath
                                        )
                                )
                )
                .orElseGet(
                        () ->
                                ResponseEntity
                                        .notFound()
                                        .build()
                );
    }

    @PostMapping("/plan/balanced/debug")
    public ResponseEntity<JourneyOptionResponse>
    planBalancedDebug(
            @RequestBody PlanJourneyRequest request) {

        return journeyPlanningService
                .findBalancedPath(
                        request.getOriginLatitude(),
                        request.getOriginLongitude(),
                        request.getDestinationStopId()
                )
                .map(
                        plannedPath ->
                                ResponseEntity.ok(
                                        buildJourneyOption(
                                                List.of(
                                                        "BALANCED"
                                                ),
                                                plannedPath
                                        )
                                )
                )
                .orElseGet(
                        () ->
                                ResponseEntity
                                        .notFound()
                                        .build()
                );
    }

    // ============================================================
    // JOURNEY OPTION BUILDING
    // ============================================================

    private JourneyOptionResponse buildJourneyOption(
            List<String> tags,
            JourneyPlanningService.PlannedPath
                    plannedPath) {

        List<JourneyLegOptionResponse> legs =
                journeyLegBuilderService
                        .buildLegs(
                                plannedPath
                        );

        int totalDurationMinutes =
                legs.stream()
                        .map(
                                JourneyLegOptionResponse
                                        ::getDurationMinutes
                        )
                        .filter(
                                value -> value != null
                        )
                        .mapToInt(
                                Integer::intValue
                        )
                        .sum();

        double totalCost =
                legs.stream()
                        .map(
                                JourneyLegOptionResponse
                                        ::getCost
                        )
                        .filter(
                                value -> value != null
                        )
                        .mapToDouble(
                                Double::doubleValue
                        )
                        .sum();

        totalCost =
                Math.round(
                        totalCost * 100.0
                ) / 100.0;

        int transferCount =
                journeyTransferService
                        .countTransfers(
                                plannedPath
                                        .getEdgePath()
                        );

        return new JourneyOptionResponse(
                tags,
                totalDurationMinutes,
                totalCost,
                transferCount,
                legs
        );
    }

    // ============================================================
    // RANKING / TAGGING
    // ============================================================

    /*
     * Applies ranking tags across the COMPLETE set
     * of sensible journey alternatives.
     *
     * One journey may win several categories.
     *
     * Example:
     *
     * [
     *   "FASTEST",
     *   "CHEAPEST",
     *   "FEWEST_TRANSFERS"
     * ]
     */
    private void applyRankingTags(
            List<JourneyOptionResponse> options) {

        if (options == null
                || options.isEmpty()) {

            return;
        }

        int fastestDuration =
                options.stream()
                        .map(
                                JourneyOptionResponse
                                        ::getTotalDurationMinutes
                        )
                        .filter(
                                value -> value != null
                        )
                        .mapToInt(
                                Integer::intValue
                        )
                        .min()
                        .orElse(
                                Integer.MAX_VALUE
                        );

        double cheapestCost =
                options.stream()
                        .map(
                                JourneyOptionResponse
                                        ::getTotalCost
                        )
                        .filter(
                                value -> value != null
                        )
                        .mapToDouble(
                                Double::doubleValue
                        )
                        .min()
                        .orElse(
                                Double.MAX_VALUE
                        );

        int fewestTransfers =
                options.stream()
                        .map(
                                JourneyOptionResponse
                                        ::getTransferCount
                        )
                        .filter(
                                value -> value != null
                        )
                        .mapToInt(
                                Integer::intValue
                        )
                        .min()
                        .orElse(
                                Integer.MAX_VALUE
                        );

        double bestBalancedScore =
                options.stream()
                        .mapToDouble(
                                this::balancedScore
                        )
                        .min()
                        .orElse(
                                Double.MAX_VALUE
                        );

        for (JourneyOptionResponse option
                : options) {

            List<String> tags =
                    new ArrayList<>();

            if (option.getTotalDurationMinutes()
                    != null
                    && option.getTotalDurationMinutes()
                    == fastestDuration) {

                tags.add(
                        "FASTEST"
                );
            }

            if (option.getTotalCost()
                    != null
                    && Double.compare(
                    option.getTotalCost(),
                    cheapestCost
            ) == 0) {

                tags.add(
                        "CHEAPEST"
                );
            }

            if (option.getTransferCount()
                    != null
                    && option.getTransferCount()
                    == fewestTransfers) {

                tags.add(
                        "FEWEST_TRANSFERS"
                );
            }

            if (Double.compare(
                    balancedScore(option),
                    bestBalancedScore
            ) == 0) {

                tags.add(
                        "BALANCED"
                );
            }

            option.setTags(
                    tags
            );
        }
    }

    /*
     * Same prototype balanced formula used by the
     * journey-planning foundation:
     *
     * duration
     * + cost * 2
     * + transfers * 10
     */
    private double balancedScore(
            JourneyOptionResponse option) {

        int duration =
                option.getTotalDurationMinutes() == null
                        ? 0
                        : option.getTotalDurationMinutes();

        double cost =
                option.getTotalCost() == null
                        ? 0.0
                        : option.getTotalCost();

        int transfers =
                option.getTransferCount() == null
                        ? 0
                        : option.getTransferCount();

        return duration
                + cost * 2.0
                + transfers * 10.0;
    }

    /*
     * Display order:
     *
     * 1. More strongly ranked/tagged journeys first.
     *
     * 2. Then lower balanced score.
     *
     * All sensible alternatives remain in the list.
     */
    private void sortJourneyOptions(
            List<JourneyOptionResponse> options,
            PlanJourneyRequest request) {

        Comparator<JourneyOptionResponse>
                priorityComparator =
                priorityComparator(
                        request.getPriority()
                );

        if (request.isPreferFewerTransfers()) {
            options.sort(
                    Comparator
                            .comparingInt(
                                    (JourneyOptionResponse option) ->
                                            option.getTransferCount() == null
                                                    ? Integer.MAX_VALUE
                                                    : option.getTransferCount()
                            )
                            .thenComparing(
                                    priorityComparator
                            )
                            .thenComparingDouble(
                                    this::balancedScore
                            )
            );

            return;
        }

        options.sort(
                priorityComparator
                        .thenComparingDouble(
                                this::balancedScore
                        )
        );
    }

    private Comparator<JourneyOptionResponse>
    priorityComparator(
            String priority) {

        String normalizedPriority =
                priority == null
                        ? "BALANCED"
                        : priority
                        .trim()
                        .toUpperCase();

        return switch (normalizedPriority) {
            case "FASTEST" ->
                    Comparator.comparingInt(
                            option ->
                                    option.getTotalDurationMinutes() == null
                                            ? Integer.MAX_VALUE
                                            : option.getTotalDurationMinutes()
                    );

            case "CHEAPEST" ->
                    Comparator.comparingDouble(
                            option ->
                                    option.getTotalCost() == null
                                            ? Double.MAX_VALUE
                                            : option.getTotalCost()
                    );

            default ->
                    Comparator.comparingDouble(
                            this::balancedScore
                    );
        };
    }

    private List<JourneyPlanningService.PlannedPath>
    applyTransportPreferences(
            List<JourneyPlanningService.PlannedPath> candidates,
            PlanJourneyRequest request) {

        if (candidates == null
                || candidates.isEmpty()) {

            return List.of();
        }

        Map<Long, Route> routesById =
                new HashMap<>();

        for (Route route
                : routeRepository.findAll()) {

            routesById.put(
                    route.getRouteId(),
                    route
            );
        }

        List<JourneyPlanningService.PlannedPath>
                filtered =
                new ArrayList<>();

        for (JourneyPlanningService.PlannedPath candidate
                : candidates) {

            if (isCandidateAllowedByTransportPreferences(
                    candidate,
                    request,
                    routesById)) {

                filtered.add(
                        candidate
                );
            }
        }

        return filtered;
    }

    private boolean isCandidateAllowedByTransportPreferences(
            JourneyPlanningService.PlannedPath candidate,
            PlanJourneyRequest request,
            Map<Long, Route> routesById) {

        for (var edge
                : candidate.getEdgePath()) {

            Long routeId =
                    edge.getRouteId();

            /*
             * Walking / transfer edges do not represent
             * a transport service choice.
             */
            if (routeId == null) {
                continue;
            }

            Route route =
                    routesById.get(
                            routeId
                    );

            if (route == null) {
                continue;
            }

            String mode =
                    route.getTransportMode() == null
                            ? ""
                            : route.getTransportMode()
                            .trim()
                            .toUpperCase();

            Long providerId =
                    route.getProviderId();

            /*
             * Prototype provider mapping:
             * 1 = Gautrain
             * 2 = A Re Yeng
             * 3 = Rea Vaya
             * 4 = Metrorail Gauteng
             * 5 = Minibus Taxi Network
             */
            if ("TRAIN".equals(mode)) {
                if (Long.valueOf(1L)
                        .equals(providerId)
                        && !request.isGautrainSelected()) {

                    return false;
                }

                if (Long.valueOf(4L)
                        .equals(providerId)
                        && !request.isMetrorailSelected()) {

                    return false;
                }
            }

            if ("BUS".equals(mode)
                    && !request.isBusSelected()) {

                return false;
            }

            if ("TAXI".equals(mode)
                    && !request.isTaxiSelected()) {

                return false;
            }
        }

        return true;
    }

    // ============================================================
    // UPDATE
    // ============================================================

    @PutMapping("/{id}")
    public ResponseEntity<Journey> updateJourney(
            @PathVariable Long id,
            @RequestBody Journey journey) {

        try {

            Journey updatedJourney =
                    journeyService
                            .updateJourney(
                                    id,
                                    journey
                            );

            return ResponseEntity.ok(
                    updatedJourney
            );

        } catch (RuntimeException exception) {

            return ResponseEntity
                    .notFound()
                    .build();
        }
    }

    // ============================================================
    // DELETE
    // ============================================================

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteJourney(
            @PathVariable Long id) {

        try {

            journeyService.deleteJourney(
                    id
            );

            return ResponseEntity
                    .noContent()
                    .build();

        } catch (RuntimeException exception) {

            return ResponseEntity
                    .notFound()
                    .build();
        }
    }
}