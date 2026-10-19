package za.co.linkride.link_ride_api.dto;

import java.util.ArrayList;
import java.util.List;

public class SelectJourneyRequest {

    private Integer totalDurationMinutes;

    private Double totalCost;

    private Integer transferCount;

    private List<JourneyLegOptionResponse> legs =
            new ArrayList<>();

    public SelectJourneyRequest() {
    }

    public SelectJourneyRequest(
            Integer totalDurationMinutes,
            Double totalCost,
            Integer transferCount,
            List<JourneyLegOptionResponse> legs) {

        this.totalDurationMinutes =
                totalDurationMinutes;

        this.totalCost =
                totalCost;

        this.transferCount =
                transferCount;

        this.legs =
                legs == null
                        ? new ArrayList<>()
                        : legs;
    }

    public Integer getTotalDurationMinutes() {
        return totalDurationMinutes;
    }

    public void setTotalDurationMinutes(
            Integer totalDurationMinutes) {

        this.totalDurationMinutes =
                totalDurationMinutes;
    }

    public Double getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(
            Double totalCost) {

        this.totalCost =
                totalCost;
    }

    public Integer getTransferCount() {
        return transferCount;
    }

    public void setTransferCount(
            Integer transferCount) {

        this.transferCount =
                transferCount;
    }

    public List<JourneyLegOptionResponse> getLegs() {
        return legs;
    }

    public void setLegs(
            List<JourneyLegOptionResponse> legs) {

        this.legs =
                legs == null
                        ? new ArrayList<>()
                        : legs;
    }
}