package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.Route;

import java.util.Optional;

public interface RouteRepository
        extends JpaRepository<Route, Long> {

    Optional<Route> findByRouteName(String routeName);
}