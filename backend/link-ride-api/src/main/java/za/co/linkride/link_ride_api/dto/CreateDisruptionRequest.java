package za.co.linkride.link_ride_api.dto;

import java.time.LocalDateTime;

public class CreateDisruptionRequest {

    private Long routeId;
    private String disruptionType;
    private String severity;
    private String title;
    private String description;
    private LocalDateTime startDateTime;
    private LocalDateTime expectedEndDateTime;

    public CreateDisruptionRequest() {
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
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
}
