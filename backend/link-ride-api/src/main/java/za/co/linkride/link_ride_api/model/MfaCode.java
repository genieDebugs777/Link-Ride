package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "mfa_codes",
        indexes = {
                @Index(
                        name = "idx_mfa_user_id",
                        columnList = "user_id"
                ),
                @Index(
                        name = "idx_mfa_created_at",
                        columnList = "created_at"
                )
        }
)
public class MfaCode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mfa_code_id")
    private Long mfaCodeId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(
            name = "code_hash",
            nullable = false,
            length = 64
    )
    private String codeHash;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "used", nullable = false)
    private boolean used;

    @Column(name = "failed_attempts", nullable = false)
    private int failedAttempts;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public MfaCode() {
    }

    public MfaCode(
            Long userId,
            String codeHash,
            LocalDateTime expiresAt,
            boolean used,
            int failedAttempts,
            LocalDateTime createdAt) {

        this.userId = userId;
        this.codeHash = codeHash;
        this.expiresAt = expiresAt;
        this.used = used;
        this.failedAttempts = failedAttempts;
        this.createdAt = createdAt;
    }

    public Long getMfaCodeId() {
        return mfaCodeId;
    }

    public void setMfaCodeId(
            Long mfaCodeId) {

        this.mfaCodeId = mfaCodeId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(
            Long userId) {

        this.userId = userId;
    }

    public String getCodeHash() {
        return codeHash;
    }

    public void setCodeHash(
            String codeHash) {

        this.codeHash = codeHash;
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

    public int getFailedAttempts() {
        return failedAttempts;
    }

    public void setFailedAttempts(
            int failedAttempts) {

        this.failedAttempts = failedAttempts;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(
            LocalDateTime createdAt) {

        this.createdAt = createdAt;
    }
}
