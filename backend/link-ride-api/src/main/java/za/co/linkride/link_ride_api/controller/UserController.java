package za.co.linkride.link_ride_api.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import za.co.linkride.link_ride_api.dto.ChangePasswordRequest;
import za.co.linkride.link_ride_api.dto.ForgotPasswordRequest;
import za.co.linkride.link_ride_api.dto.ForgotPasswordResponse;
import za.co.linkride.link_ride_api.dto.LoginRequest;
import za.co.linkride.link_ride_api.dto.LoginResponse;
import za.co.linkride.link_ride_api.dto.RegistrationRequest;
import za.co.linkride.link_ride_api.dto.ResendMfaRequest;
import za.co.linkride.link_ride_api.dto.ResendVerificationRequest;
import za.co.linkride.link_ride_api.dto.ResetPasswordRequest;
import za.co.linkride.link_ride_api.dto.UserResponse;
import za.co.linkride.link_ride_api.dto.UserUpdateRequest;
import za.co.linkride.link_ride_api.dto.VerifyEmailRequest;
import za.co.linkride.link_ride_api.dto.VerifyMfaRequest;
import za.co.linkride.link_ride_api.service.EmailVerificationService;
import za.co.linkride.link_ride_api.service.MfaService;
import za.co.linkride.link_ride_api.service.PasswordResetService;
import za.co.linkride.link_ride_api.service.UserService;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final PasswordResetService passwordResetService;
    private final EmailVerificationService emailVerificationService;
    private final MfaService mfaService;

    public UserController(
            UserService userService,
            PasswordResetService passwordResetService,
            EmailVerificationService emailVerificationService,
            MfaService mfaService) {

        this.userService = userService;
        this.passwordResetService =
                passwordResetService;
        this.emailVerificationService =
                emailVerificationService;
        this.mfaService =
                mfaService;
    }

    // REGISTER
    @PostMapping("/register")
    public ResponseEntity<UserResponse> registerUser(
            @Valid @RequestBody RegistrationRequest request) {

        UserResponse registeredUser =
                userService.registerUser(
                        request
                );

        return ResponseEntity.ok(
                registeredUser
        );
    }

    // VERIFY EMAIL
    @PostMapping("/verify-email")
    public ResponseEntity<Void> verifyEmail(
            @Valid @RequestBody VerifyEmailRequest request) {

        emailVerificationService.verifyEmail(
                request.getEmail(),
                request.getVerificationCode()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    // RESEND VERIFICATION CODE
    @PostMapping("/resend-verification")
    public ResponseEntity<Void> resendVerificationCode(
            @Valid @RequestBody ResendVerificationRequest request) {

        emailVerificationService.resendVerificationCode(
                request.getEmail()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    // LOGIN
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> loginUser(
            @Valid @RequestBody LoginRequest request) {

        LoginResponse loginResponse =
                userService.loginUser(
                        request
                );

        return ResponseEntity.ok(
                loginResponse
        );
    }

    // VERIFY MFA AND ISSUE JWT
    @PostMapping("/verify-mfa")
    public ResponseEntity<LoginResponse> verifyMfa(
            @Valid @RequestBody VerifyMfaRequest request) {

        LoginResponse loginResponse =
                userService.verifyMfa(
                        request.getEmail(),
                        request.getCode()
                );

        return ResponseEntity.ok(
                loginResponse
        );
    }

    // RESEND MFA CODE
    @PostMapping("/resend-mfa")
    public ResponseEntity<Void> resendMfa(
            @Valid @RequestBody ResendMfaRequest request) {

        mfaService.resendChallenge(
                request.getEmail()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    // FORGOT PASSWORD
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

    // RESET PASSWORD
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

    // ADMIN - READ ALL USERS
    @GetMapping
    public ResponseEntity<List<UserResponse>>
    getAllUsers() {

        return ResponseEntity.ok(
                userService.getAllUsers()
        );
    }

    // SELF OR ADMIN - READ USER
    @GetMapping("/{userId}")
    public ResponseEntity<UserResponse> getUserById(
            @PathVariable Long userId,
            Authentication authentication) {

        if (!isSelfOrAdmin(
                authentication,
                userId
        )) {

            return ResponseEntity
                    .status(
                            HttpStatus.FORBIDDEN
                    )
                    .build();
        }

        return userService
                .getUserById(
                        userId
                )
                .map(
                        ResponseEntity::ok
                )
                .orElse(
                        ResponseEntity
                                .notFound()
                                .build()
                );
    }

    // SELF OR ADMIN - UPDATE USER
    @PutMapping("/{userId}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long userId,
            @Valid @RequestBody UserUpdateRequest request,
            Authentication authentication) {

        if (!isSelfOrAdmin(
                authentication,
                userId
        )) {

            return ResponseEntity
                    .status(
                            HttpStatus.FORBIDDEN
                    )
                    .build();
        }

        try {
            UserResponse updatedUser =
                    userService.updateUser(
                            userId,
                            request
                    );

            return ResponseEntity.ok(
                    updatedUser
            );

        } catch (RuntimeException error) {

            return ResponseEntity
                    .notFound()
                    .build();
        }
    }

    // SELF - CHANGE PASSWORD
    @PutMapping("/password")
    public ResponseEntity<Void> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request) {

        Long authenticatedUserId =
                authenticatedUserId(
                        authentication
                );

        if (authenticatedUserId == null) {

            return ResponseEntity
                    .status(
                            HttpStatus.UNAUTHORIZED
                    )
                    .build();
        }

        userService.changePassword(
                authenticatedUserId,
                request
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    // ADMIN - DELETE USER
    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> deleteUser(
            @PathVariable Long userId) {

        try {
            userService.deleteUser(
                    userId
            );

            return ResponseEntity
                    .noContent()
                    .build();

        } catch (RuntimeException error) {

            return ResponseEntity
                    .notFound()
                    .build();
        }
    }

    private boolean isSelfOrAdmin(
            Authentication authentication,
            Long requestedUserId) {

        if (authentication == null ||
                !authentication.isAuthenticated()) {

            return false;
        }

        if (hasRole(
                authentication,
                "ROLE_ADMIN"
        )) {

            return true;
        }

        Long authenticatedUserId =
                authenticatedUserId(
                        authentication
                );

        return authenticatedUserId != null &&
                authenticatedUserId.equals(
                        requestedUserId
                );
    }

    private Long authenticatedUserId(
            Authentication authentication) {

        if (authentication == null) {
            return null;
        }

        Object details =
                authentication.getDetails();

        if (details instanceof Long userId) {
            return userId;
        }

        return null;
    }

    private boolean hasRole(
            Authentication authentication,
            String role) {

        if (authentication == null) {
            return false;
        }

        return authentication
                .getAuthorities()
                .stream()
                .anyMatch(
                        authority ->
                                role.equals(
                                        authority.getAuthority()
                                )
                );
    }
}
