package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

@Entity
@Table(
        name = "notification_preferences",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_notification_preferences_user",
                        columnNames = "user_id"
                )
        }
)
public class NotificationPreference {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_preference_id")
    private Long notificationPreferenceId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "disruption_alerts", nullable = false)
    private boolean disruptionAlerts = true;

    @Column(name = "journey_updates", nullable = false)
    private boolean journeyUpdates = true;

    @Column(name = "ticket_payment_updates", nullable = false)
    private boolean ticketPaymentUpdates = true;

    @Column(name = "general_notifications", nullable = false)
    private boolean generalNotifications = false;

    public NotificationPreference() {
    }

    public NotificationPreference(Long userId) {
        this.userId = userId;
    }

    public Long getNotificationPreferenceId() {
        return notificationPreferenceId;
    }

    public void setNotificationPreferenceId(
            Long notificationPreferenceId) {
        this.notificationPreferenceId = notificationPreferenceId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public boolean isDisruptionAlerts() {
        return disruptionAlerts;
    }

    public void setDisruptionAlerts(boolean disruptionAlerts) {
        this.disruptionAlerts = disruptionAlerts;
    }

    public boolean isJourneyUpdates() {
        return journeyUpdates;
    }

    public void setJourneyUpdates(boolean journeyUpdates) {
        this.journeyUpdates = journeyUpdates;
    }

    public boolean isTicketPaymentUpdates() {
        return ticketPaymentUpdates;
    }

    public void setTicketPaymentUpdates(boolean ticketPaymentUpdates) {
        this.ticketPaymentUpdates = ticketPaymentUpdates;
    }

    public boolean isGeneralNotifications() {
        return generalNotifications;
    }

    public void setGeneralNotifications(boolean generalNotifications) {
        this.generalNotifications = generalNotifications;
    }
}
