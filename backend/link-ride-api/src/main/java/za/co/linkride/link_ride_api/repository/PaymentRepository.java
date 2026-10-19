package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.Payment;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository
        extends JpaRepository<Payment, Long> {

    List<Payment>
    findByUserIdOrderByCreatedAtDesc(
            Long userId
    );

    Optional<Payment>
    findTopByJourneyIdOrderByCreatedAtDesc(
            Long journeyId
    );

    boolean existsByTransactionReference(
            String transactionReference
    );
}