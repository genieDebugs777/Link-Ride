package za.co.linkride.link_ride_api.dto;

public class ForgotPasswordResponse {

    private String message;
    private String developmentResetCode;

    public ForgotPasswordResponse() {
    }

    public ForgotPasswordResponse(
            String message,
            String developmentResetCode) {

        this.message = message;
        this.developmentResetCode =
                developmentResetCode;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(
            String message) {

        this.message = message;
    }

    public String getDevelopmentResetCode() {
        return developmentResetCode;
    }

    public void setDevelopmentResetCode(
            String developmentResetCode) {

        this.developmentResetCode =
                developmentResetCode;
    }
}
