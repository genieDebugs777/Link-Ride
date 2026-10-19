package za.co.linkride.link_ride_api.dto;

public class ProcessPaymentRequest {

    private Long journeyId;
    private String paymentMethod;

    public ProcessPaymentRequest() {
    }

    public Long getJourneyId() {
        return journeyId;
    }

    public void setJourneyId(Long journeyId) {
        this.journeyId = journeyId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(
            String paymentMethod) {

        this.paymentMethod =
                paymentMethod;
    }
}