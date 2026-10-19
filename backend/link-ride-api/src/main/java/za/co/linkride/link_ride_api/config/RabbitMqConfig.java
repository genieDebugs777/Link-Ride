package za.co.linkride.link_ride_api.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.QueueBuilder;
import org.springframework.amqp.support.converter.JacksonJsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMqConfig {

    public static final String DISRUPTION_EXCHANGE =
            "linkride.disruptions.exchange";

    public static final String DISRUPTION_QUEUE =
            "linkride.disruptions.queue";

    public static final String DISRUPTION_ROUTING_KEY =
            "linkride.disruptions.event";

    @Bean
    public DirectExchange disruptionExchange() {
        return new DirectExchange(
                DISRUPTION_EXCHANGE,
                true,
                false
        );
    }

    @Bean
    public Queue disruptionQueue() {
        return QueueBuilder
                .durable(
                        DISRUPTION_QUEUE
                )
                .build();
    }

    @Bean
    public Binding disruptionBinding(
            Queue disruptionQueue,
            DirectExchange disruptionExchange) {

        return BindingBuilder
                .bind(
                        disruptionQueue
                )
                .to(
                        disruptionExchange
                )
                .with(
                        DISRUPTION_ROUTING_KEY
                );
    }

    @Bean
    public MessageConverter rabbitMessageConverter() {
        return new JacksonJsonMessageConverter();
    }
}
