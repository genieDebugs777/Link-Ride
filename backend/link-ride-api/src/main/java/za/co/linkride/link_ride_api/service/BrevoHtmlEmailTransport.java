package za.co.linkride.link_ride_api.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import java.time.Duration;

import java.util.List;
import java.util.Map;

@Service
@Profile("prod")
public class BrevoHtmlEmailTransport implements HtmlEmailTransport {
    private final RestClient client;
    private final String fromAddress;
    private final String fromName;

    public BrevoHtmlEmailTransport(@Value("${BREVO_API_KEY}") String apiKey,
                                   @Value("${linkride.mail.from}") String fromAddress,
                                   @Value("${linkride.mail.from-name:Link Ride}") String fromName) {
        if (apiKey.isBlank()) {
            throw new IllegalArgumentException("BREVO_API_KEY is required in production.");
        }
        SimpleClientHttpRequestFactory requestFactory =
                new SimpleClientHttpRequestFactory();

        requestFactory.setConnectTimeout(Duration.ofSeconds(5));
        requestFactory.setReadTimeout(Duration.ofSeconds(15));

        this.client = RestClient.builder()
                .baseUrl("https://api.brevo.com")
                .defaultHeader("api-key", apiKey)
                .requestFactory(requestFactory)
                .build();
        this.fromAddress = fromAddress;
        this.fromName = fromName;
    }

    @Override
    public void send(String recipientEmail, String subject, String htmlBody) {
        Map<String, Object> message = Map.of(
                "sender", Map.of("email", fromAddress, "name", fromName),
                "to", List.of(Map.of("email", recipientEmail)),
                "subject", subject,
                "htmlContent", htmlBody
        );
        try {
            ResponseEntity<Void> result = client.post()
                    .uri("/v3/smtp/email")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(message)
                    .retrieve()
                    .toBodilessEntity();
            if (result.getStatusCode().value() != 201) {
                throw new IllegalStateException("Brevo did not accept Link Ride email.");
            }
        } catch (RestClientException error) {
            // Do not log the API key, one-time code, recipient, or response body.
            throw new IllegalStateException("Brevo email request failed; check the provider dashboard.");
        }
    }
}
