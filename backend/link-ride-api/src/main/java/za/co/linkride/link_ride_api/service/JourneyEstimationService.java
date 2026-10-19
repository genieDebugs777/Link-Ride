package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.dto.JourneyLegOptionResponse;

import java.util.List;

@Service
public class JourneyEstimationService {

    private static final double EARTH_RADIUS_KM = 6371.0;

    /*
     * Prototype operating assumptions.
     *
     * These are not real operator fares or timetables.
     * They exist only so Link Ride can consistently
     * compare journey alternatives.
     */

    private static final double WALK_SPEED_KMH = 5.0;
    private static final double BUS_SPEED_KMH = 25.0;
    private static final double TRAIN_SPEED_KMH = 45.0;
    private static final double TAXI_SPEED_KMH = 30.0;

    /*
     * Straight-line coordinates underestimate real
     * travelled distance because route geometry is
     * not yet stored.
     */

    private static final double WALK_DISTANCE_FACTOR = 1.15;
    private static final double TRANSIT_DISTANCE_FACTOR = 1.20;

    /*
     * Prototype fare rules.
     */

    private static final double TRAIN_BASE_FARE = 12.00;
    private static final double TRAIN_PER_KM = 1.20;

    private static final double BUS_BASE_FARE = 8.00;
    private static final double BUS_PER_KM = 0.80;

    private static final double TAXI_BASE_FARE = 10.00;
    private static final double TAXI_PER_KM = 1.00;

    public EstimationSummary estimateJourney(
            List<JourneyLegOptionResponse> legs) {

        int totalDurationMinutes = 0;
        double totalCost = 0.0;

        for (JourneyLegOptionResponse leg : legs) {

            if (!hasCoordinates(leg)) {
                continue;
            }

            int durationMinutes =
                    estimateDurationMinutes(
                            leg.getStartLatitude(),
                            leg.getStartLongitude(),
                            leg.getEndLatitude(),
                            leg.getEndLongitude(),
                            leg.getTransportMode()
                    );

            double cost =
                    estimateCost(
                            leg.getStartLatitude(),
                            leg.getStartLongitude(),
                            leg.getEndLatitude(),
                            leg.getEndLongitude(),
                            leg.getTransportMode()
                    );

            leg.setDurationMinutes(
                    durationMinutes
            );

            leg.setCost(
                    roundCurrency(cost)
            );

            totalDurationMinutes +=
                    durationMinutes;

            totalCost +=
                    cost;
        }

        return new EstimationSummary(
                totalDurationMinutes,
                roundCurrency(totalCost)
        );
    }

    public int estimateDurationMinutes(
            double startLatitude,
            double startLongitude,
            double endLatitude,
            double endLongitude,
            String transportMode) {

        String mode =
                normalizeMode(
                        transportMode
                );

        double directDistanceKm =
                calculateDistanceKm(
                        startLatitude,
                        startLongitude,
                        endLatitude,
                        endLongitude
                );

        double estimatedDistanceKm =
                estimateTravelDistance(
                        directDistanceKm,
                        mode
                );

        return estimateDurationFromDistance(
                estimatedDistanceKm,
                mode
        );
    }

    /*
     * Full leg cost.
     *
     * Used after graph edges are collapsed into
     * commuter-facing journey legs.
     */
    public double estimateCost(
            double startLatitude,
            double startLongitude,
            double endLatitude,
            double endLongitude,
            String transportMode) {

        String mode =
                normalizeMode(
                        transportMode
                );

        double directDistanceKm =
                calculateDistanceKm(
                        startLatitude,
                        startLongitude,
                        endLatitude,
                        endLongitude
                );

        double estimatedDistanceKm =
                estimateTravelDistance(
                        directDistanceKm,
                        mode
                );

        return roundCurrency(
                estimateCostFromDistance(
                        estimatedDistanceKm,
                        mode,
                        true
                )
        );
    }

