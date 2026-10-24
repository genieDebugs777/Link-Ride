package za.co.linkride.link_ride_api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(
            JwtAuthenticationFilter jwtAuthenticationFilter) {

        this.jwtAuthenticationFilter =
                jwtAuthenticationFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http)
            throws Exception {

        http
                .csrf(csrf -> csrf.disable())

                .sessionManagement(session ->
                        session.sessionCreationPolicy(
                                SessionCreationPolicy.STATELESS
                        )
                )

                .exceptionHandling(exception -> exception

                        .authenticationEntryPoint(
                                (request, response, authException) -> {
                                    response.setStatus(
                                            HttpStatus.UNAUTHORIZED.value()
                                    );
                                    response.setContentType(
                                            "application/json"
                                    );
                                    response.getWriter().write(
                                            "{\"message\":\"Unauthorized\"}"
                                    );
                                }
                        )

                        .accessDeniedHandler(
                                (request, response, accessDeniedException) -> {
                                    response.setStatus(
                                            HttpStatus.FORBIDDEN.value()
                                    );
                                    response.setContentType(
                                            "application/json"
                                    );
                                    response.getWriter().write(
                                            "{\"message\":\"Forbidden\"}"
                                    );
                                }
                        )
                )

                .authorizeHttpRequests(auth -> auth

                        // Public authentication and recovery endpoints.
                        .requestMatchers(
                                "/api/users/register",
                                "/api/users/login",
                                "/api/users/verify-mfa",
                                "/api/users/resend-mfa",
                                "/api/users/verify-email",
                                "/api/users/resend-verification",
                                "/api/users/forgot-password",
                                "/api/users/reset-password"
                        ).permitAll()

                        // User administration.
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/users"
                        ).hasRole("ADMIN")

                        .requestMatchers(
                                HttpMethod.DELETE,
                                "/api/users/*"
                        ).hasRole("ADMIN")


                        .requestMatchers(
                                HttpMethod.PATCH,
                                "/api/users/*/role"
                        ).hasRole("ADMIN")

                        // A user's own profile is checked again in UserController.
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/users/*"
                        ).authenticated()

                        .requestMatchers(
                                HttpMethod.PUT,
                                "/api/users/*"
                        ).authenticated()

                        // All authenticated roles can read disruption information.
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/disruptions/**"
                        ).authenticated()

                        // Only transport operators and administrators may
                        // create or resolve service disruptions.
                        .requestMatchers(
                                HttpMethod.POST,
                                "/api/disruptions"
                        ).hasAnyRole(
                                "OPERATOR",
                                "ADMIN"
                        )

                        .requestMatchers(
                                HttpMethod.PUT,
                                "/api/disruptions/*/resolve"
                        ).hasAnyRole(
                                "OPERATOR",
                                "ADMIN"
                        )

                        // Other application functionality remains available
                        // to authenticated users until later role-specific
                        // endpoints are introduced.
                        .anyRequest().authenticated()
                )

                .addFilterBefore(
                        jwtAuthenticationFilter,
                        UsernamePasswordAuthenticationFilter.class
                );

        return http.build();
    }
}
