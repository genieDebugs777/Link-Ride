package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.EmailVerificationToken;

import java.util.List;
import java.util.Optional;

public interface EmailVerificationTokenRepository
        extends JpaRepository<EmailVerificationToken, Long> {

    Optional<EmailVerificationToken>
    findByTokenHashAndUsedFalse(
            String tokenHash
    );

    List<EmailVerificationToken>
    findByUserIdAndUsedFalse(
            Long userId
    );
}