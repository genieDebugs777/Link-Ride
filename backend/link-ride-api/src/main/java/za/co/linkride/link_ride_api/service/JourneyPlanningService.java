package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.repository.StopRepository;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.Set;

@Service
public class JourneyPlanningService {

    private static final double BALANCED_COST_WEIGHT = 2.0;
    private static final double BALANCED_TRANSFER_PENALTY = 10.0;

    private final TransportGraphService transportGraphService;
    private final NearestStopService nearestStopService;
    private final StopRepository stopRepository;
    private final JourneyEstimationService journeyEstimationService;

    public JourneyPlanningService(
            TransportGraphService transportGraphService,
            NearestStopService nearestStopService,
            StopRepository stopRepository,
            JourneyEstimationService journeyEstimationService) {

        this.transportGraphService =
                transportGraphService;

        this.nearestStopService =
                nearestStopService;

        this.stopRepository =
                stopRepository;

        this.journeyEstimationService =
                journeyEstimationService;
    }

    /*
     * Existing unweighted search.
     */
    public Optional<PlannedPath> findPath(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        Optional<SearchContext> contextOptional =
                prepareSearchContext(
                        originLatitude,
                        originLongitude,
                        destinationStopId
                );

        if (contextOptional.isEmpty()) {
            return Optional.empty();
        }

        SearchContext context =
                contextOptional.get();

        if (context.startStopId()
                .equals(context.targetStopId())) {

            return Optional.of(
                    createZeroEdgePath(context)
            );
        }

        Queue<Long> queue =
                new ArrayDeque<>();

        Set<Long> visited =
                new HashSet<>();

        Map<Long, Long> previousStop =
                new HashMap<>();

        Map<Long, TransportGraphService.GraphEdge>
                previousEdge =
                new HashMap<>();

        queue.add(
                context.startStopId()
        );

        visited.add(
                context.startStopId()
        );

        boolean found = false;

        while (!queue.isEmpty()) {

            Long currentStopId =
                    queue.poll();

            List<TransportGraphService.GraphEdge>
                    edges =
                    context.graph()
                            .getOrDefault(
                                    currentStopId,
                                    List.of()
                            );

            for (TransportGraphService.GraphEdge edge
                    : edges) {

                Long nextStopId =
                        edge.getDestinationStopId();

                if (visited.contains(
                        nextStopId)) {

                    continue;
                }

                visited.add(
                        nextStopId
                );

                previousStop.put(
                        nextStopId,
                        currentStopId
                );

                previousEdge.put(
                        nextStopId,
                        edge
                );

                if (nextStopId.equals(
                        context.targetStopId())) {

                    found = true;
                    queue.clear();
                    break;
                }

                queue.add(
                        nextStopId
                );
            }
        }

        if (!found) {
            return Optional.empty();
        }

        return reconstructPath(
                context,
                previousStop,
                previousEdge
        );
    }

