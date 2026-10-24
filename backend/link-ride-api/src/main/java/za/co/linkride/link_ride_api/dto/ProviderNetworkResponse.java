package za.co.linkride.link_ride_api.dto;

import java.util.List;

public class ProviderNetworkResponse {

    private Long providerId;
    private String providerName;
    private String providerType;
    private String providerStatus;
    private String sourceType;
    private List<ProviderRouteResponse> routes;

    public ProviderNetworkResponse() {
    }

    public ProviderNetworkResponse(
            Long providerId,
            String providerName,
            String providerType,
            String providerStatus,
            String sourceType,
            List<ProviderRouteResponse> routes) {

        this.providerId = providerId;
        this.providerName = providerName;
        this.providerType = providerType;
        this.providerStatus = providerStatus;
        this.sourceType = sourceType;
        this.routes = routes;
    }

    public Long getProviderId() {
        return providerId;
    }

    public void setProviderId(Long providerId) {
        this.providerId = providerId;
    }

    public String getProviderName() {
        return providerName;
    }

    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getProviderType() {
        return providerType;
    }

    public void setProviderType(String providerType) {
        this.providerType = providerType;
    }

    public String getProviderStatus() {
        return providerStatus;
    }

    public void setProviderStatus(String providerStatus) {
        this.providerStatus = providerStatus;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public List<ProviderRouteResponse> getRoutes() {
        return routes;
    }

    public void setRoutes(List<ProviderRouteResponse> routes) {
        this.routes = routes;
    }
}
