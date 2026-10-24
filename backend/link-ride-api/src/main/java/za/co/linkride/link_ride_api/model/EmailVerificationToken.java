package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "email_verification_tokens",
        indexes = {
                @Index(
                        name = "idx_email_verification_token_hash",
                        columnList = "token_hash"
                ),
                @Index(
                        name = "idx_email_verification_user_id",
                        columnList = "user_id"
                )
        }
)
public class EmailVerificationToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "email_verification_token_id")
    private Long emailVerificationTokenId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(
            name = "token_hash",
            nullable = false,
            unique = true,
            length = 64
    )
    private String tokenHash;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "used", nullable = false)
    private boolean used;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public EmailVerificationToken() {
    }

    public EmailVerificationToken(
            Long userId,
            String tokenHash,
            LocalDateTime expiresAt,
            boolean used,
            LocalDateTime createdAt) {

        this.userId = userId;
        this.tokenHash = tokenHash;
        this.expiresAt = expiresAt;
        this.used = used;
        this.createdAt = createdAt;
    }

    public Long getEmailVerificationTokenId() {
        return emailVerificationTokenId;
    }

    public void setEmailVerificationTokenId(
            Long emailVerificationTokenId) {

        this.emailVerificationTokenId =
                emailVerificationTokenId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(
            Long userId) {

        this.userId = userId;
    }

    public String getTokenHash() {
        return tokenHash;
    }

    public void setTokenHash(
            String tokenHash) {

        this.tokenHash = tokenHash;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(
            LocalDateTime expiresAt) {

        this.expiresAt = expiresAt;
    }

    public boolean isUsed() {
        return used;
    }

    public void setUsed(
            boolean used) {

        this.used = used;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(
            LocalDateTime createdAt) {

        this.createdAt = createdAt;
    }
}