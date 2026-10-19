package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.Ticket;
import za.co.linkride.link_ride_api.repository.JourneyRepository;
import za.co.linkride.link_ride_api.repository.TicketRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class TicketService {

    private final TicketRepository ticketRepository;
    private final JourneyRepository journeyRepository;

    public TicketService(
            TicketRepository ticketRepository,
            JourneyRepository journeyRepository) {

        this.ticketRepository =
                ticketRepository;

        this.journeyRepository =
                journeyRepository;
    }

    // ============================================================
    // ISSUE TICKET
    // ============================================================

    @Transactional
    public Ticket issueTicket(
            Long userId,
            Long journeyId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        if (journeyId == null) {
            throw new IllegalArgumentException(
                    "Journey ID is required."
            );
        }

        Journey journey =
                journeyRepository
                        .findById(journeyId)
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Journey not found."
                                        )
                        );

        if (!userId.equals(
                journey.getUserId())) {

            throw new IllegalArgumentException(
                    "This journey does not belong to the authenticated user."
            );
        }

        Optional<Ticket> existingTicket =
                ticketRepository
                        .findTopByJourneyIdOrderByIssuedAtDesc(
                                journeyId
                        );

        if (existingTicket.isPresent()) {
            return existingTicket.get();
        }

        String journeyStatus =
                journey.getJourneyStatus();

        if (journeyStatus == null
                || !journeyStatus.equalsIgnoreCase(
                "PAID"
        )) {

            throw new IllegalArgumentException(
                    "Only a PAID journey can receive a ticket."
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        Ticket ticket =
                new Ticket(
                        journeyId,
                        userId,
                        generateTicketCode(),
                        "ISSUED",
                        now,
                        null
                );

        Ticket savedTicket =
                ticketRepository.save(
                        ticket
                );

        journey.setJourneyStatus(
                "READY"
        );

        journeyRepository.save(
                journey
        );

        return savedTicket;
    }

    // ============================================================
    // ACTIVATE TICKET / START JOURNEY
    // ============================================================

    @Transactional
    public Ticket activateTicket(
            Long userId,
            Long journeyId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        if (journeyId == null) {
            throw new IllegalArgumentException(
                    "Journey ID is required."
            );
        }

        Journey journey =
                journeyRepository
                        .findById(journeyId)
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Journey not found."
                                        )
                        );

        if (!userId.equals(
                journey.getUserId())) {

            throw new IllegalArgumentException(
                    "This journey does not belong to the authenticated user."
            );
        }

        Ticket ticket =
                ticketRepository
                        .findTopByJourneyIdOrderByIssuedAtDesc(
                                journeyId
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "No ticket exists for this journey."
                                        )
                        );

        if (!userId.equals(
                ticket.getUserId())) {

            throw new IllegalArgumentException(
                    "This ticket does not belong to the authenticated user."
            );
        }

        String journeyStatus =
                journey.getJourneyStatus();

        String ticketStatus =
                ticket.getTicketStatus();

        // Safe repeated request:
        // if activation already happened,
        // return the existing active ticket.
        if (journeyStatus != null
                && journeyStatus.equalsIgnoreCase(
                "IN_PROGRESS"
        )
                && ticketStatus != null
                && ticketStatus.equalsIgnoreCase(
                "ACTIVE"
        )) {

            return ticket;
        }

        if (journeyStatus == null
                || !journeyStatus.equalsIgnoreCase(
                "READY"
        )) {

            throw new IllegalArgumentException(
                    "Only a READY journey can be started."
            );
        }

        if (ticketStatus == null
                || !ticketStatus.equalsIgnoreCase(
                "ISSUED"
        )) {

            throw new IllegalArgumentException(
                    "Only an ISSUED ticket can be activated."
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        ticket.setTicketStatus(
                "ACTIVE"
        );

        ticket.setActivatedAt(
                now
        );

        Ticket savedTicket =
                ticketRepository.save(
                        ticket
                );

        journey.setJourneyStatus(
                "IN_PROGRESS"
        );

        journeyRepository.save(
                journey
        );

        return savedTicket;
    }

    // ============================================================
// COMPLETE JOURNEY
// ============================================================

    @Transactional
    public Ticket completeJourney(
            Long userId,
            Long journeyId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        if (journeyId == null) {
            throw new IllegalArgumentException(
                    "Journey ID is required."
            );
        }

        Journey journey =
                journeyRepository
                        .findById(journeyId)
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Journey not found."
                                        )
                        );

        if (!userId.equals(
                journey.getUserId())) {

            throw new IllegalArgumentException(
                    "This journey does not belong to the authenticated user."
            );
        }

        Ticket ticket =
                ticketRepository
                        .findTopByJourneyIdOrderByIssuedAtDesc(
                                journeyId
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "No ticket exists for this journey."
                                        )
                        );

        if (!userId.equals(
                ticket.getUserId())) {

            throw new IllegalArgumentException(
                    "This ticket does not belong to the authenticated user."
            );
        }

        String journeyStatus =
                journey.getJourneyStatus();

        String ticketStatus =
                ticket.getTicketStatus();

        // Safe repeated request.
        if (journeyStatus != null
                && journeyStatus.equalsIgnoreCase(
                "COMPLETED"
        )
                && ticketStatus != null
                && ticketStatus.equalsIgnoreCase(
                "USED"
        )) {

            return ticket;
        }

        if (journeyStatus == null
                || !journeyStatus.equalsIgnoreCase(
                "IN_PROGRESS"
        )) {

            throw new IllegalArgumentException(
                    "Only an IN_PROGRESS journey can be completed."
            );
        }

        if (ticketStatus == null
                || !ticketStatus.equalsIgnoreCase(
                "ACTIVE"
        )) {

            throw new IllegalArgumentException(
                    "Only an ACTIVE ticket can be completed."
            );
        }

        ticket.setTicketStatus(
                "USED"
        );

        Ticket savedTicket =
                ticketRepository.save(
                        ticket
                );

        journey.setJourneyStatus(
                "COMPLETED"
        );

        journeyRepository.save(
                journey
        );

        return savedTicket;
    }

    // ============================================================
    // READ
    // ============================================================

    public List<Ticket> getTicketsForUser(
            Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        return ticketRepository
                .findByUserIdOrderByIssuedAtDesc(
                        userId
                );
    }

    public Optional<Ticket> getCurrentTicket(
            Long userId) {

        if (userId == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is required."
            );
        }

        List<Ticket> tickets =
                ticketRepository
                        .findByUserIdOrderByIssuedAtDesc(
                                userId
                        );

        Optional<Ticket> activeTicket =
                tickets.stream()
                        .filter(
                                ticket ->
                                        ticket.getTicketStatus() != null
                                                && ticket.getTicketStatus()
                                                .equalsIgnoreCase(
                                                        "ACTIVE"
                                                )
                        )
                        .findFirst();

        if (activeTicket.isPresent()) {
            return activeTicket;
        }

        return tickets.stream()
                .filter(
                        ticket ->
                                ticket.getTicketStatus() != null
                                        && ticket.getTicketStatus()
                                        .equalsIgnoreCase(
                                                "ISSUED"
                                        )
                )
                .findFirst();
    }

    public Optional<Ticket>
    getLatestTicketForJourney(
            Long journeyId) {

        return ticketRepository
                .findTopByJourneyIdOrderByIssuedAtDesc(
                        journeyId
                );
    }

    // ============================================================
    // TICKET CODE
    // ============================================================

    private String generateTicketCode() {

        String ticketCode;

        do {
            ticketCode =
                    "LRT-"
                            + UUID.randomUUID()
                            .toString()
                            .replace("-", "")
                            .substring(0, 12)
                            .toUpperCase();

        } while (
                ticketRepository
                        .existsByTicketCode(
                                ticketCode
                        )
        );

        return ticketCode;
    }
}