    /*
     * FASTEST
     *
     * Dijkstra using estimated travel minutes.
     */
    public Optional<PlannedPath> findFastestPath(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        Optional<SearchContext> contextOptional =
                prepareSearchContext(
                        originLatitude,
                        originLongitude,
                        destinationStopId
                );

        if (contextOptional.isEmpty()) {
            return Optional.empty();
        }

        SearchContext context =
                contextOptional.get();

        if (context.startStopId()
                .equals(context.targetStopId())) {

            return Optional.of(
                    createZeroEdgePath(context)
            );
        }

        Map<Long, Stop> stopsById =
                buildStopsById();

        Map<Long, Double> bestDuration =
                new HashMap<>();

        Map<Long, Long> previousStop =
                new HashMap<>();

        Map<Long, TransportGraphService.GraphEdge>
                previousEdge =
                new HashMap<>();

        PriorityQueue<NodeScore> queue =
                new PriorityQueue<>(
                        Comparator.comparingDouble(
                                NodeScore::score
                        )
                );

        bestDuration.put(
                context.startStopId(),
                0.0
        );

        queue.add(
                new NodeScore(
                        context.startStopId(),
                        0.0
                )
        );

        while (!queue.isEmpty()) {

            NodeScore current =
                    queue.poll();

            double knownBest =
                    bestDuration.getOrDefault(
                            current.stopId(),
                            Double.POSITIVE_INFINITY
                    );

            if (current.score() > knownBest) {
                continue;
            }

            if (current.stopId()
                    .equals(
                            context.targetStopId()
                    )) {

                break;
            }

            Stop currentStop =
                    stopsById.get(
                            current.stopId()
                    );

            if (!hasCoordinates(
                    currentStop)) {

                continue;
            }

            List<TransportGraphService.GraphEdge>
                    edges =
                    context.graph()
                            .getOrDefault(
                                    current.stopId(),
                                    List.of()
                            );

            for (TransportGraphService.GraphEdge edge
                    : edges) {

                Long nextStopId =
                        edge.getDestinationStopId();

                Stop nextStop =
                        stopsById.get(
                                nextStopId
                        );

                if (!hasCoordinates(
                        nextStop)) {

                    continue;
                }

                int edgeDuration =
                        journeyEstimationService
                                .estimateDurationMinutes(
                                        currentStop.getLatitude(),
                                        currentStop.getLongitude(),
                                        nextStop.getLatitude(),
                                        nextStop.getLongitude(),
                                        edge.getTransportMode()
                                );

                double candidateDuration =
                        current.score()
                                + edgeDuration;

                double existingDuration =
                        bestDuration.getOrDefault(
                                nextStopId,
                                Double.POSITIVE_INFINITY
                        );

                if (candidateDuration
                        < existingDuration) {

                    bestDuration.put(
                            nextStopId,
                            candidateDuration
                    );

                    previousStop.put(
                            nextStopId,
                            current.stopId()
                    );

                    previousEdge.put(
                            nextStopId,
                            edge
                    );

                    queue.add(
                            new NodeScore(
                                    nextStopId,
                                    candidateDuration
                            )
                    );
                }
            }
        }

        if (!bestDuration.containsKey(
                context.targetStopId())) {

            return Optional.empty();
        }

        return reconstructPath(
                context,
                previousStop,
                previousEdge
        );
    }

    /*
     * CHEAPEST
     *
     * State:
     *
     * (stopId, currentRouteId)
     */
    public Optional<PlannedPath> findCheapestPath(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        Optional<SearchContext> contextOptional =
                prepareSearchContext(
                        originLatitude,
                        originLongitude,
                        destinationStopId
                );

        if (contextOptional.isEmpty()) {
            return Optional.empty();
        }

        SearchContext context =
                contextOptional.get();

        if (context.startStopId()
                .equals(context.targetStopId())) {

            return Optional.of(
                    createZeroEdgePath(context)
            );
        }

        Map<Long, Stop> stopsById =
                buildStopsById();

        SearchState startState =
                new SearchState(
                        context.startStopId(),
                        null
                );

        Map<SearchState, Double> bestCost =
                new HashMap<>();

        Map<SearchState, SearchState>
                previousState =
                new HashMap<>();

        Map<SearchState, TransportGraphService.GraphEdge>
                previousEdge =
                new HashMap<>();

        PriorityQueue<StateScore> queue =
                new PriorityQueue<>(
                        Comparator.comparingDouble(
                                StateScore::score
                        )
                );

        bestCost.put(
                startState,
                0.0
        );

        queue.add(
                new StateScore(
                        startState,
                        0.0
                )
        );

        SearchState targetState =
                null;

        while (!queue.isEmpty()) {

            StateScore current =
                    queue.poll();

            double knownBest =
                    bestCost.getOrDefault(
                            current.state(),
                            Double.POSITIVE_INFINITY
                    );

            if (current.score() > knownBest) {
                continue;
            }

            if (current.state()
                    .stopId()
                    .equals(
                            context.targetStopId()
                    )) {

                targetState =
                        current.state();

                break;
            }

            Stop currentStop =
                    stopsById.get(
                            current.state()
                                    .stopId()
                    );

            if (!hasCoordinates(
                    currentStop)) {

                continue;
            }

            List<TransportGraphService.GraphEdge>
                    edges =
                    context.graph()
                            .getOrDefault(
                                    current.state()
                                            .stopId(),
                                    List.of()
                            );

            for (TransportGraphService.GraphEdge edge
                    : edges) {

                Long nextStopId =
                        edge.getDestinationStopId();

                Stop nextStop =
                        stopsById.get(
                                nextStopId
                        );

                if (!hasCoordinates(
                        nextStop)) {

                    continue;
                }

                Long nextRouteId =
                        edge.getRouteId();

                boolean chargeBaseFare =
                        nextRouteId != null
                                && !nextRouteId.equals(
                                current.state()
                                        .routeId()
                        );

                double edgeCost =
                        journeyEstimationService
                                .estimateEdgeCost(
                                        currentStop.getLatitude(),
                                        currentStop.getLongitude(),
                                        nextStop.getLatitude(),
                                        nextStop.getLongitude(),
                                        edge.getTransportMode(),
                                        chargeBaseFare
                                );

                SearchState nextState =
                        new SearchState(
                                nextStopId,
                                nextRouteId
                        );

                double candidateCost =
                        current.score()
                                + edgeCost;

                double existingCost =
                        bestCost.getOrDefault(
                                nextState,
                                Double.POSITIVE_INFINITY
                        );

                if (candidateCost
                        < existingCost) {

                    bestCost.put(
                            nextState,
                            candidateCost
                    );

                    previousState.put(
                            nextState,
                            current.state()
                    );

                    previousEdge.put(
                            nextState,
                            edge
                    );

                    queue.add(
                            new StateScore(
                                    nextState,
                                    candidateCost
                            )
                    );
                }
            }
        }

        if (targetState == null) {
            return Optional.empty();
        }

        return reconstructStatePath(
                context,
                startState,
                targetState,
                previousState,
                previousEdge
        );
    }

