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