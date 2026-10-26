
package za.co.linkride.link_ride_api;

import com.google.firebase.FirebaseApp;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import za.co.linkride.link_ride_api.model.Role;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.repository.UserRepository;
import za.co.linkride.link_ride_api.service.FirebasePushNotificationService;
import za.co.linkride.link_ride_api.service.JwtService;

import java.time.LocalDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityAuthorizationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    @MockitoBean
    private FirebaseApp firebaseApp;

    @MockitoBean
    private FirebasePushNotificationService firebasePushNotificationService;

    @MockitoBean
    private JavaMailSender javaMailSender;

    private String createTestToken(Role role) {

        String email = "security-" +
                role.name().toLowerCase() +
                "-" +
                java.util.UUID.randomUUID() +
                "@example.invalid";

        User user = new User(
                "Security",
                "Tester",
                email,
                null,
                "test-only-password-hash",
                LocalDateTime.now(),
                "ACTIVE",
                role
        );

        user = userRepository.save(user);

        return jwtService.generateToken(
                user.getUserId(),
                user.getEmail(),
                role
        );
    }

    @Test
    void anonymousUserCannotAccessAdminUsers() throws Exception {

        mockMvc.perform(get("/api/users"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void invalidJwtCannotAccessAdminUsers() throws Exception {

        mockMvc.perform(
                get("/api/users")
                        .header(
                                "Authorization",
                                "Bearer invalid.test.token"
                        )
        ).andExpect(status().isUnauthorized());
    }

    @Test
    void commuterCannotAccessAdminUsers() throws Exception {

        String token = createTestToken(Role.COMMUTER);

        mockMvc.perform(
                get("/api/users")
                        .header("Authorization", "Bearer " + token)
        ).andExpect(status().isForbidden());
    }

    @Test
    void adminCanAccessAdminUsers() throws Exception {

        String token = createTestToken(Role.ADMIN);

        mockMvc.perform(
                get("/api/users")
                        .header("Authorization", "Bearer " + token)
        ).andExpect(status().isOk());
    }

    @Test
    void commuterCannotCreateDisruption() throws Exception {

        String token = createTestToken(Role.COMMUTER);

        mockMvc.perform(
                post("/api/disruptions")
                        .header("Authorization", "Bearer " + token)
                        .contentType("application/json")
                        .content("""
                                {
                                  "routeId": 1,
                                  "disruptionType": "DELAY",
                                  "severity": "LOW",
                                  "title": "TEST disruption",
                                  "description": "Security authorization test."
                                }
                                """)
        ).andExpect(status().isForbidden());
    }


    @Test
    void deactivatedAccountCannotUseExistingJwt() throws Exception {

        String token = createTestToken(Role.ADMIN);

        // Confirm the existing token initially has ADMIN access.
        mockMvc.perform(
                get("/api/users")
                        .header("Authorization", "Bearer " + token)
        ).andExpect(status().isOk());

        // Identify the test account without changing the JWT.
        Long userId = jwtService.extractUserId(token);

        User user = userRepository.findById(userId)
                .orElseThrow();

        user.setAccountStatus("INACTIVE");
        userRepository.saveAndFlush(user);

        // The same JWT must no longer authenticate.
        mockMvc.perform(
                get("/api/users")
                        .header("Authorization", "Bearer " + token)
        ).andExpect(status().isUnauthorized());
    }

    @Test
    void demotedAdminLosesPrivilegesWithExistingJwt() throws Exception {

        String token = createTestToken(Role.ADMIN);

        // Confirm access before demotion.
        mockMvc.perform(
                get("/api/users")
                        .header("Authorization", "Bearer " + token)
        ).andExpect(status().isOk());

        Long userId = jwtService.extractUserId(token);

        User user = userRepository.findById(userId)
                .orElseThrow();

        // Revoke ADMIN privileges in the database.
        user.setRole(Role.COMMUTER);
        userRepository.saveAndFlush(user);

        // Same JWT, but current database role is COMMUTER.
        mockMvc.perform(
                get("/api/users")
                        .header("Authorization", "Bearer " + token)
        ).andExpect(status().isForbidden());
    }

}
