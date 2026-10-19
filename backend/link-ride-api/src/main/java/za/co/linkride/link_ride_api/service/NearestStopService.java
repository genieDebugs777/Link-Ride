package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.Stop;
import za.co.linkride.link_ride_api.repository.StopRepository;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@Service
public class NearestStopService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    private final StopRepository stopRepository;

    public NearestStopService(
            StopRepository stopRepository) {

        this.stopRepository = stopRepository;
    }

    public Optional<NearestStopResult> findNearestStop(
            Double latitude,
            Double longitude) {

        if (latitude == null || longitude == null) {
            return Optional.empty();
        }

        List<Stop> stops = stopRepository.findAll();

        return stops.stream()
                .filter(stop ->
                        stop.getLatitude() != null
                                && stop.getLongitude() != null
                                && "ACTIVE".equalsIgnoreCase(
                                stop.getStopStatus()
                        )
                )
                .map(stop ->
                        new NearestStopResult(
                                stop,
                                calculateDistanceKm(
                                        latitude,
                                        longitude,
                                        stop.getLatitude(),
                                        stop.getLongitude()
                                )
                        )
                )
                .min(
                        Comparator.comparingDouble(
                                NearestStopResult::getDistanceKm
                        )
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
                                * Math.sin(
                                longitudeDifference / 2
                        )
                                * Math.sin(
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

    public static class NearestStopResult {

        private final Stop stop;
        private final double distanceKm;

        public NearestStopResult(
                Stop stop,
                double distanceKm) {

            this.stop = stop;
            this.distanceKm = distanceKm;
        }

        public Stop getStop() {
            return stop;
        }

        public double getDistanceKm() {
            return distanceKm;
        }
    }
}