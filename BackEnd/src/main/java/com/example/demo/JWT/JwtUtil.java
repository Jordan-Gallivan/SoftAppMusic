package com.example.demo.JWT;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.util.Date;

public class JwtUtil {

    private static final String SECRET = "secret";

    public String generateToken(String username) {
        int jwtExpirationInMinutes = 15;
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationInMinutes))
                .signWith(SignatureAlgorithm.HS512, SECRET)
                .compact();
    }

    public boolean validateToken(String jwt) {
        try {
            Jwts.parser().setSigningKey(SECRET).parseClaimsJws(jwt);
            return true;
        } catch (io.jsonwebtoken.ExpiredJwtException e) {
            System.out.println("JWT token is expired: " + e.getMessage());
        } catch (io.jsonwebtoken.SignatureException e) {
            System.out.println("JWT signature does not match locally computed signature: " + e.getMessage());
        } catch (Exception e) {
            System.out.println("JWT token is invalid: " + e.getMessage());
        }
        return false;
    }

    public String getUserNameFromToken(String jwt) {
        return Jwts.parser().setSigningKey(SECRET).parseClaimsJws(jwt).getBody().getSubject();
    }
}