    /*
     * FEWEST_TRANSFERS
     *
     * Primary:
     * lowest transfer count.
     *
     * Secondary:
     * lowest duration.
     */
    public Optional<PlannedPath> findFewestTransfersPath(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        Optional<SearchContext> contextOptional =
                prepareSearchContext(
                        originLatitude,
                        originLongitude,
                        destinationStopId
                );

        if (contextOptional.isEmpty()) {
            return Optional.empty();
        }

        SearchContext context =
                contextOptional.get();

        if (context.startStopId()
                .equals(context.targetStopId())) {

            return Optional.of(
                    createZeroEdgePath(context)
            );
        }

        Map<Long, Stop> stopsById =
                buildStopsById();

        SearchState startState =
                new SearchState(
                        context.startStopId(),
                        null
                );

        TransferScore startScore =
                new TransferScore(
                        0,
                        0
                );

        Map<SearchState, TransferScore>
                bestScore =
                new HashMap<>();

        Map<SearchState, SearchState>
                previousState =
                new HashMap<>();

        Map<SearchState, TransportGraphService.GraphEdge>
                previousEdge =
                new HashMap<>();

        PriorityQueue<TransferQueueItem> queue =
                new PriorityQueue<>(
                        Comparator
                                .comparingInt(
                                        (TransferQueueItem item) ->
                                                item.score()
                                                        .transferCount()
                                )
                                .thenComparingInt(
                                        item ->
                                                item.score()
                                                        .durationMinutes()
                                )
                );

        bestScore.put(
                startState,
                startScore
        );

        queue.add(
                new TransferQueueItem(
                        startState,
                        startScore
                )
        );

        SearchState targetState =
                null;

        while (!queue.isEmpty()) {

            TransferQueueItem current =
                    queue.poll();

            TransferScore knownBest =
                    bestScore.get(
                            current.state()
                    );

            if (knownBest == null
                    || compareScores(
                    current.score(),
                    knownBest
            ) > 0) {

                continue;
            }

            if (current.state()
                    .stopId()
                    .equals(
                            context.targetStopId()
                    )) {

                targetState =
                        current.state();

                break;
            }

            Stop currentStop =
                    stopsById.get(
                            current.state()
                                    .stopId()
                    );

            if (!hasCoordinates(
                    currentStop)) {

                continue;
            }

            List<TransportGraphService.GraphEdge>
                    edges =
                    context.graph()
                            .getOrDefault(
                                    current.state()
                                            .stopId(),
                                    List.of()
                            );

            for (TransportGraphService.GraphEdge edge
                    : edges) {

                Long nextStopId =
                        edge.getDestinationStopId();

                Stop nextStop =
                        stopsById.get(
                                nextStopId
                        );

                if (!hasCoordinates(
                        nextStop)) {

                    continue;
                }

                Long currentRouteId =
                        current.state()
                                .routeId();

                Long nextRouteId =
                        edge.getRouteId();

                int transferIncrement =
                        calculateTransferIncrement(
                                currentRouteId,
                                edge
                        );

                int edgeDuration =
                        journeyEstimationService
                                .estimateDurationMinutes(
                                        currentStop.getLatitude(),
                                        currentStop.getLongitude(),
                                        nextStop.getLatitude(),
                                        nextStop.getLongitude(),
                                        edge.getTransportMode()
                                );

                TransferScore candidateScore =
                        new TransferScore(
                                current.score()
                                        .transferCount()
                                        + transferIncrement,

                                current.score()
                                        .durationMinutes()
                                        + edgeDuration
                        );

                Long nextActiveRouteId =
                        edge.isTransfer()
                                ? null
                                : nextRouteId;

                SearchState nextState =
                        new SearchState(
                                nextStopId,
                                nextActiveRouteId
                        );

                TransferScore existingScore =
                        bestScore.get(
                                nextState
                        );

                if (existingScore == null
                        || compareScores(
                        candidateScore,
                        existingScore
                ) < 0) {

                    bestScore.put(
                            nextState,
                            candidateScore
                    );

                    previousState.put(
                            nextState,
                            current.state()
                    );

                    previousEdge.put(
                            nextState,
                            edge
                    );

                    queue.add(
                            new TransferQueueItem(
                                    nextState,
                                    candidateScore
                            )
                    );
                }
            }
        }

        if (targetState == null) {
            return Optional.empty();
        }

        return reconstructStatePath(
                context,
                startState,
                targetState,
                previousState,
                previousEdge
        );
    }

