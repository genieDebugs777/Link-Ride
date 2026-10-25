package za.co.linkride.link_ride_api.dto;

public class PaystackInitializeRequest {

    private Long journeyId;

    public PaystackInitializeRequest() {
    }

    public Long getJourneyId() {
        return journeyId;
    }

    public void setJourneyId(Long journeyId) {
        this.journeyId = journeyId;
    }
}
