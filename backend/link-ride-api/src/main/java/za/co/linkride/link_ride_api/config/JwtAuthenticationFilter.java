package za.co.linkride.link_ride_api.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import za.co.linkride.link_ride_api.model.User;
import za.co.linkride.link_ride_api.repository.UserRepository;
import za.co.linkride.link_ride_api.service.JwtService;

import java.io.IOException;
import java.util.Collections;
import java.util.Optional;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    public JwtAuthenticationFilter(JwtService jwtService,
                                   UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = header.substring(7).trim();
        Long tokenUserId;
        String tokenEmail;

        try {
            if (token.isEmpty() || !jwtService.isTokenValid(token)) {
                SecurityContextHolder.clearContext();
                filterChain.doFilter(request, response);
                return;
            }

            tokenUserId = jwtService.extractUserId(token);
            tokenEmail = jwtService.extractEmail(token);
        } catch (RuntimeException invalidToken) {
            // Bad or malformed claims must never fail open or cause an unhandled 500.
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        if (tokenUserId == null || tokenEmail == null || tokenEmail.isBlank()) {
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        // Read the current account state and role on every authenticated request.
        // This ensures role changes and account deletion take effect immediately.
        Optional<User> optionalUser = userRepository.findById(tokenUserId);
        if (optionalUser.isEmpty()) {
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        User user = optionalUser.get();
        if (!"ACTIVE".equalsIgnoreCase(user.getAccountStatus())
                || user.getEmail() == null
                || !user.getEmail().equalsIgnoreCase(tokenEmail)
                || user.getRole() == null) {
            SecurityContextHolder.clearContext();
            filterChain.doFilter(request, response);
            return;
        }

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        user.getEmail(),
                        null,
                        Collections.singletonList(
                                new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
                        )
                );
        authentication.setDetails(user.getUserId());
        SecurityContextHolder.getContext().setAuthentication(authentication);
        filterChain.doFilter(request, response);
    }
}
