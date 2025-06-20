package com.steg.loto.backend.repositories;

import com.steg.loto.backend.models.Work;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface WorkRepository extends JpaRepository<Work, UUID> {
} 