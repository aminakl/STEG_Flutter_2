-- Create database (this should be run separately in psql)
-- CREATE DATABASE loto_db;

-- User table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  matricule VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true
);

-- Works table
CREATE TABLE IF NOT EXISTS works (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  description TEXT NOT NULL,
  worker_id INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Lockout notes table
CREATE TABLE IF NOT EXISTS lockout_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  poste_ht VARCHAR(100) NOT NULL,
  status VARCHAR(50) CHECK (status IN ('DRAFT', 'PENDING_CHEF_BASE', 'PENDING_CHARGE_EXPLOITATION', 'VALIDATED', 'REJECTED')),
  created_by INT REFERENCES users(id),
  validated_by_chef_base INT REFERENCES users(id),
  validated_by_charge_exploitation INT REFERENCES users(id),
  assigned_to INT REFERENCES users(id),
  rejection_reason TEXT,
  equipment_type VARCHAR(50) CHECK (equipment_type IN ('TRANSFORMATEUR MD', 'COUPLAGE HT/MD', 'LIGNE HT/MD', 'TRANSFORMATEUR_MD', 'COUPLAGE_HT_MD', 'LIGNE_HT_MD')),
  equipment_details TEXT,
  unite_steg VARCHAR(100) DEFAULT 'Unité STEG',
  work_nature TEXT,
  retrait_date TIMESTAMP,
  debut_travaux TIMESTAMP,
  fin_travaux TIMESTAMP,
  retour_date TIMESTAMP,
  jours_indisponibilite INT,
  charge_retrait VARCHAR(255),
  charge_consignation VARCHAR(255),
  charge_travaux VARCHAR(255),
  charge_essais VARCHAR(255),
  instructions_techniques TEXT,
  destinataires TEXT,
  coupure_demandee_par VARCHAR(255),
  note_transmise_a VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  validated_at_chef_base TIMESTAMP,
  validated_at_charge_exploitation TIMESTAMP,
  assigned_at TIMESTAMP,
  consignation_started_at TIMESTAMP,
  consignation_completed_at TIMESTAMP,
  deconsignation_started_at TIMESTAMP,
  deconsignation_completed_at TIMESTAMP,
  work_id UUID REFERENCES works(id)
);

-- Equipment type mapping table
CREATE TABLE IF NOT EXISTS equipment_type_mapping (
  lockout_note_type VARCHAR(50) PRIMARY KEY,
  manoeuver_sheet_type VARCHAR(50) NOT NULL,
  schema_image VARCHAR(255) NOT NULL,
  CONSTRAINT fk_lockout_note_type CHECK (lockout_note_type IN ('TRANSFORMATEUR MD', 'COUPLAGE HT/MD', 'LIGNE HT/MD', 'TRANSFORMATEUR_MD', 'COUPLAGE_HT_MD', 'LIGNE_HT_MD')),
  CONSTRAINT fk_manoeuver_sheet_type CHECK (manoeuver_sheet_type IN ('TRANSFORMATEUR', 'COUPLAGE', 'LIGNE_HT'))
);

-- Manoeuver sheets table
CREATE TABLE IF NOT EXISTS manoeuver_sheets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lockout_note_id UUID NOT NULL REFERENCES lockout_notes(id),
  created_by_id INT NOT NULL REFERENCES users(id),
  equipment_type VARCHAR(50) NOT NULL CHECK (equipment_type IN ('TRANSFORMATEUR', 'COUPLAGE', 'LIGNE_HT')),
  epi_verified BOOLEAN NOT NULL DEFAULT FALSE,
  epi_verified_at TIMESTAMP,
  consignation_started BOOLEAN NOT NULL DEFAULT FALSE,
  consignation_started_at TIMESTAMP,
  consignation_completed BOOLEAN NOT NULL DEFAULT FALSE,
  consignation_completed_at TIMESTAMP,
  deconsignation_started BOOLEAN NOT NULL DEFAULT FALSE,
  deconsignation_started_at TIMESTAMP,
  deconsignation_completed BOOLEAN NOT NULL DEFAULT FALSE,
  deconsignation_completed_at TIMESTAMP,
  work_attestation_id UUID,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Work attestations table
CREATE TABLE IF NOT EXISTS work_attestations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manoeuver_sheet_id UUID NOT NULL REFERENCES manoeuver_sheets(id),
  work_id UUID NOT NULL REFERENCES works(id),
  worker_id INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Work attestation equipment types table
