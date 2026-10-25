package za.co.linkride.link_ride_api.service;

public interface HtmlEmailTransport {
    void send(String recipientEmail, String subject, String htmlBody);
}
