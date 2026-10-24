package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.MfaCode;

import java.util.List;
import java.util.Optional;

public interface MfaCodeRepository
        extends JpaRepository<MfaCode, Long> {

    Optional<MfaCode>
    findTopByUserIdAndUsedFalseOrderByCreatedAtDesc(
            Long userId
    );

    List<MfaCode>
    findByUserIdAndUsedFalse(
            Long userId
    );
}
