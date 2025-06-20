package com.steg.loto.backend.repositories;

import com.steg.loto.backend.models.WorkAttestation;
import com.steg.loto.backend.models.ManoeuverSheet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WorkAttestationRepository extends JpaRepository<WorkAttestation, UUID> {
    Optional<WorkAttestation> findByManoeuverSheet(ManoeuverSheet manoeuverSheet);
} 