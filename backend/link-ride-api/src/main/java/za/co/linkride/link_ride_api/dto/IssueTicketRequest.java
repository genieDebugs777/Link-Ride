package za.co.linkride.link_ride_api.dto;

public class IssueTicketRequest {

    private Long journeyId;

    public IssueTicketRequest() {
    }

    public Long getJourneyId() {
        return journeyId;
    }

    public void setJourneyId(
            Long journeyId) {

        this.journeyId = journeyId;
    }
}