CREATE TABLE IF NOT EXISTS work_attestation_equipment_types (
  work_attestation_id UUID NOT NULL REFERENCES work_attestations(id),
  equipment_type VARCHAR(50) NOT NULL,
  PRIMARY KEY (work_attestation_id, equipment_type),
  CONSTRAINT fk_equipment_type CHECK (equipment_type IN ('TRANSFORMATEUR', 'COUPLAGE', 'LIGNE_HT'))
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  related_note_id UUID,
  user_id INT NOT NULL REFERENCES users(id),
  read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- Create indexes for lockout_notes
CREATE INDEX IF NOT EXISTS idx_lockout_notes_status ON lockout_notes(status);
CREATE INDEX IF NOT EXISTS idx_lockout_notes_created_by ON lockout_notes(created_by);
CREATE INDEX IF NOT EXISTS idx_lockout_notes_assigned_to ON lockout_notes(assigned_to);
CREATE INDEX IF NOT EXISTS idx_lockout_notes_created_at ON lockout_notes(created_at);

-- Create indexes for manoeuver_sheets
CREATE INDEX IF NOT EXISTS idx_manoeuver_sheets_lockout_note_id ON manoeuver_sheets(lockout_note_id);
CREATE INDEX IF NOT EXISTS idx_manoeuver_sheets_created_by_id ON manoeuver_sheets(created_by_id);
CREATE INDEX IF NOT EXISTS idx_manoeuver_sheets_work_attestation_id ON manoeuver_sheets(work_attestation_id);
CREATE INDEX IF NOT EXISTS idx_manoeuver_sheets_created_at ON manoeuver_sheets(created_at);

-- Create indexes for work_attestations
CREATE INDEX IF NOT EXISTS idx_work_attestations_manoeuver_sheet_id ON work_attestations(manoeuver_sheet_id);
CREATE INDEX IF NOT EXISTS idx_work_attestations_work_id ON work_attestations(work_id);
CREATE INDEX IF NOT EXISTS idx_work_attestations_worker_id ON work_attestations(worker_id);
CREATE INDEX IF NOT EXISTS idx_work_attestations_created_at ON work_attestations(created_at);

-- Insert equipment type mappings
INSERT INTO equipment_type_mapping (lockout_note_type, manoeuver_sheet_type, schema_image) VALUES
  ('TRANSFORMATEUR MD', 'TRANSFORMATEUR', 'assets/schemas/TRANSFORMATEUR.png'),
  ('TRANSFORMATEUR_MD', 'TRANSFORMATEUR', 'assets/schemas/TRANSFORMATEUR.png'),
  ('COUPLAGE HT/MD', 'COUPLAGE', 'assets/schemas/COUPLAGE.png'),
  ('COUPLAGE_HT_MD', 'COUPLAGE', 'assets/schemas/COUPLAGE.png'),
  ('LIGNE HT/MD', 'LIGNE_HT', 'assets/schemas/LIGNE_HT.png'),
  ('LIGNE_HT_MD', 'LIGNE_HT', 'assets/schemas/LIGNE_HT.png')
ON CONFLICT (lockout_note_type) DO UPDATE
SET manoeuver_sheet_type = EXCLUDED.manoeuver_sheet_type,
    schema_image = EXCLUDED.schema_image;

-- Insert admin user (password: admin123)
INSERT INTO users (matricule, email, password_hash, role) 
VALUES ('ADMIN001', 'admin@steg.com.tn', '$2a$10$7YYsmzEw49yNnykpwOpUz.hzAinn8SE/xvFVuakT92KkKHF5WNxd.', 'ADMIN')
ON CONFLICT (matricule) DO NOTHING;

-- Insert sample users with all roles (password: admin123 for all)
INSERT INTO users (matricule, email, password_hash, role) 
VALUES 
  ('CHEF001', 'chef@steg.com.tn', '$2a$10$7YYsmzEw49yNnykpwOpUz.hzAinn8SE/xvFVuakT92KkKHF5WNxd.', 'CHEF_EXPLOITATION'),
  ('CHARGE001', 'charge@steg.com.tn', '$2a$10$7YYsmzEw49yNnykpwOpUz.hzAinn8SE/xvFVuakT92KkKHF5WNxd.', 'CHARGE_CONSIGNATION'),
  ('BASE001', 'base@steg.com.tn', '$2a$10$7YYsmzEw49yNnykpwOpUz.hzAinn8SE/xvFVuakT92KkKHF5WNxd.', 'CHEF_DE_BASE'),
  ('CHARGEX001', 'chargex@steg.com.tn', '$2a$10$7YYsmzEw49yNnykpwOpUz.hzAinn8SE/xvFVuakT92KkKHF5WNxd.', 'CHARGE_EXPLOITATION')
ON CONFLICT (matricule) DO NOTHING;
