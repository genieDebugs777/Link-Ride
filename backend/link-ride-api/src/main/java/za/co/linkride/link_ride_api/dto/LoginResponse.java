package za.co.linkride.link_ride_api.dto;

public class LoginResponse {

    private String token;
    private String tokenType;
    private UserResponse user;
    private boolean mfaRequired;

    public LoginResponse() {
    }

    public LoginResponse(
            String token,
            String tokenType,
            UserResponse user,
            boolean mfaRequired) {

        this.token = token;
        this.tokenType = tokenType;
        this.user = user;
        this.mfaRequired = mfaRequired;
    }

    public String getToken() {
        return token;
    }

    public void setToken(
            String token) {

        this.token = token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(
            String tokenType) {

        this.tokenType = tokenType;
    }

    public UserResponse getUser() {
        return user;
    }

    public void setUser(
            UserResponse user) {

        this.user = user;
    }

    public boolean isMfaRequired() {
        return mfaRequired;
    }

    public void setMfaRequired(
            boolean mfaRequired) {

        this.mfaRequired = mfaRequired;
    }
}
