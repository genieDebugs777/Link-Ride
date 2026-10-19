package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.RouteStop;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.repository.RouteStopRepository;
import za.co.linkride.link_ride_api.repository.StopRepository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class NearbyWalkConnectorService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    /*
     * Prototype walking-transfer threshold.
     *
     * Stops within 600 metres may be connected
     * temporarily in the journey-planning graph.
     */
    private static final double MAX_WALK_DISTANCE_KM = 0.60;

    private final StopRepository stopRepository;
    private final RouteStopRepository routeStopRepository;

    public NearbyWalkConnectorService(
            StopRepository stopRepository,
            RouteStopRepository routeStopRepository) {

        this.stopRepository =
                stopRepository;

        this.routeStopRepository =
                routeStopRepository;
    }

    public List<WalkConnection> findNearbyConnections() {

        List<Stop> activeStops =
                stopRepository.findAll()
                        .stream()
                        .filter(this::isUsableStop)
                        .toList();

        Map<Long, Set<Long>> routesByStop =
                buildRoutesByStop();

        List<WalkConnection> connections =
                new ArrayList<>();

        for (int firstIndex = 0;
             firstIndex < activeStops.size();
             firstIndex++) {

            Stop firstStop =
                    activeStops.get(
                            firstIndex
                    );

            for (int secondIndex =
                 firstIndex + 1;
                 secondIndex < activeStops.size();
                 secondIndex++) {

                Stop secondStop =
                        activeStops.get(
                                secondIndex
                        );

                /*
                 * Do not create a walking shortcut
                 * between two stops already served
                 * by the same route.
                 */
                if (shareRoute(
                        firstStop.getStopId(),
                        secondStop.getStopId(),
                        routesByStop)) {

                    continue;
                }

                double distanceKm =
                        calculateDistanceKm(
                                firstStop.getLatitude(),
                                firstStop.getLongitude(),
                                secondStop.getLatitude(),
                                secondStop.getLongitude()
                        );

                if (distanceKm
                        <= MAX_WALK_DISTANCE_KM) {

                    connections.add(
                            new WalkConnection(
                                    firstStop.getStopId(),
                                    secondStop.getStopId(),
                                    distanceKm
                            )
                    );
                }
            }
        }

        return connections;
    }

    private Map<Long, Set<Long>> buildRoutesByStop() {

        Map<Long, Set<Long>> routesByStop =
                new HashMap<>();

        List<RouteStop> routeStops =
                routeStopRepository.findAll();

        for (RouteStop routeStop : routeStops) {

            routesByStop
                    .computeIfAbsent(
                            routeStop.getStopId(),
                            ignored -> new HashSet<>()
                    )
                    .add(
                            routeStop.getRouteId()
                    );
        }

        return routesByStop;
    }

    private boolean shareRoute(
            Long firstStopId,
            Long secondStopId,
            Map<Long, Set<Long>> routesByStop) {

        Set<Long> firstRoutes =
                routesByStop.getOrDefault(
                        firstStopId,
                        Set.of()
                );

        Set<Long> secondRoutes =
                routesByStop.getOrDefault(
                        secondStopId,
                        Set.of()
                );

        for (Long routeId : firstRoutes) {

            if (secondRoutes.contains(
                    routeId)) {

                return true;
            }
        }

        return false;
    }

    private boolean isUsableStop(
            Stop stop) {

        return stop != null
                && stop.getStopId() != null
                && stop.getLatitude() != null
                && stop.getLongitude() != null
                && "ACTIVE".equalsIgnoreCase(
                stop.getStopStatus()
        );
    }

    private double calculateDistanceKm(
            double latitude1,
            double longitude1,
            double latitude2,
            double longitude2) {

        double latitudeDifference =
                Math.toRadians(
                        latitude2 - latitude1
                );

        double longitudeDifference =
                Math.toRadians(
                        longitude2 - longitude1
                );

        double startLatitude =
                Math.toRadians(latitude1);

        double endLatitude =
                Math.toRadians(latitude2);

        double haversine =
                Math.sin(latitudeDifference / 2)
                        * Math.sin(latitudeDifference / 2)
                        +
                        Math.cos(startLatitude)
                                * Math.cos(endLatitude)
                                *
                                Math.sin(
                                        longitudeDifference / 2
                                )
                                *
                                Math.sin(
                                        longitudeDifference / 2
                                );

        double angularDistance =
                2 * Math.atan2(
                        Math.sqrt(haversine),
                        Math.sqrt(1 - haversine)
                );

        return EARTH_RADIUS_KM
                * angularDistance;
    }

    public record WalkConnection(
            Long stopAId,
            Long stopBId,
            double distanceKm) {
    }
}