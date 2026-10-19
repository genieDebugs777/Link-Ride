package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

@Entity
@Table(
        name = "journey_legs",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_journey_leg_order",
                        columnNames = {"journey_id", "leg_order"}
                )
        }
)
public class JourneyLeg {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "journey_leg_id")
    private Long journeyLegId;

    @Column(name = "journey_id", nullable = false)
    private Long journeyId;

    @Column(name = "route_id")
    private Long routeId;

    @Column(name = "origin_name", nullable = false)
    private String originName;

    @Column(name = "destination_name", nullable = false)
    private String destinationName;

    @Column(name = "origin_latitude")
    private Double originLatitude;

    @Column(name = "origin_longitude")
    private Double originLongitude;

    @Column(name = "destination_latitude")
    private Double destinationLatitude;

    @Column(name = "destination_longitude")
    private Double destinationLongitude;

    @Column(name = "transport_mode", nullable = false)
    private String transportMode;

    @Column(name = "leg_order", nullable = false)
    private Integer legOrder;

    @Column(name = "estimated_duration", nullable = false)
    private Integer estimatedDuration;

    @Column(name = "estimated_cost", nullable = false)
    private Double estimatedCost;

    public JourneyLeg() {
    }

    public JourneyLeg(
            Long journeyId,
            Long routeId,
            String originName,
            String destinationName,
            Double originLatitude,
            Double originLongitude,
            Double destinationLatitude,
            Double destinationLongitude,
            String transportMode,
            Integer legOrder,
            Integer estimatedDuration,
            Double estimatedCost) {

        this.journeyId = journeyId;
        this.routeId = routeId;
        this.originName = originName;
        this.destinationName = destinationName;
        this.originLatitude = originLatitude;
        this.originLongitude = originLongitude;
        this.destinationLatitude = destinationLatitude;
        this.destinationLongitude = destinationLongitude;
        this.transportMode = transportMode;
        this.legOrder = legOrder;
        this.estimatedDuration = estimatedDuration;
        this.estimatedCost = estimatedCost;
    }

    public Long getJourneyLegId() {
        return journeyLegId;
    }

    public void setJourneyLegId(Long journeyLegId) {
        this.journeyLegId = journeyLegId;
    }

    public Long getJourneyId() {
        return journeyId;
    }

    public void setJourneyId(Long journeyId) {
        this.journeyId = journeyId;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getOriginName() {
        return originName;
    }

    public void setOriginName(String originName) {
        this.originName = originName;
    }

    public String getDestinationName() {
        return destinationName;
    }

    public void setDestinationName(String destinationName) {
        this.destinationName = destinationName;
    }

    public Double getOriginLatitude() {
        return originLatitude;
    }

    public void setOriginLatitude(Double originLatitude) {
        this.originLatitude = originLatitude;
    }

    public Double getOriginLongitude() {
        return originLongitude;
    }

    public void setOriginLongitude(Double originLongitude) {
        this.originLongitude = originLongitude;
    }

    public Double getDestinationLatitude() {
        return destinationLatitude;
    }

    public void setDestinationLatitude(Double destinationLatitude) {
        this.destinationLatitude = destinationLatitude;
    }

    public Double getDestinationLongitude() {
        return destinationLongitude;
    }

    public void setDestinationLongitude(Double destinationLongitude) {
        this.destinationLongitude = destinationLongitude;
    }

    public String getTransportMode() {
        return transportMode;
    }

    public void setTransportMode(String transportMode) {
        this.transportMode = transportMode;
    }

    public Integer getLegOrder() {
        return legOrder;
    }

    public void setLegOrder(Integer legOrder) {
        this.legOrder = legOrder;
    }

    public Integer getEstimatedDuration() {
        return estimatedDuration;
    }

    public void setEstimatedDuration(Integer estimatedDuration) {
        this.estimatedDuration = estimatedDuration;
    }

    public Double getEstimatedCost() {
        return estimatedCost;
    }

    public void setEstimatedCost(Double estimatedCost) {
        this.estimatedCost = estimatedCost;
    }
}