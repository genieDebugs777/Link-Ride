package za.co.linkride.link_ride_api.messaging;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;
import za.co.linkride.link_ride_api.config.RabbitMqConfig;
import za.co.linkride.link_ride_api.event.DisruptionEvent;
import za.co.linkride.link_ride_api.service.NotificationService;

@Component
public class DisruptionEventListener {

    private static final Logger logger =
            LoggerFactory.getLogger(
                    DisruptionEventListener.class
            );

    private final NotificationService notificationService;

    public DisruptionEventListener(
            NotificationService notificationService) {

        this.notificationService =
                notificationService;
    }

    @RabbitListener(
            queues = RabbitMqConfig.DISRUPTION_QUEUE
    )
    public void handleDisruptionEvent(
            DisruptionEvent event) {

        logger.info(
                "Consumed disruption event: type={}, disruptionId={}, routeId={}, severity={}, status={}",
                event.getEventType(),
                event.getDisruptionId(),
                event.getRouteId(),
                event.getSeverity(),
                event.getDisruptionStatus()
        );

        int createdNotifications =
                notificationService
                        .createNotificationsForDisruptionEvent(
                                event
                        );

        logger.info(
                "Created {} Link Ride notification(s) for disruption event {}.",
                createdNotifications,
                event.getEventType()
        );
    }
}
