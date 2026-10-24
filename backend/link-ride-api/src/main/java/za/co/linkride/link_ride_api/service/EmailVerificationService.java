package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.model.EmailVerificationToken;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.repository.EmailVerificationTokenRepository;
import za.co.linkride.link_ride_api.repository.UserRepository;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.List;

@Service
public class EmailVerificationService {

    private static final int VERIFICATION_CODE_BOUND =
            1_000_000;

    private static final int VERIFICATION_CODE_EXPIRY_MINUTES =
            15;

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository
            emailVerificationTokenRepository;
    private final EmailService emailService;

    private final SecureRandom secureRandom =
            new SecureRandom();

    public EmailVerificationService(
            UserRepository userRepository,
            EmailVerificationTokenRepository emailVerificationTokenRepository,
            EmailService emailService) {

        this.userRepository =
                userRepository;

        this.emailVerificationTokenRepository =
                emailVerificationTokenRepository;

        this.emailService =
                emailService;
    }

    @Transactional
    public void sendVerificationCode(
            User user) {

        invalidatePreviousUnusedTokens(
                user.getUserId()
        );

        String verificationCode =
                String.format(
                        "%06d",
                        secureRandom.nextInt(
                                VERIFICATION_CODE_BOUND
                        )
                );

        EmailVerificationToken token =
                new EmailVerificationToken(
                        user.getUserId(),
                        hashVerificationCode(
                                verificationCode
                        ),
                        LocalDateTime.now()
                                .plusMinutes(
                                        VERIFICATION_CODE_EXPIRY_MINUTES
                                ),
                        false,
                        LocalDateTime.now()
                );

        emailVerificationTokenRepository.save(
                token
        );

        emailService.sendVerificationCode(
                user.getEmail(),
                user.getFirstName(),
                verificationCode
        );
    }

    @Transactional
    public void verifyEmail(
            String email,
            String verificationCode) {

        if (email == null ||
                email.isBlank()) {

            throw new IllegalArgumentException(
                    "Email is required."
            );
        }

        if (verificationCode == null ||
                verificationCode.isBlank()) {

            throw new IllegalArgumentException(
                    "Verification code is required."
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
                                                "Invalid or expired verification code."
                                        )
                        );

        if ("ACTIVE".equalsIgnoreCase(
                user.getAccountStatus()
        )) {

            return;
        }

        String tokenHash =
                hashVerificationCode(
                        verificationCode.trim()
                );

        EmailVerificationToken token =
                emailVerificationTokenRepository
                        .findByTokenHashAndUsedFalse(
                                tokenHash
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Invalid or expired verification code."
                                        )
                        );

        if (!user.getUserId()
                .equals(
                        token.getUserId()
                )) {

            throw new IllegalArgumentException(
                    "Invalid or expired verification code."
            );
        }

        if (token.getExpiresAt()
                .isBefore(
                        LocalDateTime.now()
                )) {

            token.setUsed(
                    true
            );

            emailVerificationTokenRepository.save(
                    token
            );

            throw new IllegalArgumentException(
                    "Invalid or expired verification code."
            );
        }

        token.setUsed(
                true
        );

        emailVerificationTokenRepository.save(
                token
        );

        user.setAccountStatus(
                "ACTIVE"
        );

        userRepository.save(
                user
        );

        invalidatePreviousUnusedTokens(
                user.getUserId()
        );

        emailService.sendWelcomeEmail(
                user.getEmail(),
                user.getFirstName()
        );
    }

    @Transactional
    public void resendVerificationCode(
            String email) {

        if (email == null ||
                email.isBlank()) {

            return;
        }

        User user =
                userRepository
                        .findByEmail(
                                email.trim()
                        )
                        .orElse(null);

        if (user == null) {
            return;
        }

        if ("ACTIVE".equalsIgnoreCase(
                user.getAccountStatus()
        )) {

            return;
        }

        sendVerificationCode(
                user
        );
    }

    private void invalidatePreviousUnusedTokens(
            Long userId) {

        List<EmailVerificationToken> tokens =
                emailVerificationTokenRepository
                        .findByUserIdAndUsedFalse(
                                userId
                        );

        if (tokens.isEmpty()) {
            return;
        }

        for (EmailVerificationToken token
                : tokens) {

            token.setUsed(
                    true
            );
        }

        emailVerificationTokenRepository.saveAll(
                tokens
        );
    }

    private String hashVerificationCode(
            String verificationCode) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance(
                            "SHA-256"
                    );

            byte[] hash =
                    digest.digest(
                            verificationCode.getBytes(
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