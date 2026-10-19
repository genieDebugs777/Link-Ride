package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.dto.JourneyLegOptionResponse;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class CandidateJourneyFilterService {

    /*
     * Final safety thresholds.
     *
     * Different journey families are NOT removed
     * merely because they are slower or more
     * expensive.
     */
    private static final double MAX_DURATION_FACTOR = 1.60;
    private static final double MAX_COST_FACTOR = 1.40;
    private static final int MAX_EXTRA_TRANSFERS = 3;

    /*
     * A transport block this short is suspicious
     * when it appears between walking legs.
     *
     * Example:
     *
     * WALK 6 min
     * -> BUS 1 min
     * -> BUS 2 min
     * -> WALK 8 min
     *
     * The BUS + BUS section is evaluated as one
     * 3-minute transport block.
     */
    private static final int MAX_SHORT_TRANSPORT_BLOCK_MINUTES = 5;

    private final JourneyLegBuilderService journeyLegBuilderService;
    private final JourneyTransferService journeyTransferService;

    public CandidateJourneyFilterService(
            JourneyLegBuilderService journeyLegBuilderService,
            JourneyTransferService journeyTransferService) {

        this.journeyLegBuilderService =
                journeyLegBuilderService;

        this.journeyTransferService =
                journeyTransferService;
    }

    /*
     * Smart commuter-facing candidate filtering.
     *
     * Pipeline:
     *
     * 1. Evaluate all feasible candidate paths.
     *
     * 2. Reject obvious local transport detours.
     *
     * 3. Group remaining candidates by major
     *    transport strategy.
     *
     * 4. Keep the strongest representative from
     *    each strategy family.
     *
     * 5. Apply only a very loose extreme-detour
     *    safety rule across different families.
     *
     * IMPORTANT:
     *
     * A legitimate alternative survives even if
     * another option is faster or cheaper.
     */
    public List<JourneyPlanningService.PlannedPath>
    filterMeaningfulCandidates(
            List<JourneyPlanningService.PlannedPath>
                    candidates) {

        if (candidates == null
                || candidates.isEmpty()) {

            return List.of();
        }

        List<CandidateMetrics> allEvaluated =
                new ArrayList<>();

        List<CandidateMetrics> sensibleEvaluated =
                new ArrayList<>();

        for (JourneyPlanningService.PlannedPath candidate
                : candidates) {

            CandidateMetrics metrics =
                    evaluateCandidate(
                            candidate
                    );

            allEvaluated.add(
                    metrics
            );

            if (!containsPointlessTransportBlock(
                    metrics.legs())) {

                sensibleEvaluated.add(
                        metrics
                );
            }
        }

        /*
         * Safety fallback.
         *
         * The smart heuristic must never accidentally
         * erase every feasible journey.
         */
        List<CandidateMetrics> evaluated =
                sensibleEvaluated.isEmpty()
                        ? allEvaluated
                        : sensibleEvaluated;

        int bestDuration =
                evaluated.stream()
                        .mapToInt(
                                CandidateMetrics
                                        ::totalDurationMinutes
                        )
                        .min()
                        .orElse(
                                Integer.MAX_VALUE
                        );

        double bestCost =
                evaluated.stream()
                        .mapToDouble(
                                CandidateMetrics
                                        ::totalCost
                        )
                        .min()
                        .orElse(
                                Double.MAX_VALUE
                        );

        int fewestTransfers =
                evaluated.stream()
                        .mapToInt(
                                CandidateMetrics
                                        ::transferCount
                        )
                        .min()
                        .orElse(
                                Integer.MAX_VALUE
                        );

        /*
         * Keep one strong representative for every
         * genuinely different transport family.
         *
         * Examples:
         *
         * TRAIN:1 -> TRAIN:8
         *
         * BUS:3 -> TRAIN:8
         *
         * TAXI:9 -> TRAIN:8
         *
         * These remain separate families even when
         * one happens to be slower or more expensive.
         */
        Map<String, CandidateMetrics>
                bestCandidateByFamily =
                new LinkedHashMap<>();

        for (CandidateMetrics candidate
                : evaluated) {

            String familySignature =
                    buildJourneyFamilySignature(
                            candidate.legs()
                    );

            CandidateMetrics existing =
                    bestCandidateByFamily.get(
                            familySignature
                    );

            if (existing == null
                    || balancedScore(candidate)
                    < balancedScore(existing)) {

                bestCandidateByFamily.put(
                        familySignature,
                        candidate
                );
            }
        }

        List<JourneyPlanningService.PlannedPath>
                meaningfulCandidates =
                new ArrayList<>();

        for (CandidateMetrics candidate
                : bestCandidateByFamily.values()) {

            if (isExtremeDetour(
                    candidate,
                    bestDuration,
                    bestCost,
                    fewestTransfers)) {

                continue;
            }

            meaningfulCandidates.add(
                    candidate.plannedPath()
            );
        }

        /*
         * Final safety fallback.
         */
        if (meaningfulCandidates.isEmpty()) {

            CandidateMetrics bestCandidate =
                    evaluated.stream()
                            .min(
                                    (first, second) ->
                                            Double.compare(
                                                    balancedScore(first),
                                                    balancedScore(second)
                                            )
                            )
                            .orElse(null);

            if (bestCandidate != null) {

                meaningfulCandidates.add(
                        bestCandidate.plannedPath()
                );
            }
        }

        return meaningfulCandidates;
    }

    /*
     * Kept for compatibility with any older debug
     * code that may still call the previous method.
     */
    public List<JourneyPlanningService.PlannedPath>
    removeDominatedCandidates(
            List<JourneyPlanningService.PlannedPath>
                    candidates) {

        return filterMeaningfulCandidates(
                candidates
        );
    }

    // ============================================================
    // CANDIDATE METRICS
    // ============================================================

    private CandidateMetrics evaluateCandidate(
            JourneyPlanningService.PlannedPath
                    plannedPath) {

        List<JourneyLegOptionResponse> legs =
                journeyLegBuilderService.buildLegs(
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
                                plannedPath.getEdgePath()
                        );

        return new CandidateMetrics(
                plannedPath,
                legs,
                totalDurationMinutes,
                totalCost,
                transferCount
        );
    }

    // ============================================================
    // JOURNEY FAMILY
    // ============================================================

    /*
     * WALK legs are intentionally excluded from the
     * major journey-family signature.
     *
     * The actual transport services define the
     * strategy.
     */
    private String buildJourneyFamilySignature(
            List<JourneyLegOptionResponse> legs) {

        List<String> serviceSequence =
                new ArrayList<>();

        for (JourneyLegOptionResponse leg : legs) {

            String mode =
                    normalizeMode(
                            leg.getTransportMode()
                    );

            if ("WALK".equals(mode)) {
                continue;
            }

            String route =
                    leg.getRouteId() == null
                            ? "NONE"
                            : String.valueOf(
                            leg.getRouteId()
                    );

            String service =
                    mode
                            + ":"
                            + route;

            if (serviceSequence.isEmpty()
                    || !serviceSequence
                    .get(
                            serviceSequence.size() - 1
                    )
                    .equals(service)) {

                serviceSequence.add(
                        service
                );
            }
        }

        if (serviceSequence.isEmpty()) {
            return "WALK_ONLY";
        }

        return String.join(
                "->",
                serviceSequence
        );
    }

    // ============================================================
    // SMART DETOUR DETECTION
    // ============================================================

    /*
     * Detects a whole sequence of paid transport
     * services placed between two WALK legs.
     *
     * Previous implementation only detected:
     *
     * WALK -> BUS -> WALK
     *
     * but missed:
     *
     * WALK -> BUS -> BUS -> WALK
     *
     * This implementation treats the consecutive
     * transport services as one block.
     */
    private boolean containsPointlessTransportBlock(
            List<JourneyLegOptionResponse> legs) {

        if (legs == null
                || legs.size() < 3) {

            return false;
        }

        for (int walkBeforeIndex = 0;
             walkBeforeIndex < legs.size() - 2;
             walkBeforeIndex++) {

            JourneyLegOptionResponse walkBefore =
                    legs.get(
                            walkBeforeIndex
                    );

            if (!isWalk(
                    walkBefore)) {

                continue;
            }

            int serviceStartIndex =
                    walkBeforeIndex + 1;

            /*
             * There must be at least one actual
             * transport service after this WALK.
             */
            if (serviceStartIndex
                    >= legs.size()
                    || isWalk(
                    legs.get(
                            serviceStartIndex
                    ))) {

                continue;
            }

            int currentIndex =
                    serviceStartIndex;

            int serviceDurationMinutes = 0;
            int serviceCount = 0;

            /*
             * Collect every consecutive non-WALK leg.
             */
            while (currentIndex < legs.size()
                    && !isWalk(
                    legs.get(
                            currentIndex
                    ))) {

                JourneyLegOptionResponse serviceLeg =
                        legs.get(
                                currentIndex
                        );

                serviceDurationMinutes +=
                        safeDuration(
                                serviceLeg
                        );

                serviceCount++;

                currentIndex++;
            }

            /*
             * The transport block must end with WALK
             * for this particular detour pattern.
             */
            if (currentIndex
                    >= legs.size()) {

                continue;
            }

            JourneyLegOptionResponse walkAfter =
                    legs.get(
                            currentIndex
                    );

            if (!isWalk(
                    walkAfter)) {

                continue;
            }

            int surroundingWalkDuration =
                    safeDuration(
                            walkBefore
                    )
                            + safeDuration(
                            walkAfter
                    );

            boolean shortTransportBlock =
                    serviceDurationMinutes
                            <= MAX_SHORT_TRANSPORT_BLOCK_MINUTES;

            /*
             * Multiple paid service changes inside a
             * tiny local movement are particularly
             * suspicious.
             */
            boolean multipleShortServices =
                    serviceCount > 1
                            && shortTransportBlock;

            /*
             * Also detect a single tiny service when
             * the commuter spends substantially more
             * time walking around it than travelling
             * on it.
             *
             * Example:
             *
             * WALK 3
             * -> BUS 1
             * -> WALK 6
             */
            boolean walkingDominatesService =
                    shortTransportBlock
                            && surroundingWalkDuration
                            >= serviceDurationMinutes * 2;

            if (multipleShortServices
                    || walkingDominatesService) {

                return true;
            }

            /*
             * Continue searching after this block.
             */
            walkBeforeIndex =
                    currentIndex - 1;
        }

        return false;
    }

    private boolean isWalk(
            JourneyLegOptionResponse leg) {

        return "WALK".equals(
                normalizeMode(
                        leg.getTransportMode()
                )
        );
    }

    private int safeDuration(
            JourneyLegOptionResponse leg) {

        if (leg == null
                || leg.getDurationMinutes() == null) {

            return 0;
        }

        return leg.getDurationMinutes();
    }

    // ============================================================
    // FINAL EXTREME-DETOUR SAFETY RULE
    // ============================================================

    /*
     * This does NOT remove ordinary slower or more
     * expensive alternatives.
     *
     * A family must be dramatically worse across
     * duration, cost AND transfers simultaneously.
     */
    private boolean isExtremeDetour(
            CandidateMetrics candidate,
            int bestDuration,
            double bestCost,
            int fewestTransfers) {

        boolean dramaticallySlower =
                candidate.totalDurationMinutes()
                        > bestDuration
                        * MAX_DURATION_FACTOR;

        boolean dramaticallyMoreExpensive =
                candidate.totalCost()
                        > bestCost
                        * MAX_COST_FACTOR;

        boolean manyExtraTransfers =
                candidate.transferCount()
                        >= fewestTransfers
                        + MAX_EXTRA_TRANSFERS;

        return dramaticallySlower
                && dramaticallyMoreExpensive
                && manyExtraTransfers;
    }

    // ============================================================
    // SAME-FAMILY REPRESENTATIVE SCORE
    // ============================================================

    /*
     * Only used to choose between multiple versions
     * of the SAME journey family.
     *
     * Different families are not eliminated simply
     * because they have a worse balanced score.
     */
    private double balancedScore(
            CandidateMetrics candidate) {

        return candidate.totalDurationMinutes()
                + candidate.totalCost() * 2.0
                + candidate.transferCount() * 10.0;
    }

    private String normalizeMode(
            String transportMode) {

        if (transportMode == null) {
            return "UNKNOWN";
        }

        return transportMode
                .trim()
                .toUpperCase();
    }

    private record CandidateMetrics(
            JourneyPlanningService.PlannedPath
            plannedPath,
            List<JourneyLegOptionResponse> legs,
            int totalDurationMinutes,
            double totalCost,
            int transferCount) {
    }
}