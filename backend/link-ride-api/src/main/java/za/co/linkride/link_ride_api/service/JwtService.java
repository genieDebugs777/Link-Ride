package za.co.linkride.link_ride_api.service;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;
import io.jsonwebtoken.Claims;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import org.springframework.beans.factory.annotation.Value;
import za.co.linkride.link_ride_api.model.Role;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.expiration}")
    private long expirationTime;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(
                secretKey.getBytes(StandardCharsets.UTF_8)
        );
    }

    // Kept temporarily for compatibility with any existing callers.
    public String generateToken(
            Long userId,
            String email) {

        return generateToken(
                userId,
                email,
                Role.COMMUTER
        );
    }

    public String generateToken(
            Long userId,
            String email,
            Role role) {

        Date now = new Date();

        Date expiration =
                new Date(
                        now.getTime()
                                + expirationTime
                );

        Role safeRole =
                role == null
                        ? Role.COMMUTER
                        : role;

        return Jwts.builder()
                .subject(email)
                .claim("userId", userId)
                .claim(
                        "role",
                        safeRole.name()
                )
                .issuedAt(now)
                .expiration(expiration)
                .signWith(getSigningKey())
                .compact();
    }

    public String extractEmail(String token) {
        return extractClaims(token)
                .getSubject();
    }

    public Long extractUserId(String token) {
        return extractClaims(token)
                .get(
                        "userId",
                        Long.class
                );
    }

    public Role extractRole(String token) {

        String role =
                extractClaims(token)
                        .get(
                                "role",
                                String.class
                        );

        if (role == null ||
                role.isBlank()) {

            return Role.COMMUTER;
        }

        return Role.valueOf(role);
    }

    public boolean isTokenValid(String token) {
        try {
            Claims claims =
                    extractClaims(token);

            return claims
                    .getExpiration()
                    .after(new Date());

        } catch (Exception exception) {
            return false;
        }
    }

    private Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
