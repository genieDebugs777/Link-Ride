package za.co.linkride.link_ride_api.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import za.co.linkride.link_ride_api.dto.NotificationPreferencesRequest;
import za.co.linkride.link_ride_api.model.NotificationPreference;
import za.co.linkride.link_ride_api.repository.NotificationPreferenceRepository;

@Service
public class NotificationPreferenceService {

    private final NotificationPreferenceRepository repository;

    public NotificationPreferenceService(
            NotificationPreferenceRepository repository) {

        this.repository = repository;
    }

    public NotificationPreference getPreferences(
            Long userId) {

        return repository
                .findByUserId(userId)
                .orElseGet(
                        () -> new NotificationPreference(userId)
                );
    }

    @Transactional
    public NotificationPreference savePreferences(
            Long userId,
            NotificationPreferencesRequest request) {

        NotificationPreference preference =
                repository
                        .findByUserId(userId)
                        .orElseGet(
                                () -> new NotificationPreference(userId)
                        );

        preference.setDisruptionAlerts(
                request.isDisruptionAlerts()
        );

        preference.setJourneyUpdates(
                request.isJourneyUpdates()
        );

        preference.setTicketPaymentUpdates(
                request.isTicketPaymentUpdates()
        );

        preference.setGeneralNotifications(
                request.isGeneralNotifications()
        );

        return repository.save(
                preference
        );
    }

    public boolean allowsDisruptionAlerts(
            Long userId) {

        return repository
                .findByUserId(userId)
                .map(
                        NotificationPreference
                                ::isDisruptionAlerts
                )
                .orElse(true);
    }
}
