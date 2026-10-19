package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

@Entity
@Table(name = "routes")
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "route_id")
    private Long routeId;

    @Column(name = "provider_id", nullable = false)
    private Long providerId;

    @Column(name = "route_name", nullable = false)
    private String routeName;

    @Column(name = "transport_mode", nullable = false)
    private String transportMode;

    @Column(name = "route_status", nullable = false)
    private String routeStatus;

    public Route() {
    }

    public Route(
            Long providerId,
            String routeName,
            String transportMode,
            String routeStatus) {

        this.providerId = providerId;
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

    public Long getProviderId() {
        return providerId;
    }

    public void setProviderId(Long providerId) {
        this.providerId = providerId;
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