package com.steg.loto.backend.repositories;

import com.steg.loto.backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByMatricule(String matricule);
    Optional<User> findByEmail(String email);
    List<User> findByRole(String role);
    Boolean existsByMatricule(String matricule);
    Boolean existsByEmail(String email);
}
