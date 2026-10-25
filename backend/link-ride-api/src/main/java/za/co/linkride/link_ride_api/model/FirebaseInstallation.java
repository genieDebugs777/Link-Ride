package za.co.linkride.link_ride_api.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "firebase_installations",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_firebase_installations_fid",
                columnNames = "firebase_installation_id"
        )
)
public class FirebaseInstallation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "firebase_installation_record_id")
    private Long firebaseInstallationRecordId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "firebase_installation_id", nullable = false, length = 255)
    private String firebaseInstallationId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public FirebaseInstallation() {}

    public FirebaseInstallation(Long userId, String fid, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.userId = userId;
        this.firebaseInstallationId = fid;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getFirebaseInstallationRecordId() { return firebaseInstallationRecordId; }
    public void setFirebaseInstallationRecordId(Long value) { this.firebaseInstallationRecordId = value; }
    public Long getUserId() { return userId; }
    public void setUserId(Long value) { this.userId = value; }
    public String getFirebaseInstallationId() { return firebaseInstallationId; }
    public void setFirebaseInstallationId(String value) { this.firebaseInstallationId = value; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime value) { this.createdAt = value; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime value) { this.updatedAt = value; }
}