    /*
     * BALANCED
     *
     * Prototype score:
     *
     * duration
     * + cost x 2
     * + transfers x 10
     *
     * Lower is better.
     */
    public Optional<PlannedPath> findBalancedPath(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        Optional<SearchContext> contextOptional =
                prepareSearchContext(
                        originLatitude,
                        originLongitude,
                        destinationStopId
                );

        if (contextOptional.isEmpty()) {
            return Optional.empty();
        }

        SearchContext context =
                contextOptional.get();

        if (context.startStopId()
                .equals(context.targetStopId())) {

            return Optional.of(
                    createZeroEdgePath(context)
            );
        }

        Map<Long, Stop> stopsById =
                buildStopsById();

        SearchState startState =
                new SearchState(
                        context.startStopId(),
                        null
                );

        Map<SearchState, Double> bestBalancedScore =
                new HashMap<>();

        Map<SearchState, SearchState>
                previousState =
                new HashMap<>();

        Map<SearchState, TransportGraphService.GraphEdge>
                previousEdge =
                new HashMap<>();

        PriorityQueue<StateScore> queue =
                new PriorityQueue<>(
                        Comparator.comparingDouble(
                                StateScore::score
                        )
                );

        bestBalancedScore.put(
                startState,
                0.0
        );

        queue.add(
                new StateScore(
                        startState,
                        0.0
                )
        );

        SearchState targetState =
                null;

        while (!queue.isEmpty()) {

            StateScore current =
                    queue.poll();

            double knownBest =
                    bestBalancedScore.getOrDefault(
                            current.state(),
                            Double.POSITIVE_INFINITY
                    );

            if (current.score() > knownBest) {
                continue;
            }

            if (current.state()
                    .stopId()
                    .equals(
                            context.targetStopId()
                    )) {

                targetState =
                        current.state();

                break;
            }

            Stop currentStop =
                    stopsById.get(
                            current.state()
                                    .stopId()
                    );

            if (!hasCoordinates(
                    currentStop)) {

                continue;
            }

            List<TransportGraphService.GraphEdge>
                    edges =
                    context.graph()
                            .getOrDefault(
                                    current.state()
                                            .stopId(),
                                    List.of()
                            );

            for (TransportGraphService.GraphEdge edge
                    : edges) {

                Long nextStopId =
                        edge.getDestinationStopId();

                Stop nextStop =
                        stopsById.get(
                                nextStopId
                        );

                if (!hasCoordinates(
                        nextStop)) {

                    continue;
                }

                Long currentRouteId =
                        current.state()
                                .routeId();

                Long nextRouteId =
                        edge.getRouteId();

                int edgeDuration =
                        journeyEstimationService
                                .estimateDurationMinutes(
                                        currentStop.getLatitude(),
                                        currentStop.getLongitude(),
                                        nextStop.getLatitude(),
                                        nextStop.getLongitude(),
                                        edge.getTransportMode()
                                );

                boolean chargeBaseFare =
                        nextRouteId != null
                                && !nextRouteId.equals(
                                currentRouteId
                        );

                double edgeCost =
                        journeyEstimationService
                                .estimateEdgeCost(
                                        currentStop.getLatitude(),
                                        currentStop.getLongitude(),
                                        nextStop.getLatitude(),
                                        nextStop.getLongitude(),
                                        edge.getTransportMode(),
                                        chargeBaseFare
                                );

                int transferIncrement =
                        calculateTransferIncrement(
                                currentRouteId,
                                edge
                        );

                double edgeBalancedScore =
                        edgeDuration
                                + (
                                edgeCost
                                        * BALANCED_COST_WEIGHT
                        )
                                + (
                                transferIncrement
                                        * BALANCED_TRANSFER_PENALTY
                        );

                double candidateScore =
                        current.score()
                                + edgeBalancedScore;

                Long nextActiveRouteId =
                        edge.isTransfer()
                                ? null
                                : nextRouteId;

                SearchState nextState =
                        new SearchState(
                                nextStopId,
                                nextActiveRouteId
                        );

                double existingScore =
                        bestBalancedScore.getOrDefault(
                                nextState,
                                Double.POSITIVE_INFINITY
                        );

                if (candidateScore
                        < existingScore) {

                    bestBalancedScore.put(
                            nextState,
                            candidateScore
                    );

                    previousState.put(
                            nextState,
                            current.state()
                    );

                    previousEdge.put(
                            nextState,
                            edge
                    );

                    queue.add(
                            new StateScore(
                                    nextState,
                                    candidateScore
                            )
                    );
                }
            }
        }

        if (targetState == null) {
            return Optional.empty();
        }

        return reconstructStatePath(
                context,
                startState,
                targetState,
                previousState,
                previousEdge
        );
    }

