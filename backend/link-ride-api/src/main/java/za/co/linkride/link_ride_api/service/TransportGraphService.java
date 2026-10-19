package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.model.RouteStop;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.model.StopTransfer;
import za.co.linkride.link_ride_api.repository.RouteRepository;
import za.co.linkride.link_ride_api.repository.RouteStopRepository;
import za.co.linkride.link_ride_api.repository.StopRepository;
import za.co.linkride.link_ride_api.repository.StopTransferRepository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TransportGraphService {

    private final RouteRepository routeRepository;
    private final RouteStopRepository routeStopRepository;
    private final StopRepository stopRepository;
    private final StopTransferRepository stopTransferRepository;
    private final NearbyWalkConnectorService nearbyWalkConnectorService;

    public TransportGraphService(
            RouteRepository routeRepository,
            RouteStopRepository routeStopRepository,
            StopRepository stopRepository,
            StopTransferRepository stopTransferRepository,
            NearbyWalkConnectorService nearbyWalkConnectorService) {

        this.routeRepository =
                routeRepository;

        this.routeStopRepository =
                routeStopRepository;

        this.stopRepository =
                stopRepository;

        this.stopTransferRepository =
                stopTransferRepository;

        this.nearbyWalkConnectorService =
                nearbyWalkConnectorService;
    }

    public Map<Long, List<GraphEdge>> buildGraph() {

        Map<Long, List<GraphEdge>> graph =
                new HashMap<>();

        List<Stop> stops =
                stopRepository.findAll();

        for (Stop stop : stops) {

            graph.put(
                    stop.getStopId(),
                    new ArrayList<>()
            );
        }

        addRouteEdges(
                graph
        );

        addStoredTransferEdges(
                graph
        );

        addNearbyWalkEdges(
                graph
        );

        return graph;
    }

    /*
     * Creates transport-service edges from the
     * ordered RouteStop records.
     *
     * Example:
     *
     * Pretoria
     * -> Pretoria-wes
     * -> Rebecca
     * -> ...
     */
    private void addRouteEdges(
            Map<Long, List<GraphEdge>> graph) {

        List<Route> routes =
                routeRepository.findAll();

        List<RouteStop> allRouteStops =
                routeStopRepository.findAll();

        for (Route route : routes) {

            List<RouteStop> orderedStops =
                    allRouteStops.stream()
                            .filter(
                                    routeStop ->
                                            routeStop
                                                    .getRouteId()
                                                    .equals(
                                                            route.getRouteId()
                                                    )
                            )
                            .sorted(
                                    Comparator.comparing(
                                            RouteStop::getStopOrder
                                    )
                            )
                            .toList();

            for (int index = 0;
                 index < orderedStops.size() - 1;
                 index++) {

                RouteStop current =
                        orderedStops.get(
                                index
                        );

                RouteStop next =
                        orderedStops.get(
                                index + 1
                        );

                addEdge(
                        graph,
                        current.getStopId(),
                        new GraphEdge(
                                next.getStopId(),
                                route.getRouteId(),
                                route.getTransportMode(),
                                false
                        )
                );

                addEdge(
                        graph,
                        next.getStopId(),
                        new GraphEdge(
                                current.getStopId(),
                                route.getRouteId(),
                                route.getTransportMode(),
                                false
                        )
                );
            }
        }
    }

    /*
     * Adds the explicitly seeded interoperability
     * transfer relationships stored in PostgreSQL.
     */
    private void addStoredTransferEdges(
            Map<Long, List<GraphEdge>> graph) {

        List<StopTransfer> transfers =
                stopTransferRepository.findAll();

        for (StopTransfer transfer : transfers) {

            if (!"ACTIVE".equalsIgnoreCase(
                    transfer.getTransferStatus())) {

                continue;
            }

            addEdge(
                    graph,
                    transfer.getStopAId(),
                    new GraphEdge(
                            transfer.getStopBId(),
                            null,
                            transfer.getTransferMode(),
                            true
                    )
            );

            if (Boolean.TRUE.equals(
                    transfer.getBidirectional())) {

                addEdge(
                        graph,
                        transfer.getStopBId(),
                        new GraphEdge(
                                transfer.getStopAId(),
                                null,
                                transfer.getTransferMode(),
                                true
                        )
                );
            }
        }
    }

    /*
     * Adds temporary proximity-based walking
     * connections.
     *
     * These edges exist only in the in-memory
     * planning graph.
     *
     * Nothing is inserted into stop_transfers.
     */
    private void addNearbyWalkEdges(
            Map<Long, List<GraphEdge>> graph) {

        List<NearbyWalkConnectorService.WalkConnection>
                connections =
                nearbyWalkConnectorService
                        .findNearbyConnections();

        for (NearbyWalkConnectorService.WalkConnection
                connection : connections) {

            addEdge(
                    graph,
                    connection.stopAId(),
                    new GraphEdge(
                            connection.stopBId(),
                            null,
                            "WALK",
                            true
                    )
            );

            addEdge(
                    graph,
                    connection.stopBId(),
                    new GraphEdge(
                            connection.stopAId(),
                            null,
                            "WALK",
                            true
                    )
            );
        }
    }

    /*
     * Adds an edge only when an equivalent one does
     * not already exist.
     *
     * This prevents a manually seeded transfer and
     * a nearby dynamically discovered transfer from
     * appearing twice in the graph.
     */
    private void addEdge(
            Map<Long, List<GraphEdge>> graph,
            Long fromStopId,
            GraphEdge edge) {

        List<GraphEdge> edges =
                graph.computeIfAbsent(
                        fromStopId,
                        ignored -> new ArrayList<>()
                );

        boolean alreadyExists =
                edges.stream()
                        .anyMatch(
                                existing ->
                                        equivalentEdge(
                                                existing,
                                                edge
                                        )
                        );

        if (!alreadyExists) {

            edges.add(
                    edge
            );
        }
    }

    private boolean equivalentEdge(
            GraphEdge first,
            GraphEdge second) {

        boolean sameDestination =
                first.getDestinationStopId()
                        .equals(
                                second.getDestinationStopId()
                        );

        boolean sameRoute =
                first.getRouteId() == null
                        ? second.getRouteId() == null
                        : first.getRouteId()
                        .equals(
                                second.getRouteId()
                        );

        boolean sameMode =
                normalizeMode(
                        first.getTransportMode()
                )
                        .equals(
                                normalizeMode(
                                        second.getTransportMode()
                                )
                        );

        boolean sameTransferState =
                first.isTransfer()
                        == second.isTransfer();

        return sameDestination
                && sameRoute
                && sameMode
                && sameTransferState;
    }

    private String normalizeMode(
            String mode) {

        if (mode == null) {
            return "";
        }

        return mode
                .trim()
                .toUpperCase();
    }

    public static class GraphEdge {

        private final Long destinationStopId;
        private final Long routeId;
        private final String transportMode;
        private final boolean transfer;

        public GraphEdge(
                Long destinationStopId,
                Long routeId,
                String transportMode,
                boolean transfer) {

            this.destinationStopId =
                    destinationStopId;

            this.routeId =
                    routeId;

            this.transportMode =
                    transportMode;

            this.transfer =
                    transfer;
        }

        public Long getDestinationStopId() {
            return destinationStopId;
        }

        public Long getRouteId() {
            return routeId;
        }

        public String getTransportMode() {
            return transportMode;
        }

        public boolean isTransfer() {
            return transfer;
        }
    }
}