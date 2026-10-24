package za.co.linkride.link_ride_api.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.dto.ForgotPasswordResponse;
import za.co.linkride.link_ride_api.model.PasswordResetToken;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.repository.PasswordResetTokenRepository;
import za.co.linkride.link_ride_api.repository.UserRepository;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.List;

@Service
public class PasswordResetService {

    private static final int RESET_CODE_BOUND =
            1_000_000;

    private static final int RESET_CODE_EXPIRY_MINUTES =
            15;

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository
            passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final SecureRandom secureRandom =
            new SecureRandom();

    public PasswordResetService(
            UserRepository userRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            PasswordEncoder passwordEncoder,
            EmailService emailService) {

        this.userRepository =
                userRepository;

        this.passwordResetTokenRepository =
                passwordResetTokenRepository;

        this.passwordEncoder =
                passwordEncoder;

        this.emailService =
                emailService;
    }

    @Transactional
    public ForgotPasswordResponse requestReset(
            String email) {

        final String genericMessage =
                "If that email is linked to a Link Ride account, reset instructions are available.";

        if (email == null ||
                email.isBlank()) {

            return new ForgotPasswordResponse(
                    genericMessage
            );
        }

        User user =
                userRepository
                        .findByEmail(
                                email.trim()
                        )
                        .orElse(null);

        if (user == null) {
            return new ForgotPasswordResponse(
                    genericMessage
            );
        }

        invalidatePreviousUnusedTokens(
                user.getUserId()
        );

        String resetCode =
                String.format(
                        "%06d",
                        secureRandom.nextInt(
                                RESET_CODE_BOUND
                        )
                );

        PasswordResetToken token =
                new PasswordResetToken(
                        user.getUserId(),
                        hashResetCode(
                                resetCode
                        ),
                        LocalDateTime.now()
                                .plusMinutes(
                                        RESET_CODE_EXPIRY_MINUTES
                                ),
                        false,
                        LocalDateTime.now()
                );

        passwordResetTokenRepository.save(
                token
        );
        emailService.sendPasswordResetCode(
                user.getEmail(),
                user.getFirstName(),
                resetCode
        );

        return new ForgotPasswordResponse(
                genericMessage
        );
    }

    @Transactional
    public void resetPassword(
            String email,
            String resetCode,
            String newPassword) {

        if (email == null ||
                email.isBlank()) {

            throw new IllegalArgumentException(
                    "Email is required."
            );
        }

        if (resetCode == null ||
                resetCode.isBlank()) {

            throw new IllegalArgumentException(
                    "Reset code is required."
            );
        }

        User user =
                userRepository
                        .findByEmail(
                                email.trim()
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Invalid or expired reset code."
                                        )
                        );

        String tokenHash =
                hashResetCode(
                        resetCode.trim()
                );

        PasswordResetToken token =
                passwordResetTokenRepository
                        .findByTokenHashAndUsedFalse(
                                tokenHash
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Invalid or expired reset code."
                                        )
                        );

        if (!user.getUserId()
                .equals(
                        token.getUserId()
                )) {

            throw new IllegalArgumentException(
                    "Invalid or expired reset code."
            );
        }

        if (token.getExpiresAt()
                .isBefore(
                        LocalDateTime.now()
                )) {

            token.setUsed(
                    true
            );

            passwordResetTokenRepository.save(
                    token
            );

            throw new IllegalArgumentException(
                    "Invalid or expired reset code."
            );
        }

        if (newPassword == null ||
                newPassword.length() < 8) {

            throw new IllegalArgumentException(
                    "New password must be at least 8 characters."
            );
        }

        if (passwordEncoder.matches(
                newPassword,
                user.getPasswordHash()
        )) {

            throw new IllegalArgumentException(
                    "New password must be different from your current password."
            );
        }

        user.setPasswordHash(
                passwordEncoder.encode(
                        newPassword
                )
        );

        userRepository.save(
                user
        );

        token.setUsed(
                true
        );

        passwordResetTokenRepository.save(
                token
        );

        invalidatePreviousUnusedTokens(
                user.getUserId()
        );

        emailService.sendPasswordChangedEmail(
                user.getEmail(),
                user.getFirstName()
        );
    }

    private void invalidatePreviousUnusedTokens(
            Long userId) {

        List<PasswordResetToken> tokens =
                passwordResetTokenRepository
                        .findByUserIdAndUsedFalse(
                                userId
                        );

        if (tokens.isEmpty()) {
            return;
        }

        for (PasswordResetToken token
                : tokens) {

            token.setUsed(
                    true
            );
        }

        passwordResetTokenRepository.saveAll(
                tokens
        );
    }

    private String hashResetCode(
            String resetCode) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance(
                            "SHA-256"
                    );

            byte[] hash =
                    digest.digest(
                            resetCode.getBytes(
                                    StandardCharsets.UTF_8
                            )
                    );

            return HexFormat.of()
                    .formatHex(
                            hash
                    );

        } catch (NoSuchAlgorithmException error) {
            throw new IllegalStateException(
                    "SHA-256 is unavailable.",
                    error
            );
        }
    }
}
