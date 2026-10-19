package za.co.linkride.link_ride_api.event;

import java.time.LocalDateTime;

public class DisruptionEvent {

    private String eventType;
    private Long disruptionId;
    private Long routeId;
    private Long providerId;
    private String disruptionType;
    private String severity;
    private String title;
    private String description;
    private String disruptionStatus;
    private LocalDateTime occurredAt;

    public DisruptionEvent() {
    }

    public DisruptionEvent(
            String eventType,
            Long disruptionId,
            Long routeId,
            Long providerId,
            String disruptionType,
            String severity,
            String title,
            String description,
            String disruptionStatus,
            LocalDateTime occurredAt) {

        this.eventType = eventType;
        this.disruptionId = disruptionId;
        this.routeId = routeId;
        this.providerId = providerId;
        this.disruptionType = disruptionType;
        this.severity = severity;
        this.title = title;
        this.description = description;
        this.disruptionStatus = disruptionStatus;
        this.occurredAt = occurredAt;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
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

    public LocalDateTime getOccurredAt() {
        return occurredAt;
    }

    public void setOccurredAt(LocalDateTime occurredAt) {
        this.occurredAt = occurredAt;
    }
}
