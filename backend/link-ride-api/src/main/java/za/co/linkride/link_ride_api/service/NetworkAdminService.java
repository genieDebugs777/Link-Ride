package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.dto.ProviderNetworkResponse;
import za.co.linkride.link_ride_api.dto.ProviderRouteResponse;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.model.TransportProvider;

import java.util.ArrayList;
import java.util.List;

@Service
public class NetworkAdminService {

    private final TransportIntegrationService transportIntegrationService;

    public NetworkAdminService(
            TransportIntegrationService transportIntegrationService) {

        this.transportIntegrationService =
                transportIntegrationService;
    }

    public List<TransportProvider> getProviders() {

        return transportIntegrationService
                .getUnifiedProviderNetwork()
                .stream()
                .map(this::toTransportProvider)
                .toList();
    }

    public List<Route> getRoutes() {

        List<Route> routes =
                new ArrayList<>();

        for (ProviderNetworkResponse provider :
                transportIntegrationService
                        .getUnifiedProviderNetwork()) {

            for (ProviderRouteResponse route :
                    provider.getRoutes()) {

                Route responseRoute =
                        new Route();

                responseRoute.setRouteId(
                        route.getRouteId()
                );

                responseRoute.setProviderId(
                        provider.getProviderId()
                );

                responseRoute.setRouteName(
                        route.getRouteName()
                );

                responseRoute.setTransportMode(
                        route.getTransportMode()
                );

                responseRoute.setRouteStatus(
                        route.getRouteStatus()
                );

                routes.add(responseRoute);
            }
        }

        return routes;
    }

    public List<ProviderNetworkResponse>
    getUnifiedProviderNetwork() {

        return transportIntegrationService
                .getUnifiedProviderNetwork();
    }

    public List<String> getAvailableAdapters() {

        return transportIntegrationService
                .getAvailableAdapterNames();
    }

    private TransportProvider toTransportProvider(
            ProviderNetworkResponse provider) {

        TransportProvider responseProvider =
                new TransportProvider();

        responseProvider.setProviderId(
                provider.getProviderId()
        );

        responseProvider.setProviderName(
                provider.getProviderName()
        );

        responseProvider.setProviderType(
                provider.getProviderType()
        );

        responseProvider.setProviderStatus(
                provider.getProviderStatus()
        );

        return responseProvider;
    }
}
