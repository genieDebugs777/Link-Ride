package za.co.linkride.link_ride_api.controller;
import org.springframework.security.core.Authentication;
import za.co.linkride.link_ride_api.dto.ChangePasswordRequest;
import za.co.linkride.link_ride_api.dto.ForgotPasswordRequest;
import za.co.linkride.link_ride_api.dto.ForgotPasswordResponse;
import za.co.linkride.link_ride_api.dto.ResetPasswordRequest;
import org.springframework.http.ResponseEntity;
import jakarta.validation.Valid;
import za.co.linkride.link_ride_api.dto.RegistrationRequest;
import za.co.linkride.link_ride_api.dto.UserResponse;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.service.UserService;
import za.co.linkride.link_ride_api.service.PasswordResetService;
import za.co.linkride.link_ride_api.dto.LoginRequest;
import java.util.List;
import za.co.linkride.link_ride_api.dto.LoginResponse;
import za.co.linkride.link_ride_api.dto.UserUpdateRequest;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final PasswordResetService passwordResetService;

    public UserController(
            UserService userService,
            PasswordResetService passwordResetService) {

        this.userService = userService;
        this.passwordResetService =
                passwordResetService;
    }

    // REGISTER
    @PostMapping("/register")
    public ResponseEntity<UserResponse> registerUser(
            @Valid @RequestBody RegistrationRequest request) {

        UserResponse registeredUser = userService.registerUser(request);

        return ResponseEntity.ok(registeredUser);
    }

    // LOGIN
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> loginUser(
            @Valid @RequestBody LoginRequest request) {

        LoginResponse loginResponse = userService.loginUser(request);

        return ResponseEntity.ok(loginResponse);
    }

    // FORGOT PASSWORD - prototype reset code flow
    @PostMapping("/forgot-password")
    public ResponseEntity<ForgotPasswordResponse>
    forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request) {

        ForgotPasswordResponse response =
                passwordResetService
                        .requestReset(
                                request.getEmail()
                        );

        return ResponseEntity.ok(
                response
        );
    }

    // RESET PASSWORD - prototype code validation
    @PostMapping("/reset-password")
    public ResponseEntity<Void>
    resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {

        passwordResetService
                .resetPassword(
                        request.getEmail(),
                        request.getResetCode(),
                        request.getNewPassword()
                );

        return ResponseEntity
                .noContent()
                .build();
    }

    // READ - all users
    @GetMapping
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    // READ - user by ID
    @GetMapping("/{userId}")
    public ResponseEntity<UserResponse> getUserById(
            @PathVariable Long userId) {

        return userService.getUserById(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // UPDATE
    @PutMapping("/{userId}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long userId,
            @Valid @RequestBody UserUpdateRequest request) {

        try {
            UserResponse updatedUser =
                    userService.updateUser(userId, request);

            return ResponseEntity.ok(updatedUser);

        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // CHANGE PASSWORD
    @PutMapping("/password")
    public ResponseEntity<Void> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request) {

        Long authenticatedUserId =
                (Long) authentication.getDetails();

        userService.changePassword(
                authenticatedUserId,
                request
        );

        return ResponseEntity.noContent().build();
    }

    // DELETE
    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long userId) {

        try {
            userService.deleteUser(userId);
            return ResponseEntity.noContent().build();

        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}