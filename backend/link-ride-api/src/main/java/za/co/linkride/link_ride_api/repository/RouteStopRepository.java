package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.RouteStop;
import java.util.Optional;

public interface RouteStopRepository
        extends JpaRepository<RouteStop, Long> {
    Optional<RouteStop> findByRouteIdAndStopOrder(
            Long routeId,
            Integer stopOrder
    );
}