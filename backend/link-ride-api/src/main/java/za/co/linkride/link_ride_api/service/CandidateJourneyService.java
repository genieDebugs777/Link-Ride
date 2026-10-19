package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.repository.StopRepository;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Queue;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class CandidateJourneyService {

    /*
     * We no longer stop after finding the first
     * arbitrary 10 destination-reaching paths.
     *
     * Instead, the planner explores the graph broadly
     * and retains a small number of representatives
     * from each distinct journey family.
     */
    private static final int MAX_CANDIDATES_PER_FAMILY = 3;

    private static final int MAX_TRANSFERS = 4;

    private static final int MAX_EDGES_PER_PATH = 30;

    /*
     * Safety valve for prototype graph exploration.
     *
     * This is intentionally larger than the previous
     * limit because we now want to discover diverse
     * journey families rather than stopping as soon
     * as a handful of destination paths are found.
     */
    private static final int MAX_SEARCH_STATES = 15000;

    private final TransportGraphService transportGraphService;
    private final NearestStopService nearestStopService;
    private final StopRepository stopRepository;
    private final JourneyTransferService journeyTransferService;

    public CandidateJourneyService(
            TransportGraphService transportGraphService,
            NearestStopService nearestStopService,
            StopRepository stopRepository,
            JourneyTransferService journeyTransferService) {

        this.transportGraphService =
                transportGraphService;

        this.nearestStopService =
                nearestStopService;

        this.stopRepository =
                stopRepository;

        this.journeyTransferService =
                journeyTransferService;
    }

    public List<JourneyPlanningService.PlannedPath>
    generateCandidates(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        if (originLatitude == null
                || originLongitude == null
                || destinationStopId == null) {

            return List.of();
        }

        Optional<Stop> destinationStopOptional =
                stopRepository.findById(
                        destinationStopId
                );

        if (destinationStopOptional.isEmpty()) {
            return List.of();
        }

        Optional<NearestStopService.NearestStopResult>
                nearestOriginOptional =
                nearestStopService.findNearestStop(
                        originLatitude,
                        originLongitude
                );

        if (nearestOriginOptional.isEmpty()) {
            return List.of();
        }

        Stop originStop =
                nearestOriginOptional
                        .get()
                        .getStop();

        Stop destinationStop =
                destinationStopOptional.get();

        double originDistanceKm =
                nearestOriginOptional
                        .get()
                        .getDistanceKm();

        Long originStopId =
                originStop.getStopId();

        Long targetStopId =
                destinationStop.getStopId();

        /*
         * Origin and destination resolve to the same
         * controlled network stop.
         */
        if (originStopId.equals(
                targetStopId)) {

            return List.of(
                    new JourneyPlanningService.PlannedPath(
                            originStop,
                            destinationStop,
                            originDistanceKm,
                            List.of(originStopId),
                            List.of()
                    )
            );
        }

        Map<Long, List<TransportGraphService.GraphEdge>>
                graph =
                transportGraphService.buildGraph();

        Queue<PathState> queue =
                new ArrayDeque<>();

        queue.add(
                new PathState(
                        List.of(originStopId),
                        List.of()
                )
        );

        List<JourneyPlanningService.PlannedPath>
                candidates =
                new ArrayList<>();

        /*
         * Prevent exactly equivalent commuter
         * itineraries from being added twice.
         */
        Set<String> itinerarySignatures =
                new HashSet<>();

        /*
         * Tracks how many representatives we have
         * retained from each major transport family.
         *
         * Examples:
         *
         * TRAIN:1->TRAIN:8
         *
         * BUS:3->TRAIN:8
         *
         * TAXI:9->TRAIN:8
         */
        Map<String, Integer> familyCandidateCounts =
                new HashMap<>();

        int exploredStates = 0;

        /*
         * IMPORTANT:
         *
         * We deliberately DO NOT stop based on the
         * number of candidates found.
         *
         * The old implementation stopped after the
         * first 10 paths, which biased discovery
         * toward whatever BFS encountered first.
         *
         * Now the search continues until the graph
         * exploration safety limit is reached.
         */
        while (!queue.isEmpty()
                && exploredStates < MAX_SEARCH_STATES) {

            PathState current =
                    queue.poll();

            exploredStates++;

            List<Long> currentStopPath =
                    current.stopPath();

            List<TransportGraphService.GraphEdge>
                    currentEdgePath =
                    current.edgePath();

            Long currentStopId =
                    currentStopPath.get(
                            currentStopPath.size() - 1
                    );

            /*
             * Complete journey discovered.
             */
            if (currentStopId.equals(
                    targetStopId)) {

                String itinerarySignature =
                        buildJourneySignature(
                                currentStopPath,
                                currentEdgePath
                        );

                /*
                 * Same commuter itinerary already
                 * discovered.
                 */
                if (!itinerarySignatures.add(
                        itinerarySignature)) {

                    continue;
                }

                String familySignature =
                        buildJourneyFamilySignature(
                                currentEdgePath
                        );

                int currentFamilyCount =
                        familyCandidateCounts
                                .getOrDefault(
                                        familySignature,
                                        0
                                );

                /*
                 * Keep several representatives from
                 * each family so the smart filter can
                 * later choose the sensible version.
                 *
                 * This prevents one transport family
                 * from monopolising candidate discovery.
                 */
                if (currentFamilyCount
                        >= MAX_CANDIDATES_PER_FAMILY) {

                    continue;
                }

                candidates.add(
                        new JourneyPlanningService.PlannedPath(
                                originStop,
                                destinationStop,
                                originDistanceKm,
                                currentStopPath,
                                currentEdgePath
                        )
                );

                familyCandidateCounts.put(
                        familySignature,
                        currentFamilyCount + 1
                );

                continue;
            }

            /*
             * Prevent excessively long graph paths.
             */
            if (currentEdgePath.size()
                    >= MAX_EDGES_PER_PATH) {

                continue;
            }

            List<TransportGraphService.GraphEdge>
                    outgoingEdges =
                    graph.getOrDefault(
                            currentStopId,
                            List.of()
                    );

            for (TransportGraphService.GraphEdge edge
                    : outgoingEdges) {

                Long nextStopId =
                        edge.getDestinationStopId();

                /*
                 * Simple-path rule.
                 *
                 * Once a stop has already been used in
                 * this journey, do not visit it again.
                 *
                 * This prevents loops and immediate
                 * reversal behaviour.
                 */
                if (currentStopPath.contains(
                        nextStopId)) {

                    continue;
                }

                List<Long> nextStopPath =
                        new ArrayList<>(
                                currentStopPath
                        );

                nextStopPath.add(
                        nextStopId
                );

                List<TransportGraphService.GraphEdge>
                        nextEdgePath =
                        new ArrayList<>(
                                currentEdgePath
                        );

                nextEdgePath.add(
                        edge
                );

                int transferCount =
                        journeyTransferService
                                .countTransfers(
                                        nextEdgePath
                                );

                /*
                 * Reject journeys requiring too many
                 * service changes for the prototype.
                 */
                if (transferCount
                        > MAX_TRANSFERS) {

                    continue;
                }

                queue.add(
                        new PathState(
                                List.copyOf(
                                        nextStopPath
                                ),
                                List.copyOf(
                                        nextEdgePath
                                )
                        )
                );
            }
        }

        return candidates;
    }

    /*
     * Journey-family signature.
     *
     * This represents the commuter's MAJOR transport
     * strategy rather than the exact stop-by-stop
     * graph path.
     *
     * WALK edges are ignored because they normally
     * provide access or interchange between services.
     *
     * Examples:
     *
     * TRAIN:1 -> TRAIN:8
     *
     * BUS:3 -> TRAIN:8
     *
     * TAXI:9 -> TRAIN:8
     *
     * TRAIN:1 -> BUS:2 -> TRAIN:8
     */
    private String buildJourneyFamilySignature(
            List<TransportGraphService.GraphEdge>
                    edgePath) {

        List<String> serviceSequence =
                new ArrayList<>();

        for (TransportGraphService.GraphEdge edge
                : edgePath) {

            /*
             * Transfer / walking edges do not define
             * the major journey family.
             */
            if (edge.getRouteId() == null) {
                continue;
            }

            String mode =
                    normalizeMode(
                            edge.getTransportMode()
                    );

            String service =
                    mode
                            + ":"
                            + edge.getRouteId();

            /*
             * Consecutive graph edges on the same
             * service count as one journey segment.
             */
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

    /*
     * Exact commuter-itinerary signature.
     *
     * This is still useful for preventing exact
     * duplicates inside the same journey family.
     *
     * Consecutive edges belonging to the same
     * service or WALK transfer are collapsed into
     * logical commuter-facing segments.
     */
    private String buildJourneySignature(
            List<Long> stopPath,
            List<TransportGraphService.GraphEdge>
                    edgePath) {

        if (edgePath.isEmpty()) {

            return stopPath.stream()
                    .map(String::valueOf)
                    .collect(
                            Collectors.joining(
                                    ">"
                            )
                    );
        }

        List<String> segments =
                new ArrayList<>();

        int edgeIndex = 0;

        while (edgeIndex < edgePath.size()) {

            TransportGraphService.GraphEdge firstEdge =
                    edgePath.get(
                            edgeIndex
                    );

            Long routeId =
                    firstEdge.getRouteId();

            String mode =
                    normalizeMode(
                            firstEdge.getTransportMode()
                    );

            boolean transfer =
                    firstEdge.isTransfer();

            int segmentStartEdgeIndex =
                    edgeIndex;

            int segmentEndEdgeIndex =
                    edgeIndex;

            while (segmentEndEdgeIndex + 1
                    < edgePath.size()) {

                TransportGraphService.GraphEdge nextEdge =
                        edgePath.get(
                                segmentEndEdgeIndex + 1
                        );

                if (!belongsToSameSegment(
                        routeId,
                        mode,
                        transfer,
                        nextEdge)) {

                    break;
                }

                segmentEndEdgeIndex++;
            }

            Long segmentStartStopId =
                    stopPath.get(
                            segmentStartEdgeIndex
                    );

            Long segmentEndStopId =
                    stopPath.get(
                            segmentEndEdgeIndex + 1
                    );

            String routePart =
                    routeId == null
                            ? "NONE"
                            : String.valueOf(
                            routeId
                    );

            String transferPart =
                    transfer
                            ? "TRANSFER"
                            : "SERVICE";

            segments.add(
                    mode
                            + ":"
                            + routePart
                            + ":"
                            + transferPart
                            + ":"
                            + segmentStartStopId
                            + ">"
                            + segmentEndStopId
            );

            edgeIndex =
                    segmentEndEdgeIndex + 1;
        }

        return String.join(
                "|",
                segments
        );
    }

    private boolean belongsToSameSegment(
            Long routeId,
            String mode,
            boolean transfer,
            TransportGraphService.GraphEdge nextEdge) {

        String nextMode =
                normalizeMode(
                        nextEdge.getTransportMode()
                );

        if (routeId != null) {

            return routeId.equals(
                    nextEdge.getRouteId()
            );
        }

        return nextEdge.getRouteId() == null
                && transfer
                == nextEdge.isTransfer()
                && mode.equals(
                nextMode
        );
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

    private record PathState(
            List<Long> stopPath,
            List<TransportGraphService.GraphEdge>
            edgePath) {
    }
}