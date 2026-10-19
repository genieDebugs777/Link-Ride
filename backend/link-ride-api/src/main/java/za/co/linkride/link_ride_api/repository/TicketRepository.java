package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.Ticket;

import java.util.List;
import java.util.Optional;

public interface TicketRepository
        extends JpaRepository<Ticket, Long> {

    Optional<Ticket>
    findTopByJourneyIdOrderByIssuedAtDesc(
            Long journeyId
    );

    List<Ticket>
    findByUserIdOrderByIssuedAtDesc(
            Long userId
    );

    boolean existsByTicketCode(
            String ticketCode
    );
}