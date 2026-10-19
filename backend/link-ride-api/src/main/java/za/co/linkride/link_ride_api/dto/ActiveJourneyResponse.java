package za.co.linkride.link_ride_api.dto;

import za.co.linkride.link_ride_api.model.Journey;
import za.co.linkride.link_ride_api.model.JourneyLeg;

import java.util.List;

public class ActiveJourneyResponse {

    private Journey journey;

    private List<JourneyLeg> legs;

    public ActiveJourneyResponse() {
    }

    public ActiveJourneyResponse(
            Journey journey,
            List<JourneyLeg> legs) {

        this.journey = journey;
        this.legs = legs;
    }

    public Journey getJourney() {
        return journey;
    }

    public void setJourney(
            Journey journey) {

        this.journey = journey;
    }

    public List<JourneyLeg> getLegs() {
        return legs;
    }

    public void setLegs(
            List<JourneyLeg> legs) {

        this.legs = legs;
    }
}