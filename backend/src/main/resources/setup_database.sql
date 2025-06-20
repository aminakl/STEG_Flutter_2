-- Drop existing connections
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'loto_db'
AND pid <> pg_backend_pid();

-- Drop the database if it exists
DROP DATABASE IF EXISTS loto_db;

-- Create a new database
CREATE DATABASE loto_db;

-- Connect to the new database
\c loto_db

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  matricule VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true
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
  deconsignation_completed_at TIMESTAMP
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