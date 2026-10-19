package za.co.linkride.link_ride_api.dto;

public class NotificationPreferencesRequest {

    private boolean disruptionAlerts;
    private boolean journeyUpdates;
    private boolean ticketPaymentUpdates;
    private boolean generalNotifications;

    public NotificationPreferencesRequest() {
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
