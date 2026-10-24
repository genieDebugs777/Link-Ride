package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.model.MfaCode;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.repository.MfaCodeRepository;
import za.co.linkride.link_ride_api.repository.UserRepository;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.List;

@Service
public class MfaService {

    private static final int MFA_CODE_BOUND =
            1_000_000;

    private static final int MFA_CODE_EXPIRY_MINUTES =
            10;

    private static final int MAX_FAILED_ATTEMPTS =
            5;

    private final UserRepository userRepository;
    private final MfaCodeRepository mfaCodeRepository;
    private final MfaMailService mfaMailService;

    private final SecureRandom secureRandom =
            new SecureRandom();

    public MfaService(
            UserRepository userRepository,
            MfaCodeRepository mfaCodeRepository,
            MfaMailService mfaMailService) {

        this.userRepository =
                userRepository;

        this.mfaCodeRepository =
                mfaCodeRepository;

        this.mfaMailService =
                mfaMailService;
    }

    @Transactional
    public void sendChallenge(
            User user) {

        invalidatePreviousUnusedCodes(
                user.getUserId()
        );

        String code =
                String.format(
                        "%06d",
                        secureRandom.nextInt(
                                MFA_CODE_BOUND
                        )
                );

        MfaCode mfaCode =
                new MfaCode(
                        user.getUserId(),
                        hashCodeValue(
                                code
                        ),
                        LocalDateTime.now()
                                .plusMinutes(
                                        MFA_CODE_EXPIRY_MINUTES
                                ),
                        false,
                        0,
                        LocalDateTime.now()
                );

        mfaCodeRepository.save(
                mfaCode
        );

        mfaMailService.sendMfaCode(
                user.getEmail(),
                user.getFirstName(),
                code
        );
    }

    @Transactional
    public User verifyChallenge(
            String email,
            String code) {

        if (email == null ||
                email.isBlank()) {

            throw new IllegalArgumentException(
                    "Email is required."
            );
        }

        if (code == null ||
                code.isBlank()) {

            throw new IllegalArgumentException(
                    "MFA code is required."
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
                                                "Invalid or expired MFA code."
                                        )
                        );

        MfaCode mfaCode =
                mfaCodeRepository
                        .findTopByUserIdAndUsedFalseOrderByCreatedAtDesc(
                                user.getUserId()
                        )
                        .orElseThrow(
                                () ->
                                        new IllegalArgumentException(
                                                "Invalid or expired MFA code."
                                        )
                        );

        if (mfaCode.getExpiresAt()
                .isBefore(
                        LocalDateTime.now()
                )) {

            mfaCode.setUsed(
                    true
            );

            mfaCodeRepository.save(
                    mfaCode
            );

            throw new IllegalArgumentException(
                    "Invalid or expired MFA code."
            );
        }

        if (mfaCode.getFailedAttempts() >=
                MAX_FAILED_ATTEMPTS) {

            mfaCode.setUsed(
                    true
            );

            mfaCodeRepository.save(
                    mfaCode
            );

            throw new IllegalArgumentException(
                    "Invalid or expired MFA code."
            );
        }

        String submittedHash =
                hashCodeValue(
                        code.trim()
                );

        boolean matches =
                MessageDigest.isEqual(
                        mfaCode.getCodeHash()
                                .getBytes(
                                        StandardCharsets.UTF_8
                                ),
                        submittedHash.getBytes(
                                StandardCharsets.UTF_8
                        )
                );

        if (!matches) {

            mfaCode.setFailedAttempts(
                    mfaCode.getFailedAttempts() + 1
            );

            if (mfaCode.getFailedAttempts() >=
                    MAX_FAILED_ATTEMPTS) {

                mfaCode.setUsed(
                        true
                );
            }

            mfaCodeRepository.save(
                    mfaCode
            );

            throw new IllegalArgumentException(
                    "Invalid or expired MFA code."
            );
        }

        mfaCode.setUsed(
                true
        );

        mfaCodeRepository.save(
                mfaCode
        );

        invalidatePreviousUnusedCodes(
                user.getUserId()
        );

        return user;
    }

    @Transactional
    public void resendChallenge(
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

        if (user == null ||
                !"ACTIVE".equalsIgnoreCase(
                        user.getAccountStatus()
                )) {

            return;
        }

        // Resend is only allowed when the password-authenticated login
        // flow has already created an active MFA challenge.
        MfaCode existingChallenge =
                mfaCodeRepository
                        .findTopByUserIdAndUsedFalseOrderByCreatedAtDesc(
                                user.getUserId()
                        )
                        .orElse(null);

        if (existingChallenge == null ||
                existingChallenge.getExpiresAt()
                        .isBefore(
                                LocalDateTime.now()
                        )) {

            return;
        }

        sendChallenge(
                user
        );
    }

    private void invalidatePreviousUnusedCodes(
            Long userId) {

        List<MfaCode> codes =
                mfaCodeRepository
                        .findByUserIdAndUsedFalse(
                                userId
                        );

        if (codes.isEmpty()) {
            return;
        }

        for (MfaCode code : codes) {
            code.setUsed(
                    true
            );
        }

        mfaCodeRepository.saveAll(
                codes
        );
    }

    private String hashCodeValue(
            String code) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance(
                            "SHA-256"
                    );

            byte[] hash =
                    digest.digest(
                            code.getBytes(
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
