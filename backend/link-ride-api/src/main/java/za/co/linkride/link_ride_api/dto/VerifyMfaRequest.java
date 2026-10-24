package za.co.linkride.link_ride_api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class VerifyMfaRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Enter a valid email address")
    private String email;

    @NotBlank(message = "MFA code is required")
    @Pattern(
            regexp = "^\\d{6}$",
            message = "MFA code must contain 6 digits"
    )
    private String code;

    public VerifyMfaRequest() {
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(
            String email) {

        this.email = email;
    }

    public String getCode() {
        return code;
    }

    public void setCode(
            String code) {

        this.code = code;
    }
}
