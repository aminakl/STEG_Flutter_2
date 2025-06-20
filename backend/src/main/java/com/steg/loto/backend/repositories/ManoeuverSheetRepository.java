package com.steg.loto.backend.repositories;

import com.steg.loto.backend.models.ManoeuverSheet;
import com.steg.loto.backend.models.LockoutNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ManoeuverSheetRepository extends JpaRepository<ManoeuverSheet, UUID> {
    Optional<ManoeuverSheet> findByLockoutNote(LockoutNote lockoutNote);
    Optional<ManoeuverSheet> findByWorkAttestationId(UUID workAttestationId);
    Optional<ManoeuverSheet> findByLockoutNoteId(UUID lockoutNoteId);
} 