package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.dto.LoginResponse;
import za.co.linkride.link_ride_api.dto.RegistrationRequest;
import za.co.linkride.link_ride_api.dto.UserResponse;
import za.co.linkride.link_ride_api.exception.DuplicateEmailException;
import java.time.LocalDateTime;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.model.Role;
import za.co.linkride.link_ride_api.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import za.co.linkride.link_ride_api.dto.LoginRequest;
import java.util.List;
import java.util.Optional;
import za.co.linkride.link_ride_api.exception.InvalidCredentialsException;
import za.co.linkride.link_ride_api.dto.UserUpdateRequest;
import za.co.linkride.link_ride_api.dto.ChangePasswordRequest;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailVerificationService emailVerificationService;
    private final MfaService mfaService;

    public UserService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            EmailVerificationService emailVerificationService,
            MfaService mfaService) {

        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailVerificationService = emailVerificationService;
        this.mfaService = mfaService;
    }

    // REGISTER USER
    public UserResponse registerUser(RegistrationRequest request) {

        // Prevent duplicate email addresses
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new DuplicateEmailException(
                    "An account with this email already exists"
            );
        }

        // Create the database entity
        User user = new User();

        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());

        // Hash the plain password before storing it
        String hashedPassword =
                passwordEncoder.encode(request.getPassword());

        user.setPasswordHash(hashedPassword);

        // These values are controlled by the backend
        user.setCreatedAt(LocalDateTime.now());
        user.setAccountStatus("PENDING_VERIFICATION");
        user.setRole(Role.COMMUTER);

        // Save to PostgreSQL before creating the verification token
        User savedUser = userRepository.save(user);

        // Send a one-time verification code to the registered email address
        emailVerificationService.sendVerificationCode(savedUser);

        // Return safe user information only
        return new UserResponse(
                savedUser.getUserId(),
                savedUser.getFirstName(),
                savedUser.getLastName(),
                savedUser.getEmail(),
                savedUser.getPhoneNumber(),
                savedUser.getCreatedAt(),
                savedUser.getAccountStatus(),
                savedUser.getRole().name()
        );
    }

    // LOGIN USER
    public LoginResponse loginUser(LoginRequest request) {

        // Find the user by email
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() ->
                        new InvalidCredentialsException(
                                "Invalid email or password"
                        )
                );

        // Compare the plain password with the stored BCrypt hash
        boolean passwordMatches = passwordEncoder.matches(
                request.getPassword(),
                user.getPasswordHash()
        );

        if (!passwordMatches) {
            throw new InvalidCredentialsException(
                    "Invalid email or password"
            );
        }

        if (!"ACTIVE".equalsIgnoreCase(user.getAccountStatus())) {
            throw new InvalidCredentialsException(
                    "Please verify your email before signing in."
            );
        }

        UserResponse userResponse = new UserResponse(
                user.getUserId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getPhoneNumber(),
                user.getCreatedAt(),
                user.getAccountStatus(),
                user.getRole().name()
        );

        // Password authentication is only the first factor.
        // A JWT is issued only after the emailed MFA code is verified.
        mfaService.sendChallenge(
                user
        );

        return new LoginResponse(
                null,
                null,
                userResponse,
                true
        );
    }

    // COMPLETE MFA LOGIN
    public LoginResponse verifyMfa(
            String email,
            String code) {

        User user =
                mfaService.verifyChallenge(
                        email,
                        code
                );

        UserResponse userResponse =
                new UserResponse(
                        user.getUserId(),
                        user.getFirstName(),
                        user.getLastName(),
                        user.getEmail(),
                        user.getPhoneNumber(),
                        user.getCreatedAt(),
                        user.getAccountStatus(),
                        user.getRole().name()
                );

        String token =
                jwtService.generateToken(
                        user.getUserId(),
                        user.getEmail(),
                        user.getRole()
                );

        return new LoginResponse(
                token,
                "Bearer",
                userResponse,
                false
        );
    }

    // READ - all users
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll()
                .stream()
                .map(this::toUserResponse)
                .toList();
    }

    // READ - user by ID
    public Optional<UserResponse> getUserById(Long userId) {
        return userRepository.findById(userId)
                .map(this::toUserResponse);
    }

    // UPDATE
    public UserResponse updateUser(
            Long userId,
            UserUpdateRequest request) {

        User existingUser = userRepository.findById(userId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "User not found with ID: " + userId
                        )
                );

        existingUser.setFirstName(request.getFirstName());
        existingUser.setLastName(request.getLastName());
        existingUser.setEmail(request.getEmail());
        existingUser.setPhoneNumber(request.getPhoneNumber());

        User savedUser = userRepository.save(existingUser);

        return new UserResponse(
                savedUser.getUserId(),
                savedUser.getFirstName(),
                savedUser.getLastName(),
                savedUser.getEmail(),
                savedUser.getPhoneNumber(),
                savedUser.getCreatedAt(),
                savedUser.getAccountStatus(),
                savedUser.getRole().name()
        );
    }


    // ADMIN - UPDATE USER ROLE
    public UserResponse updateUserRole(
            Long userId,
            Role role) {

        User existingUser = userRepository.findById(userId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "User not found with ID: " + userId
                        )
                );

        if (existingUser.getRole() == Role.ADMIN) {
            throw new IllegalArgumentException(
                    "ADMIN accounts cannot be changed through operator management"
            );
        }

        if (role != Role.COMMUTER &&
                role != Role.OPERATOR) {
            throw new IllegalArgumentException(
                    "Operator management only supports COMMUTER and OPERATOR roles"
            );
        }

        existingUser.setRole(role);

        User savedUser =
                userRepository.save(existingUser);

        return toUserResponse(savedUser);
    }

    // DELETE
    public void deleteUser(Long userId) {

        if (!userRepository.existsById(userId)) {
            throw new RuntimeException("User not found with ID: " + userId);
        }

        userRepository.deleteById(userId);
    }

    // CHANGE PASSWORD
    public void changePassword(
            Long userId,
            ChangePasswordRequest request) {

        // Find the authenticated user's account
        User user = userRepository.findById(userId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "User not found with ID: " + userId
                        )
                );

        // Verify that the supplied current password is correct
        boolean currentPasswordMatches =
                passwordEncoder.matches(
                        request.getCurrentPassword(),
                        user.getPasswordHash()
                );

        if (!currentPasswordMatches) {
            throw new InvalidCredentialsException(
                    "Current password is incorrect"
            );
        }

        // Prevent the user from reusing their current password
        boolean sameAsCurrentPassword =
                passwordEncoder.matches(
                        request.getNewPassword(),
                        user.getPasswordHash()
                );

        if (sameAsCurrentPassword) {
            throw new IllegalArgumentException(
                    "New password must be different from current password"
            );
        }

        // Hash the new password before storing it
        String newPasswordHash =
                passwordEncoder.encode(
                        request.getNewPassword()
                );

        user.setPasswordHash(newPasswordHash);

        // Persist only the BCrypt hash
        userRepository.save(user);
    }


    private UserResponse toUserResponse(User user) {

        return new UserResponse(
                user.getUserId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getPhoneNumber(),
                user.getCreatedAt(),
                user.getAccountStatus(),
                user.getRole().name()
        );
    }
}