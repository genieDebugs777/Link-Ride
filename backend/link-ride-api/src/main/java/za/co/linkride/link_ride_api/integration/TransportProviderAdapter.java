package za.co.linkride.link_ride_api.integration;

import za.co.linkride.link_ride_api.dto.ProviderNetworkResponse;

import java.util.List;

public interface TransportProviderAdapter {

    String getAdapterName();

    String getSourceType();

    List<ProviderNetworkResponse> fetchProviderNetwork();
}
