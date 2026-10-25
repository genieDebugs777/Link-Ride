package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.model.FirebaseInstallation;
import za.co.linkride.link_ride_api.repository.FirebaseInstallationRepository;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class FirebaseInstallationService {

    private final FirebaseInstallationRepository repository;

    public FirebaseInstallationService(FirebaseInstallationRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public FirebaseInstallation register(Long userId, String fid) {
        validateUserId(userId);
        String normalized = normalizeFid(fid);
        LocalDateTime now = LocalDateTime.now();

        FirebaseInstallation installation =
                repository.findByFirebaseInstallationId(normalized).orElse(null);

        if (installation == null) {
            installation = new FirebaseInstallation(userId, normalized, now, now);
        } else {
            installation.setUserId(userId);
            installation.setUpdatedAt(now);
        }

        return repository.save(installation);
    }

    public List<FirebaseInstallation> getInstallationsForUser(Long userId) {
        validateUserId(userId);
        return repository.findByUserId(userId);
    }

    @Transactional
    public void unregister(Long userId, String fid) {
        validateUserId(userId);
        repository.deleteByUserIdAndFirebaseInstallationId(userId, normalizeFid(fid));
    }

    private String normalizeFid(String fid) {
        if (fid == null || fid.isBlank()) {
            throw new IllegalArgumentException("Firebase installation ID is required.");
        }
        String normalized = fid.trim();
        if (normalized.length() > 255) {
            throw new IllegalArgumentException("Firebase installation ID is invalid.");
        }
        return normalized;
    }

    private void validateUserId(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("Authenticated user ID is required.");
        }
    }
}
