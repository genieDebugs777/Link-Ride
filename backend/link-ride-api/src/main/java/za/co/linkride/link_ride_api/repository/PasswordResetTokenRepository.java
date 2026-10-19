package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.PasswordResetToken;

import java.util.List;
import java.util.Optional;

public interface PasswordResetTokenRepository
        extends JpaRepository<PasswordResetToken, Long> {

    Optional<PasswordResetToken>
    findByTokenHashAndUsedFalse(
            String tokenHash
    );

    List<PasswordResetToken>
    findByUserIdAndUsedFalse(
            Long userId
    );
}
