package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "journeys")
public class Journey {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "journey_id")
    private Long journeyId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "origin", nullable = false)
    private String origin;

    @Column(name = "destination", nullable = false)
    private String destination;

    @Column(name = "search_date_time", nullable = false)
    private LocalDateTime searchDateTime;

    @Column(name = "estimated_duration")
    private Integer estimatedDuration;

    @Column(name = "estimated_cost")
    private Double estimatedCost;

    @Column(name = "journey_status", nullable = false)
    private String journeyStatus;

    public Journey() {
    }

    public Journey(Long userId,
                   String origin,
                   String destination,
                   LocalDateTime searchDateTime,
                   Integer estimatedDuration,
                   Double estimatedCost,
                   String journeyStatus) {

        this.userId = userId;
        this.origin = origin;
        this.destination = destination;
        this.searchDateTime = searchDateTime;
        this.estimatedDuration = estimatedDuration;
        this.estimatedCost = estimatedCost;
        this.journeyStatus = journeyStatus;
    }

    public Long getJourneyId() {
        return journeyId;
    }

    public void setJourneyId(Long journeyId) {
        this.journeyId = journeyId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public LocalDateTime getSearchDateTime() {
        return searchDateTime;
    }

    public void setSearchDateTime(LocalDateTime searchDateTime) {
        this.searchDateTime = searchDateTime;
    }

    public Integer getEstimatedDuration() {
        return estimatedDuration;
    }

    public void setEstimatedDuration(Integer estimatedDuration) {
        this.estimatedDuration = estimatedDuration;
    }

    public Double getEstimatedCost() {
        return estimatedCost;
    }

    public void setEstimatedCost(Double estimatedCost) {
        this.estimatedCost = estimatedCost;
    }

    public String getJourneyStatus() {
        return journeyStatus;
    }

    public void setJourneyStatus(String journeyStatus) {
        this.journeyStatus = journeyStatus;
    }
}