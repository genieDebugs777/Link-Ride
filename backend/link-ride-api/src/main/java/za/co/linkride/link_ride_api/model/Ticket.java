package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "tickets")
public class Ticket {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ticket_id")
    private Long ticketId;

    @Column(name = "journey_id", nullable = false)
    private Long journeyId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(
            name = "ticket_code",
            nullable = false,
            unique = true
    )
    private String ticketCode;

    @Column(name = "ticket_status", nullable = false)
    private String ticketStatus;

    @Column(name = "issued_at", nullable = false)
    private LocalDateTime issuedAt;

    @Column(name = "activated_at")
    private LocalDateTime activatedAt;

    public Ticket() {
    }

    public Ticket(
            Long journeyId,
            Long userId,
            String ticketCode,
            String ticketStatus,
            LocalDateTime issuedAt,
            LocalDateTime activatedAt) {

        this.journeyId = journeyId;
        this.userId = userId;
        this.ticketCode = ticketCode;
        this.ticketStatus = ticketStatus;
        this.issuedAt = issuedAt;
        this.activatedAt = activatedAt;
    }

    public Long getTicketId() {
        return ticketId;
    }

    public void setTicketId(
            Long ticketId) {

        this.ticketId = ticketId;
    }

    public Long getJourneyId() {
        return journeyId;
    }

    public void setJourneyId(
            Long journeyId) {

        this.journeyId = journeyId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(
            Long userId) {

        this.userId = userId;
    }

    public String getTicketCode() {
        return ticketCode;
    }

    public void setTicketCode(
            String ticketCode) {

        this.ticketCode = ticketCode;
    }

    public String getTicketStatus() {
        return ticketStatus;
    }

    public void setTicketStatus(
            String ticketStatus) {

        this.ticketStatus = ticketStatus;
    }

    public LocalDateTime getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(
            LocalDateTime issuedAt) {

        this.issuedAt = issuedAt;
    }

    public LocalDateTime getActivatedAt() {
        return activatedAt;
    }

    public void setActivatedAt(
            LocalDateTime activatedAt) {

        this.activatedAt = activatedAt;
    }
}