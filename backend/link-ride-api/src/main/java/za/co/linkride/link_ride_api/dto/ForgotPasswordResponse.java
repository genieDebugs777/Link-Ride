package za.co.linkride.link_ride_api.dto;

public class ForgotPasswordResponse {

    private String message;

    public ForgotPasswordResponse() {
    }

    public ForgotPasswordResponse(
            String message) {

        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(
            String message) {

        this.message = message;
    }
}
