-- ─────────────────────────────────────────────────────────────────────
-- V1__baseline.sql
-- Vetra Database Baseline Migration
--
-- This file establishes the Flyway baseline.
-- Entity schemas will be added by domain feature migrations (V2+).
-- ─────────────────────────────────────────────────────────────────────

-- Enable PostgreSQL extensions required by Vetra
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";    -- UUID generation
CREATE EXTENSION IF NOT EXISTS "postgis";       -- Geospatial (outbreak radius queries)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- Trigram search (animal tag, name search)

-- Set default timezone for all sessions
SET TIME ZONE 'UTC';
