package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.Route;
import za.co.linkride.link_ride_api.model.TransportProvider;
import za.co.linkride.link_ride_api.repository.RouteRepository;
import za.co.linkride.link_ride_api.repository.TransportProviderRepository;

import java.util.Comparator;
import java.util.List;

@Service
public class NetworkAdminService {

    private final TransportProviderRepository transportProviderRepository;
    private final RouteRepository routeRepository;

    public NetworkAdminService(
            TransportProviderRepository transportProviderRepository,
            RouteRepository routeRepository) {

        this.transportProviderRepository =
                transportProviderRepository;

        this.routeRepository =
                routeRepository;
    }

    public List<TransportProvider> getProviders() {
        return transportProviderRepository
                .findAll()
                .stream()
                .sorted(
                        Comparator.comparing(
                                TransportProvider::getProviderId
                        )
                )
                .toList();
    }

    public List<Route> getRoutes() {
        return routeRepository
                .findAll()
                .stream()
                .sorted(
                        Comparator.comparing(
                                Route::getRouteId
                        )
                )
                .toList();
    }
}
