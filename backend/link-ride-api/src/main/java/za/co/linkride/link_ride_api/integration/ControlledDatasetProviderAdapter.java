package za.co.linkride.link_ride_api.integration;

import org.springframework.stereotype.Component;
import za.co.linkride.link_ride_api.dto.ProviderNetworkResponse;
import za.co.linkride.link_ride_api.dto.ProviderRouteResponse;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.model.TransportProvider;
import za.co.linkride.link_ride_api.repository.RouteRepository;
import za.co.linkride.link_ride_api.repository.TransportProviderRepository;

import java.util.Comparator;
import java.util.List;

@Component
public class ControlledDatasetProviderAdapter
        implements TransportProviderAdapter {

    private static final String SOURCE_TYPE =
            "CONTROLLED_DATASET";

    private final TransportProviderRepository transportProviderRepository;
    private final RouteRepository routeRepository;

    public ControlledDatasetProviderAdapter(
            TransportProviderRepository transportProviderRepository,
            RouteRepository routeRepository) {

        this.transportProviderRepository =
                transportProviderRepository;

        this.routeRepository =
                routeRepository;
    }

    @Override
    public String getAdapterName() {
        return "Link Ride Controlled Dataset Adapter";
    }

    @Override
    public String getSourceType() {
        return SOURCE_TYPE;
    }

    @Override
    public List<ProviderNetworkResponse> fetchProviderNetwork() {

        List<Route> routes =
                routeRepository
                        .findAll();

        return transportProviderRepository
                .findAll()
                .stream()
                .sorted(
                        Comparator.comparing(
                                TransportProvider::getProviderId
                        )
                )
                .map(provider ->
                        toProviderNetwork(
                                provider,
                                routes
                        )
                )
                .toList();
    }

    private ProviderNetworkResponse toProviderNetwork(
            TransportProvider provider,
            List<Route> routes) {

        List<ProviderRouteResponse> providerRoutes =
                routes
                        .stream()
                        .filter(route ->
                                provider
                                        .getProviderId()
                                        .equals(
                                                route.getProviderId()
                                        )
                        )
                        .sorted(
                                Comparator.comparing(
                                        Route::getRouteId
                                )
                        )
                        .map(route ->
                                new ProviderRouteResponse(
                                        route.getRouteId(),
                                        route.getRouteName(),
                                        route.getTransportMode(),
                                        route.getRouteStatus()
                                )
                        )
                        .toList();

        return new ProviderNetworkResponse(
                provider.getProviderId(),
                provider.getProviderName(),
                provider.getProviderType(),
                provider.getProviderStatus(),
                SOURCE_TYPE,
                providerRoutes
        );
    }
}
