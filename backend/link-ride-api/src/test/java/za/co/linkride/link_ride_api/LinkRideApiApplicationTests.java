package za.co.linkride.link_ride_api;

import com.google.firebase.FirebaseApp;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Configuration;
import org.springframework.test.context.ActiveProfiles;
import za.co.linkride.link_ride_api.service.FirebasePushNotificationService;

import static org.mockito.Mockito.mock;

@SpringBootTest
@ActiveProfiles("test")
@Import(LinkRideApiApplicationTests.FirebaseTestConfig.class)
class LinkRideApiApplicationTests {

	@Configuration(proxyBeanMethods = false)
	static class FirebaseTestConfig {

		@Bean
		@Primary
		FirebaseApp testFirebaseApp() {
			return mock(FirebaseApp.class);
		}

		@Bean
		@Primary
		FirebasePushNotificationService testFirebasePushService() {
			return mock(FirebasePushNotificationService.class);
		}
	}

	@Test
	void contextLoads() {
	}
}