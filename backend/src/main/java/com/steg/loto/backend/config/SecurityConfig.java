package com.steg.loto.backend.config;

import com.steg.loto.backend.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource())) // Enable CORS
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/").permitAll() // Allow access to root endpoint
                .requestMatchers("/api/auth/**").permitAll() // Allow access to authentication endpoints
                .requestMatchers("/api/test/**").permitAll() // Allow access to test endpoints
                // Allow all roles to access notes endpoints with role-based filtering handled at the controller level
                .requestMatchers("/api/notes/**").hasAnyAuthority("ADMIN", "CHEF_EXPLOITATION", "CHEF_DE_BASE", "CHARGE_EXPLOITATION", "CHARGE_CONSIGNATION")
                .requestMatchers("/api/manoeuver-sheets/**").hasAnyAuthority("CHARGE_CONSIGNATION", "ADMIN", "CHEF_EXPLOITATION", "CHEF_DE_BASE", "CHARGE_EXPLOITATION")
                // Admin-only endpoints
                .requestMatchers("/api/admin/**").hasAuthority("ADMIN")
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(corsFilter(), UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();
        // Allow credentials
        corsConfiguration.setAllowCredentials(false); // Change to false to allow wildcard
        // Allow all origins
        corsConfiguration.addAllowedOrigin("*");
        // For specific origins if needed
        /*
        corsConfiguration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000", 
            "http://localhost:8080", 
            "http://10.0.2.2:8080",
            "http://10.0.2.2",
            "http://localhost",
            "capacitor://localhost",
            "ionic://localhost"
        ));
        */
        corsConfiguration.setAllowedHeaders(Arrays.asList(
            "Origin", 
            "Access-Control-Allow-Origin", 
            "Content-Type",
            "Accept", 
            "Authorization", 
            "Origin, Accept", 
            "X-Requested-With",
            "Access-Control-Request-Method", 
            "Access-Control-Request-Headers"
        ));
        corsConfiguration.setExposedHeaders(Arrays.asList(
            "Origin", 
            "Content-Type", 
            "Accept", 
            "Authorization",
            "Access-Control-Allow-Origin", 
            "Access-Control-Allow-Credentials"
        ));
        corsConfiguration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        UrlBasedCorsConfigurationSource urlBasedCorsConfigurationSource = new UrlBasedCorsConfigurationSource();
        urlBasedCorsConfigurationSource.registerCorsConfiguration("/**", corsConfiguration);
        return new CorsFilter(urlBasedCorsConfigurationSource);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // Allow all origins
        configuration.addAllowedOrigin("*");
        // For specific origins if needed
        /*
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000", 
            "http://localhost:8080", 
            "http://10.0.2.2:8080",
            "http://10.0.2.2",
            "http://localhost",
            "capacitor://localhost",
            "ionic://localhost"
        ));
        */
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setExposedHeaders(Arrays.asList(
            "Origin", 
            "Content-Type", 
            "Accept", 
            "Authorization",
            "Access-Control-Allow-Origin", 
            "Access-Control-Allow-Credentials"
        ));
        configuration.setAllowCredentials(false); // Changed to false to allow wildcard origins
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
