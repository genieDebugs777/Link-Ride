package za.co.linkride.link_ride_api.dto;

public class PlanJourneyRequest {

    private Double originLatitude;
    private Double originLongitude;
    private Long destinationStopId;

    private String priority;

    private Boolean gautrainSelected;
    private Boolean metrorailSelected;
    private Boolean busSelected;
    private Boolean taxiSelected;

    private Boolean preferFewerTransfers;

    public PlanJourneyRequest() {
    }

    public PlanJourneyRequest(
            Double originLatitude,
            Double originLongitude,
            Long destinationStopId) {

        this.originLatitude = originLatitude;
        this.originLongitude = originLongitude;
        this.destinationStopId = destinationStopId;
    }

    public Double getOriginLatitude() {
        return originLatitude;
    }

    public void setOriginLatitude(Double originLatitude) {
        this.originLatitude = originLatitude;
    }

    public Double getOriginLongitude() {
        return originLongitude;
    }

    public void setOriginLongitude(Double originLongitude) {
        this.originLongitude = originLongitude;
    }

    public Long getDestinationStopId() {
        return destinationStopId;
    }

    public void setDestinationStopId(Long destinationStopId) {
        this.destinationStopId = destinationStopId;
    }

    public String getPriority() {
        return priority == null || priority.isBlank()
                ? "Balanced"
                : priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public boolean isGautrainSelected() {
        return gautrainSelected == null || gautrainSelected;
    }

    public void setGautrainSelected(Boolean gautrainSelected) {
        this.gautrainSelected = gautrainSelected;
    }

    public boolean isMetrorailSelected() {
        return metrorailSelected == null || metrorailSelected;
    }

    public void setMetrorailSelected(Boolean metrorailSelected) {
        this.metrorailSelected = metrorailSelected;
    }

    public boolean isBusSelected() {
        return busSelected == null || busSelected;
    }

    public void setBusSelected(Boolean busSelected) {
        this.busSelected = busSelected;
    }

    public boolean isTaxiSelected() {
        return taxiSelected == null || taxiSelected;
    }

    public void setTaxiSelected(Boolean taxiSelected) {
        this.taxiSelected = taxiSelected;
    }

    public boolean isPreferFewerTransfers() {
        return preferFewerTransfers != null
                && preferFewerTransfers;
    }

    public void setPreferFewerTransfers(Boolean preferFewerTransfers) {
        this.preferFewerTransfers = preferFewerTransfers;
    }
}