    /*
     * Graph-search fare estimator.
     *
     * chargeBaseFare = true:
     * commuter is boarding a new transport service.
     *
     * chargeBaseFare = false:
     * commuter remains on the same route, so only
     * the distance component is added.
     */
    public double estimateEdgeCost(
            double startLatitude,
            double startLongitude,
            double endLatitude,
            double endLongitude,
            String transportMode,
            boolean chargeBaseFare) {

        String mode =
                normalizeMode(
                        transportMode
                );

        double directDistanceKm =
                calculateDistanceKm(
                        startLatitude,
                        startLongitude,
                        endLatitude,
                        endLongitude
                );

        double estimatedDistanceKm =
                estimateTravelDistance(
                        directDistanceKm,
                        mode
                );

        return roundCurrency(
                estimateCostFromDistance(
                        estimatedDistanceKm,
                        mode,
                        chargeBaseFare
                )
        );
    }

    private boolean hasCoordinates(
            JourneyLegOptionResponse leg) {

        return leg.getStartLatitude() != null
                && leg.getStartLongitude() != null
                && leg.getEndLatitude() != null
                && leg.getEndLongitude() != null;
    }

    private String normalizeMode(
            String transportMode) {

        if (transportMode == null) {
            return "";
        }

        return transportMode
                .trim()
                .toUpperCase();
    }

    private double estimateTravelDistance(
            double directDistanceKm,
            String mode) {

        if ("WALK".equals(mode)) {
            return directDistanceKm
                    * WALK_DISTANCE_FACTOR;
        }

        return directDistanceKm
                * TRANSIT_DISTANCE_FACTOR;
    }

    private int estimateDurationFromDistance(
            double distanceKm,
            String mode) {

        double speedKmh =
                switch (mode) {

                    case "WALK" ->
                            WALK_SPEED_KMH;

                    case "TRAIN" ->
                            TRAIN_SPEED_KMH;

                    case "BUS" ->
                            BUS_SPEED_KMH;

                    case "TAXI" ->
                            TAXI_SPEED_KMH;

                    default ->
                            BUS_SPEED_KMH;
                };

        double hours =
                distanceKm / speedKmh;

        int minutes =
                (int) Math.ceil(
                        hours * 60.0
                );

        return Math.max(
                minutes,
                1
        );
    }

    private double estimateCostFromDistance(
            double distanceKm,
            String mode,
            boolean chargeBaseFare) {

        if ("WALK".equals(mode)) {
            return 0.0;
        }

        double baseFare =
                chargeBaseFare
                        ? getBaseFare(mode)
                        : 0.0;

        double perKmRate =
                getPerKmRate(mode);

        return baseFare
                + (
                distanceKm
                        * perKmRate
        );
    }

    private double getBaseFare(
            String mode) {

        return switch (mode) {

            case "TRAIN" ->
                    TRAIN_BASE_FARE;

            case "BUS" ->
                    BUS_BASE_FARE;

            case "TAXI" ->
                    TAXI_BASE_FARE;

            default ->
                    BUS_BASE_FARE;
        };
    }

    private double getPerKmRate(
            String mode) {

        return switch (mode) {

            case "TRAIN" ->
                    TRAIN_PER_KM;

            case "BUS" ->
                    BUS_PER_KM;

            case "TAXI" ->
                    TAXI_PER_KM;

            case "WALK" ->
                    0.0;

            default ->
                    BUS_PER_KM;
        };
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

    private double roundCurrency(
            double value) {

        return Math.round(
                value * 100.0
        ) / 100.0;
    }

    public static class EstimationSummary {

        private final int totalDurationMinutes;
        private final double totalCost;

        public EstimationSummary(
                int totalDurationMinutes,
                double totalCost) {

            this.totalDurationMinutes =
                    totalDurationMinutes;

            this.totalCost =
                    totalCost;
        }

        public int getTotalDurationMinutes() {
            return totalDurationMinutes;
        }

        public double getTotalCost() {
            return totalCost;
        }
    }
}