    /*
     * Transfer logic shared by FEWEST_TRANSFERS
     * and BALANCED.
     *
     * This matches JourneyTransferService.
     */
    private int calculateTransferIncrement(
            Long currentRouteId,
            TransportGraphService.GraphEdge edge) {

        if (edge.isTransfer()) {
            return 1;
        }

        Long nextRouteId =
                edge.getRouteId();

        if (currentRouteId == null
                || nextRouteId == null) {

            return 0;
        }

        if (!currentRouteId.equals(
                nextRouteId)) {

            return 1;
        }

        return 0;
    }

    private int compareScores(
            TransferScore first,
            TransferScore second) {

        int transferComparison =
                Integer.compare(
                        first.transferCount(),
                        second.transferCount()
                );

        if (transferComparison != 0) {
            return transferComparison;
        }

        return Integer.compare(
                first.durationMinutes(),
                second.durationMinutes()
        );
    }

    private Map<Long, Stop> buildStopsById() {

        Map<Long, Stop> stopsById =
                new HashMap<>();

        for (Stop stop : stopRepository.findAll()) {

            stopsById.put(
                    stop.getStopId(),
                    stop
            );
        }

        return stopsById;
    }

    private Optional<SearchContext> prepareSearchContext(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        if (originLatitude == null
                || originLongitude == null
                || destinationStopId == null) {

            return Optional.empty();
        }

        Optional<Stop> destinationStop =
                stopRepository.findById(
                        destinationStopId
                );

        if (destinationStop.isEmpty()) {
            return Optional.empty();
        }

        Optional<NearestStopService.NearestStopResult>
                nearestOriginResult =
                nearestStopService.findNearestStop(
                        originLatitude,
                        originLongitude
                );

        if (nearestOriginResult.isEmpty()) {
            return Optional.empty();
        }

        Stop originStop =
                nearestOriginResult
                        .get()
                        .getStop();

        Map<Long, List<TransportGraphService.GraphEdge>>
                graph =
                transportGraphService.buildGraph();

        return Optional.of(
                new SearchContext(
                        originStop,
                        destinationStop.get(),
                        nearestOriginResult
                                .get()
                                .getDistanceKm(),
                        originStop.getStopId(),
                        destinationStopId,
                        graph
                )
        );
    }

