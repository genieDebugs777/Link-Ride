package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "disruptions")
public class Disruption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "disruption_id")
    private Long disruptionId;

    @Column(name = "route_id", nullable = false)
    private Long routeId;

    @Column(name = "provider_id", nullable = false)
    private Long providerId;

    @Column(name = "disruption_type", nullable = false)
    private String disruptionType;

    @Column(name = "severity", nullable = false)
    private String severity;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", nullable = false, length = 1000)
    private String description;

    @Column(name = "disruption_status", nullable = false)
    private String disruptionStatus;

    @Column(name = "start_date_time", nullable = false)
    private LocalDateTime startDateTime;

    @Column(name = "expected_end_date_time")
    private LocalDateTime expectedEndDateTime;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public Disruption() {
    }

    public Disruption(
            Long routeId,
            Long providerId,
            String disruptionType,
            String severity,
            String title,
            String description,
            String disruptionStatus,
            LocalDateTime startDateTime,
            LocalDateTime expectedEndDateTime,
            LocalDateTime createdAt) {

        this.routeId = routeId;
        this.providerId = providerId;
        this.disruptionType = disruptionType;
        this.severity = severity;
        this.title = title;
        this.description = description;
        this.disruptionStatus = disruptionStatus;
        this.startDateTime = startDateTime;
        this.expectedEndDateTime = expectedEndDateTime;
        this.createdAt = createdAt;
    }

    public Long getDisruptionId() {
        return disruptionId;
    }

    public void setDisruptionId(Long disruptionId) {
        this.disruptionId = disruptionId;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public Long getProviderId() {
        return providerId;
    }

    public void setProviderId(Long providerId) {
        this.providerId = providerId;
    }

    public String getDisruptionType() {
        return disruptionType;
    }

    public void setDisruptionType(String disruptionType) {
        this.disruptionType = disruptionType;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDisruptionStatus() {
        return disruptionStatus;
    }

    public void setDisruptionStatus(String disruptionStatus) {
        this.disruptionStatus = disruptionStatus;
    }

    public LocalDateTime getStartDateTime() {
        return startDateTime;
    }

    public void setStartDateTime(LocalDateTime startDateTime) {
        this.startDateTime = startDateTime;
    }

    public LocalDateTime getExpectedEndDateTime() {
        return expectedEndDateTime;
    }

    public void setExpectedEndDateTime(LocalDateTime expectedEndDateTime) {
        this.expectedEndDateTime = expectedEndDateTime;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
