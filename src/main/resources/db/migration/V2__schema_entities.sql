-- ─────────────────────────────────────────────────────────────────────
-- V2__schema_entities.sql
-- Vetra Relational & Spatial Database Schema Migration
-- ─────────────────────────────────────────────────────────────────────

-- Ensure extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 1. USERS TABLE
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

-- 2. FARMER PROFILES TABLE
CREATE TABLE farmer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    farm_name VARCHAR(255),
    village VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    animal_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_farmer_profiles_user_id ON farmer_profiles(user_id);
CREATE INDEX idx_farmer_profiles_district ON farmer_profiles(district);

-- 3. VET PROFILES TABLE
CREATE TABLE vet_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    registration_number VARCHAR(100) NOT NULL UNIQUE,
    qualification VARCHAR(255),
    specialization VARCHAR(255),
    clinic_name VARCHAR(255),
    years_experience INT DEFAULT 0,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vet_profiles_user_id ON vet_profiles(user_id);
CREATE INDEX idx_vet_profiles_reg_no ON vet_profiles(registration_number);
CREATE INDEX idx_vet_profiles_availability ON vet_profiles(is_available);

-- 4. ANIMALS TABLE
CREATE TABLE animals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES farmer_profiles(id) ON DELETE CASCADE,
    tag_number VARCHAR(100) NOT NULL,
    qr_code_id VARCHAR(100) UNIQUE,
    species VARCHAR(30) NOT NULL,
    breed VARCHAR(100),
    gender VARCHAR(20) NOT NULL,
    birth_date DATE,
    photo_url VARCHAR(512),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_animals_farmer_id ON animals(farmer_id);
CREATE INDEX idx_animals_tag_number ON animals(tag_number);
CREATE INDEX idx_animals_qr_code ON animals(qr_code_id);
CREATE INDEX idx_animals_species ON animals(species);

-- 5. APPOINTMENTS TABLE
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES farmer_profiles(id) ON DELETE CASCADE,
    vet_id UUID NOT NULL REFERENCES vet_profiles(id) ON DELETE CASCADE,
    animal_id UUID REFERENCES animals(id) ON DELETE SET NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(30) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointments_farmer ON appointments(farmer_id);
CREATE INDEX idx_appointments_vet ON appointments(vet_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_scheduled ON appointments(scheduled_at);

-- 6. MEDICAL RECORDS TABLE
CREATE TABLE medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_id UUID NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
    vet_id UUID NOT NULL REFERENCES vet_profiles(id) ON DELETE CASCADE,
    diagnosis TEXT NOT NULL,
    treatment TEXT,
    prescription TEXT,
    vaccination VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_medical_records_animal ON medical_records(animal_id);
CREATE INDEX idx_medical_records_vet ON medical_records(vet_id);

-- 7. AI SCANS TABLE
CREATE TABLE ai_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farmer_id UUID NOT NULL REFERENCES farmer_profiles(id) ON DELETE CASCADE,
    image_url VARCHAR(512) NOT NULL,
    prediction VARCHAR(255) NOT NULL,
    confidence_score DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_scans_farmer ON ai_scans(farmer_id);

-- 8. DISEASE REPORTS TABLE (With PostGIS Point Geometry)
CREATE TABLE disease_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scan_id UUID REFERENCES ai_scans(id) ON DELETE SET NULL,
    farmer_id UUID NOT NULL REFERENCES farmer_profiles(id) ON DELETE CASCADE,
    vet_id UUID REFERENCES vet_profiles(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL,
    location GEOMETRY(Point, 4326),
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_disease_reports_farmer ON disease_reports(farmer_id);
CREATE INDEX idx_disease_reports_status ON disease_reports(status);
CREATE INDEX idx_disease_reports_location ON disease_reports USING GIST(location);

-- 9. OUTBREAKS TABLE (With PostGIS Point Geometry)
CREATE TABLE outbreaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    disease_name VARCHAR(255) NOT NULL,
    center_location GEOMETRY(Point, 4326) NOT NULL,
    radius_km DOUBLE PRECISION NOT NULL,
    declared_by_vet_id UUID NOT NULL REFERENCES vet_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outbreaks_center ON outbreaks USING GIST(center_location);
CREATE INDEX idx_outbreaks_disease ON outbreaks(disease_name);

-- 10. NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(30) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_receiver ON notifications(receiver_id, is_read);
