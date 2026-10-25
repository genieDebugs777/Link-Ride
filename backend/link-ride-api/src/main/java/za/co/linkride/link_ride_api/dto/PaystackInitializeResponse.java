package za.co.linkride.link_ride_api.dto;

public class PaystackInitializeResponse {

    private String authorizationUrl;
    private String accessCode;
    private String reference;
    private Long amount;
    private String currency;

    public PaystackInitializeResponse() {
    }

    public PaystackInitializeResponse(
            String authorizationUrl,
            String accessCode,
            String reference,
            Long amount,
            String currency) {

        this.authorizationUrl = authorizationUrl;
        this.accessCode = accessCode;
        this.reference = reference;
        this.amount = amount;
        this.currency = currency;
    }

    public String getAuthorizationUrl() {
        return authorizationUrl;
    }

    public void setAuthorizationUrl(String authorizationUrl) {
        this.authorizationUrl = authorizationUrl;
    }

    public String getAccessCode() {
        return accessCode;
    }

    public void setAccessCode(String accessCode) {
        this.accessCode = accessCode;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
    }

    public Long getAmount() {
        return amount;
    }

    public void setAmount(Long amount) {
        this.amount = amount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }
}
