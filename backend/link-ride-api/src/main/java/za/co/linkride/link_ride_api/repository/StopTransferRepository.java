package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.StopTransfer;

import java.util.Optional;

public interface StopTransferRepository extends JpaRepository<StopTransfer, Long> {

    Optional<StopTransfer> findByStopAIdAndStopBId(
            Long stopAId,
            Long stopBId
    );
}
