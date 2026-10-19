package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.Disruption;

import java.util.List;

public interface DisruptionRepository
        extends JpaRepository<Disruption, Long> {

    List<Disruption>
    findByDisruptionStatusIgnoreCaseOrderByCreatedAtDesc(
            String disruptionStatus
    );

    List<Disruption>
    findByRouteIdAndDisruptionStatusIgnoreCaseOrderByCreatedAtDesc(
            Long routeId,
            String disruptionStatus
    );

    List<Disruption>
    findByRouteIdOrderByCreatedAtDesc(
            Long routeId
    );
}
