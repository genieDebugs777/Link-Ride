package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.dto.JourneyLegOptionResponse;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.repository.StopRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class JourneyLegBuilderService {

    private final StopRepository stopRepository;
    private final JourneyEstimationService journeyEstimationService;

    public JourneyLegBuilderService(
            StopRepository stopRepository,
            JourneyEstimationService journeyEstimationService) {

        this.stopRepository =
                stopRepository;

        this.journeyEstimationService =
                journeyEstimationService;
    }

    public List<JourneyLegOptionResponse> buildLegs(
            JourneyPlanningService.PlannedPath plannedPath) {

        List<Long> stopPath =
                plannedPath.getStopPath();

        List<TransportGraphService.GraphEdge> edgePath =
                plannedPath.getEdgePath();

        List<JourneyLegOptionResponse> legs =
                new ArrayList<>();

        if (stopPath.size() < 2
                || edgePath.isEmpty()) {

            return legs;
        }

        int legOrder = 1;
        int edgeIndex = 0;

        /*
         * Tracks the route currently being used.
         *
         * This is important for prototype fare
         * calculation:
         *
         * first edge on a route
         * -> base fare + distance
         *
         * next edge on same route
         * -> distance only
         *
         * walk transfer
         * -> resets current route
         */
        Long currentActiveRouteId =
                null;

        while (edgeIndex < edgePath.size()) {

            TransportGraphService.GraphEdge firstEdge =
                    edgePath.get(edgeIndex);

            Long legRouteId =
                    firstEdge.getRouteId();

            String legMode =
                    firstEdge.getTransportMode();

            int legStartEdgeIndex =
                    edgeIndex;

            int legEndEdgeIndex =
                    edgeIndex;

            while (legEndEdgeIndex + 1
                    < edgePath.size()) {

                TransportGraphService.GraphEdge nextEdge =
                        edgePath.get(
                                legEndEdgeIndex + 1
                        );

                boolean sameRoute =
                        legRouteId != null
                                && legRouteId.equals(
                                nextEdge.getRouteId()
                        );

                boolean sameTransferType =
                        legRouteId == null
                                && nextEdge.getRouteId() == null
                                && sameMode(
                                legMode,
                                nextEdge.getTransportMode()
                        );

                if (!sameRoute
                        && !sameTransferType) {

                    break;
                }

                legEndEdgeIndex++;
            }

            Long legStartStopId =
                    stopPath.get(
                            legStartEdgeIndex
                    );

            Long legEndStopId =
                    stopPath.get(
                            legEndEdgeIndex + 1
                    );

            Optional<Stop> legStartStopOptional =
                    stopRepository.findById(
                            legStartStopId
                    );

            Optional<Stop> legEndStopOptional =
                    stopRepository.findById(
                            legEndStopId
                    );

            if (legStartStopOptional.isEmpty()
                    || legEndStopOptional.isEmpty()) {

                edgeIndex =
                        legEndEdgeIndex + 1;

                continue;
            }

            int legDurationMinutes = 0;
            double legCost = 0.0;

            /*
             * Score every real graph edge contained
             * inside this commuter-facing leg.
             */
            for (int currentEdgeIndex =
                 legStartEdgeIndex;
                 currentEdgeIndex <= legEndEdgeIndex;
                 currentEdgeIndex++) {

                TransportGraphService.GraphEdge edge =
                        edgePath.get(
                                currentEdgeIndex
                        );

                Long edgeStartStopId =
                        stopPath.get(
                                currentEdgeIndex
                        );

                Long edgeEndStopId =
                        stopPath.get(
                                currentEdgeIndex + 1
                        );

                Optional<Stop> edgeStartStopOptional =
                        stopRepository.findById(
                                edgeStartStopId
                        );

                Optional<Stop> edgeEndStopOptional =
                        stopRepository.findById(
                                edgeEndStopId
                        );

                if (edgeStartStopOptional.isEmpty()
                        || edgeEndStopOptional.isEmpty()) {

                    continue;
                }

                Stop edgeStartStop =
                        edgeStartStopOptional.get();

                Stop edgeEndStop =
                        edgeEndStopOptional.get();

                if (!hasCoordinates(edgeStartStop)
                        || !hasCoordinates(edgeEndStop)) {

                    continue;
                }

                int edgeDuration =
                        journeyEstimationService
                                .estimateDurationMinutes(
                                        edgeStartStop.getLatitude(),
                                        edgeStartStop.getLongitude(),
                                        edgeEndStop.getLatitude(),
                                        edgeEndStop.getLongitude(),
                                        edge.getTransportMode()
                                );

                Long edgeRouteId =
                        edge.getRouteId();

                boolean chargeBaseFare =
                        edgeRouteId != null
                                && !edgeRouteId.equals(
                                currentActiveRouteId
                        );

                double edgeCost =
                        journeyEstimationService
                                .estimateEdgeCost(
                                        edgeStartStop.getLatitude(),
                                        edgeStartStop.getLongitude(),
                                        edgeEndStop.getLatitude(),
                                        edgeEndStop.getLongitude(),
                                        edge.getTransportMode(),
                                        chargeBaseFare
                                );

                legDurationMinutes +=
                        edgeDuration;

                legCost +=
                        edgeCost;

                /*
                 * Walking / transfer edges have no
                 * routeId, so they reset the current
                 * boarded route.
                 */
                currentActiveRouteId =
                        edgeRouteId;
            }

            Stop legStartStop =
                    legStartStopOptional.get();

            Stop legEndStop =
                    legEndStopOptional.get();

            JourneyLegOptionResponse leg =
                    new JourneyLegOptionResponse(
                            legOrder,
                            legMode,
                            legRouteId,

                            legStartStop.getStopName(),
                            legStartStop.getLatitude(),
                            legStartStop.getLongitude(),

                            legEndStop.getStopName(),
                            legEndStop.getLatitude(),
                            legEndStop.getLongitude(),

                            legDurationMinutes,
                            roundCurrency(
                                    legCost
                            )
                    );

            legs.add(
                    leg
            );

            legOrder++;

            edgeIndex =
                    legEndEdgeIndex + 1;
        }

        return legs;
    }

    private boolean sameMode(
            String firstMode,
            String secondMode) {

        if (firstMode == null
                || secondMode == null) {

            return firstMode == null
                    && secondMode == null;
        }

        return firstMode.equalsIgnoreCase(
                secondMode
        );
    }

    private boolean hasCoordinates(
            Stop stop) {

        return stop.getLatitude() != null
                && stop.getLongitude() != null;
    }

    private double roundCurrency(
            double value) {

        return Math.round(
                value * 100.0
        ) / 100.0;
    }
}