package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.Stop;

import java.util.List;
import java.util.Optional;

public interface StopRepository
        extends JpaRepository<Stop, Long> {

    Optional<Stop> findByStopName(String stopName);

    Optional<Stop> findByStopNameAndLatitudeAndLongitude(
            String stopName,
            Double latitude,
            Double longitude
    );

    List<Stop> findTop10ByStopNameContainingIgnoreCaseOrderByStopNameAsc(
            String stopName
    );
}
