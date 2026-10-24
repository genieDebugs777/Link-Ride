package za.co.linkride.link_ride_api.dto;

public class ProviderRouteResponse {

    private Long routeId;
    private String routeName;
    private String transportMode;
    private String routeStatus;

    public ProviderRouteResponse() {
    }

    public ProviderRouteResponse(
            Long routeId,
            String routeName,
            String transportMode,
            String routeStatus) {

        this.routeId = routeId;
        this.routeName = routeName;
        this.transportMode = transportMode;
        this.routeStatus = routeStatus;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public String getTransportMode() {
        return transportMode;
    }

    public void setTransportMode(String transportMode) {
        this.transportMode = transportMode;
    }

    public String getRouteStatus() {
        return routeStatus;
    }

    public void setRouteStatus(String routeStatus) {
        this.routeStatus = routeStatus;
    }
}
