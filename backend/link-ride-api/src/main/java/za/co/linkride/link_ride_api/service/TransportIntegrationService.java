package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.dto.ProviderNetworkResponse;
import za.co.linkride.link_ride_api.integration.TransportProviderAdapter;

import java.util.Comparator;
import java.util.List;

@Service
public class TransportIntegrationService {

    private final List<TransportProviderAdapter> providerAdapters;

    public TransportIntegrationService(
            List<TransportProviderAdapter> providerAdapters) {

        this.providerAdapters =
                providerAdapters;
    }

    public List<ProviderNetworkResponse>
    getUnifiedProviderNetwork() {

        return providerAdapters
                .stream()
                .flatMap(adapter ->
                        adapter
                                .fetchProviderNetwork()
                                .stream()
                )
                .sorted(
                        Comparator.comparing(
                                ProviderNetworkResponse::getProviderId
                        )
                )
                .toList();
    }

    public List<String> getAvailableAdapterNames() {

        return providerAdapters
                .stream()
                .map(
                        TransportProviderAdapter::getAdapterName
                )
                .sorted()
                .toList();
    }
}
