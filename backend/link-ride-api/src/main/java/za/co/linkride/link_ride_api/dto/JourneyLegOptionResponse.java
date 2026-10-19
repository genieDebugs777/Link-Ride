package za.co.linkride.link_ride_api.dto;

public class JourneyLegOptionResponse {

    private Integer legOrder;

    private String transportMode;

    private Long routeId;

    private String startLocationName;
    private Double startLatitude;
    private Double startLongitude;

    private String endLocationName;
    private Double endLatitude;
    private Double endLongitude;

    private Integer durationMinutes;

    private Double cost;

    public JourneyLegOptionResponse() {
    }

    public JourneyLegOptionResponse(
            Integer legOrder,
            String transportMode,
            Long routeId,
            String startLocationName,
            Double startLatitude,
            Double startLongitude,
            String endLocationName,
            Double endLatitude,
            Double endLongitude,
            Integer durationMinutes,
            Double cost) {

        this.legOrder = legOrder;
        this.transportMode = transportMode;
        this.routeId = routeId;
        this.startLocationName = startLocationName;
        this.startLatitude = startLatitude;
        this.startLongitude = startLongitude;
        this.endLocationName = endLocationName;
        this.endLatitude = endLatitude;
        this.endLongitude = endLongitude;
        this.durationMinutes = durationMinutes;
        this.cost = cost;
    }

    public Integer getLegOrder() {
        return legOrder;
    }

    public void setLegOrder(Integer legOrder) {
        this.legOrder = legOrder;
    }

    public String getTransportMode() {
        return transportMode;
    }

    public void setTransportMode(String transportMode) {
        this.transportMode = transportMode;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getStartLocationName() {
        return startLocationName;
    }

    public void setStartLocationName(String startLocationName) {
        this.startLocationName = startLocationName;
    }

    public Double getStartLatitude() {
        return startLatitude;
    }

    public void setStartLatitude(Double startLatitude) {
        this.startLatitude = startLatitude;
    }

    public Double getStartLongitude() {
        return startLongitude;
    }

    public void setStartLongitude(Double startLongitude) {
        this.startLongitude = startLongitude;
    }

    public String getEndLocationName() {
        return endLocationName;
    }

    public void setEndLocationName(String endLocationName) {
        this.endLocationName = endLocationName;
    }

    public Double getEndLatitude() {
        return endLatitude;
    }

    public void setEndLatitude(Double endLatitude) {
        this.endLatitude = endLatitude;
    }

    public Double getEndLongitude() {
        return endLongitude;
    }

    public void setEndLongitude(Double endLongitude) {
        this.endLongitude = endLongitude;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public Double getCost() {
        return cost;
    }

    public void setCost(Double cost) {
        this.cost = cost;
    }
}