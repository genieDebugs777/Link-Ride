package za.co.linkride.link_ride_api.messaging;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.AmqpException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;
import za.co.linkride.link_ride_api.config.RabbitMqConfig;
import za.co.linkride.link_ride_api.event.DisruptionEvent;
import za.co.linkride.link_ride_api.model.Disruption;

import java.time.LocalDateTime;

@Component
public class DisruptionEventPublisher {

    private static final Logger logger =
            LoggerFactory.getLogger(
                    DisruptionEventPublisher.class
            );

    private final RabbitTemplate rabbitTemplate;

    public DisruptionEventPublisher(
            RabbitTemplate rabbitTemplate) {

        this.rabbitTemplate =
                rabbitTemplate;
    }

    public void publishCreated(
            Disruption disruption) {

        publish(
                "DISRUPTION_CREATED",
                disruption
        );
    }

    public void publishResolved(
            Disruption disruption) {

        publish(
                "DISRUPTION_RESOLVED",
                disruption
        );
    }

    private void publish(
            String eventType,
            Disruption disruption) {

        DisruptionEvent event =
                new DisruptionEvent(
                        eventType,
                        disruption.getDisruptionId(),
                        disruption.getRouteId(),
                        disruption.getProviderId(),
                        disruption.getDisruptionType(),
                        disruption.getSeverity(),
                        disruption.getTitle(),
                        disruption.getDescription(),
                        disruption.getDisruptionStatus(),
                        LocalDateTime.now()
                );

        try {
            rabbitTemplate.convertAndSend(
                    RabbitMqConfig.DISRUPTION_EXCHANGE,
                    RabbitMqConfig.DISRUPTION_ROUTING_KEY,
                    event
            );

            logger.info(
                    "Published {} for disruption {} on route {}.",
                    eventType,
                    disruption.getDisruptionId(),
                    disruption.getRouteId()
            );

        } catch (AmqpException error) {

            /*
             * Prototype resilience:
             * disruption persistence must continue to work
             * even when RabbitMQ is temporarily unavailable.
             *
             * A production system would normally use an
             * outbox/retry strategy to guarantee delivery.
             */
            logger.warn(
                    "RabbitMQ unavailable. Disruption {} was saved, but event {} could not be published.",
                    disruption.getDisruptionId(),
                    eventType,
                    error
            );
        }
    }
}
