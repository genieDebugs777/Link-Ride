package za.co.linkride.link_ride_api.dto;

import java.time.LocalDateTime;

public class UserResponse {

    private Long userId;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private LocalDateTime createdAt;
    private String accountStatus;
    private String role;

    public UserResponse() {
    }

    // Kept for compatibility with any existing callers.
    public UserResponse(
            Long userId,
            String firstName,
            String lastName,
            String email,
            String phoneNumber,
            LocalDateTime createdAt,
            String accountStatus) {

        this(
                userId,
                firstName,
                lastName,
                email,
                phoneNumber,
                createdAt,
                accountStatus,
                "COMMUTER"
        );
    }

    public UserResponse(
            Long userId,
            String firstName,
            String lastName,
            String email,
            String phoneNumber,
            LocalDateTime createdAt,
            String accountStatus,
            String role) {

        this.userId = userId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.createdAt = createdAt;
        this.accountStatus = accountStatus;
        this.role = role;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
