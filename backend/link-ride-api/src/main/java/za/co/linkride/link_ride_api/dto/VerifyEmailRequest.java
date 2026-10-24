package za.co.linkride.link_ride_api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class VerifyEmailRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Enter a valid email address")
    private String email;

    @NotBlank(message = "Verification code is required")
    @Pattern(
            regexp = "^\\d{6}$",
            message = "Verification code must contain 6 digits"
    )
    private String verificationCode;

    public VerifyEmailRequest() {
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(
            String email) {

        this.email = email;
    }

    public String getVerificationCode() {
        return verificationCode;
    }

    public void setVerificationCode(
            String verificationCode) {

        this.verificationCode =
                verificationCode;
    }
}