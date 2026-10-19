package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.JourneyLeg;

import java.util.List;

public interface JourneyLegRepository
        extends JpaRepository<JourneyLeg, Long> {

    List<JourneyLeg>
    findByJourneyIdOrderByLegOrderAsc(
            Long journeyId
    );

    List<JourneyLeg> findByRouteId(
            Long routeId
    );
}