package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.TransportProvider;

import java.util.Optional;

public interface TransportProviderRepository
        extends JpaRepository<TransportProvider, Long> {

    Optional<TransportProvider> findByProviderName(String providerName);
}