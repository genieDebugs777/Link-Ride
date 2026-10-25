package za.co.linkride.link_ride_api.dto;

import za.co.linkride.link_ride_api.model.Payment;

public class PaystackVerifyResponse {

    private String gatewayStatus;
    private boolean paid;
    private Payment payment;

    public PaystackVerifyResponse() {
    }

    public PaystackVerifyResponse(
            String gatewayStatus,
            boolean paid,
            Payment payment) {

        this.gatewayStatus = gatewayStatus;
        this.paid = paid;
        this.payment = payment;
    }

    public String getGatewayStatus() {
        return gatewayStatus;
    }

    public void setGatewayStatus(String gatewayStatus) {
        this.gatewayStatus = gatewayStatus;
    }

    public boolean isPaid() {
        return paid;
    }

    public void setPaid(boolean paid) {
        this.paid = paid;
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }
}
