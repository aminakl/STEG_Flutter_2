package com.steg.loto.backend.repositories;

import com.steg.loto.backend.models.LockoutNote;
import com.steg.loto.backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface LockoutNoteRepository extends JpaRepository<LockoutNote, UUID> {
    List<LockoutNote> findByCreatedBy(User user);
    List<LockoutNote> findByStatus(LockoutNote.NoteStatus status);
    List<LockoutNote> findByPosteHtContainingIgnoreCase(String posteHt);
}
