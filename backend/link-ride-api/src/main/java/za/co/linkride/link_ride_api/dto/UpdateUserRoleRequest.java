package za.co.linkride.link_ride_api.dto;

import jakarta.validation.constraints.NotNull;
import za.co.linkride.link_ride_api.model.Role;

public class UpdateUserRoleRequest {

    @NotNull
    private Role role;

    public UpdateUserRoleRequest() {
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }
}
