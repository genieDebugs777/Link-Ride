package za.co.linkride.link_ride_api.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import za.co.linkride.link_ride_api.model.FirebaseInstallation;
import za.co.linkride.link_ride_api.repository.FirebaseInstallationRepository;

import java.util.List;

/** Best-effort push delivery. The database notification is authoritative. */
@Service
public class FirebasePushNotificationService {

    private static final Logger log = LoggerFactory.getLogger(FirebasePushNotificationService.class);

    private final FirebaseInstallationRepository installationRepository;
    private final FirebaseMessaging firebaseMessaging;

    public FirebasePushNotificationService(
            FirebaseInstallationRepository installationRepository,
            FirebaseApp firebaseApp) {
        this.installationRepository = installationRepository;
        this.firebaseMessaging = FirebaseMessaging.getInstance(firebaseApp);
    }

    /** Called after the in-app notification transaction has committed. */
    public void sendDisruptionNotification(
            Long userId,
            Long disruptionId,
            Long routeId,
            String type,
            String severity,
            String title,
            String body) {
        if (userId == null) {
            return;
        }

        final List<FirebaseInstallation> installations;
        try {
            installations = installationRepository.findByUserId(userId);
        } catch (Exception error) {
            log.warn("FCM installation lookup failed for user {}: {}", userId, error.toString());
            return;
        }

        for (FirebaseInstallation installation : installations) {
            String fid = installation.getFirebaseInstallationId();
            if (fid == null || fid.isBlank()) {
                continue;
            }
            try {
                Message message = Message.builder()
                        .setFid(fid)
                        .setNotification(com.google.firebase.messaging.Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .putData("disruptionId", String.valueOf(disruptionId))
                        .putData("routeId", String.valueOf(routeId))
                        .putData("type", type)
                        .putData("severity", severity)
                        .build();

                firebaseMessaging.send(message);
                log.info("FCM disruption push accepted for user {}", userId);
            } catch (Exception error) {
                // Never propagate a push failure to notification persistence or RabbitMQ processing.
                log.warn("FCM disruption push failed for user {}: {}", userId, error.toString());
            }
        }
    }
}
