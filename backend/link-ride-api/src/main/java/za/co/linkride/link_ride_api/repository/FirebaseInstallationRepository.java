package za.co.linkride.link_ride_api.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import za.co.linkride.link_ride_api.model.FirebaseInstallation;

import java.util.List;
import java.util.Optional;

public interface FirebaseInstallationRepository extends JpaRepository<FirebaseInstallation, Long> {
    Optional<FirebaseInstallation> findByFirebaseInstallationId(String firebaseInstallationId);
    List<FirebaseInstallation> findByUserId(Long userId);
    void deleteByUserIdAndFirebaseInstallationId(Long userId, String firebaseInstallationId);
}