    private PlannedPath createZeroEdgePath(
            SearchContext context) {

        return new PlannedPath(
                context.originStop(),
                context.destinationStop(),
                context.originDistanceKm(),
                List.of(
                        context.startStopId()
                ),
                List.of()
        );
    }

    private Optional<PlannedPath> reconstructPath(
            SearchContext context,
            Map<Long, Long> previousStop,
            Map<Long, TransportGraphService.GraphEdge>
                    previousEdge) {

        List<Long> stopPath =
                new ArrayList<>();

        List<TransportGraphService.GraphEdge>
                edgePath =
                new ArrayList<>();

        Long current =
                context.targetStopId();

        stopPath.add(
                current
        );

        while (!current.equals(
                context.startStopId())) {

            TransportGraphService.GraphEdge edge =
                    previousEdge.get(
                            current
                    );

            Long previous =
                    previousStop.get(
                            current
                    );

            if (edge == null
                    || previous == null) {

                return Optional.empty();
            }

            edgePath.add(
                    edge
            );

            current =
                    previous;

            stopPath.add(
                    current
            );
        }

        Collections.reverse(
                stopPath
        );

        Collections.reverse(
                edgePath
        );

        return Optional.of(
                new PlannedPath(
                        context.originStop(),
                        context.destinationStop(),
                        context.originDistanceKm(),
                        stopPath,
                        edgePath
                )
        );
    }

    private Optional<PlannedPath> reconstructStatePath(
            SearchContext context,
            SearchState startState,
            SearchState targetState,
            Map<SearchState, SearchState> previousState,
            Map<SearchState, TransportGraphService.GraphEdge>
                    previousEdge) {

        List<Long> stopPath =
                new ArrayList<>();

        List<TransportGraphService.GraphEdge>
                edgePath =
                new ArrayList<>();

        SearchState current =
                targetState;

        stopPath.add(
                current.stopId()
        );

        while (!current.equals(
                startState)) {

            TransportGraphService.GraphEdge edge =
                    previousEdge.get(
                            current
                    );

            SearchState previous =
                    previousState.get(
                            current
                    );

            if (edge == null
                    || previous == null) {

                return Optional.empty();
            }

            edgePath.add(
                    edge
            );

            current =
                    previous;

            stopPath.add(
                    current.stopId()
            );
        }

        Collections.reverse(
                stopPath
        );

        Collections.reverse(
                edgePath
        );

        return Optional.of(
                new PlannedPath(
                        context.originStop(),
                        context.destinationStop(),
                        context.originDistanceKm(),
                        stopPath,
                        edgePath
                )
        );
    }

    private boolean hasCoordinates(
            Stop stop) {

        return stop != null
                && stop.getLatitude() != null
                && stop.getLongitude() != null;
    }

    private record NodeScore(
            Long stopId,
            double score) {
    }

    private record SearchState(
            Long stopId,
            Long routeId) {
    }

    private record StateScore(
            SearchState state,
            double score) {
    }

    private record TransferScore(
            int transferCount,
            int durationMinutes) {
    }

    private record TransferQueueItem(
            SearchState state,
            TransferScore score) {
    }

    private record SearchContext(
            Stop originStop,
            Stop destinationStop,
            double originDistanceKm,
            Long startStopId,
            Long targetStopId,
            Map<Long,
                    List<TransportGraphService.GraphEdge>>
            graph) {
    }

    public static class PlannedPath {

        private final Stop originStop;
        private final Stop destinationStop;
        private final double originDistanceKm;

        private final List<Long> stopPath;

        private final List<
                TransportGraphService.GraphEdge>
                edgePath;

        public PlannedPath(
                Stop originStop,
                Stop destinationStop,
                double originDistanceKm,
                List<Long> stopPath,
                List<TransportGraphService.GraphEdge>
                        edgePath) {

            this.originStop =
                    originStop;

            this.destinationStop =
                    destinationStop;

            this.originDistanceKm =
                    originDistanceKm;

            this.stopPath =
                    stopPath;

            this.edgePath =
                    edgePath;
        }

        public Stop getOriginStop() {
            return originStop;
        }

        public Stop getDestinationStop() {
            return destinationStop;
        }

        public double getOriginDistanceKm() {
            return originDistanceKm;
        }

        public List<Long> getStopPath() {
            return stopPath;
        }

        public List<
                TransportGraphService.GraphEdge>
        getEdgePath() {

            return edgePath;
        }
    }
}