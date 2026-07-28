-- ─────────────────────────────────────────────────────────────────────
-- V6__create_medical_records.sql
-- Electronic Veterinary Medical Record (EVMR) Module Schema
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL UNIQUE,
    animal_id UUID NOT NULL,
    farmer_id UUID NOT NULL,
    veterinarian_id UUID NOT NULL,
    diagnosis TEXT NOT NULL,
    symptoms TEXT,
    treatment TEXT NOT NULL,
    prescription TEXT,
    weight NUMERIC(6,2),
    temperature NUMERIC(4,1),
    follow_up_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT fk_medical_records_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    CONSTRAINT fk_medical_records_animal FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE,
    CONSTRAINT fk_medical_records_farmer FOREIGN KEY (farmer_id) REFERENCES farmer_profiles(id) ON DELETE CASCADE,
    CONSTRAINT fk_medical_records_veterinarian FOREIGN KEY (veterinarian_id) REFERENCES vet_profiles(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_medical_records_animal_id ON medical_records(animal_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_veterinarian_id ON medical_records(veterinarian_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_farmer_id ON medical_records(farmer_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_appointment_id ON medical_records(appointment_id);
