-- ─────────────────────────────────────────────────────────────────────
-- V5__create_appointments.sql
-- Forward-compatible migration for Appointment Management Module
-- ─────────────────────────────────────────────────────────────────────

-- 1. Rename column vet_id to veterinarian_id if vet_id exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'appointments' AND column_name = 'vet_id'
    ) THEN
        ALTER TABLE appointments RENAME COLUMN vet_id TO veterinarian_id;
    END IF;
END $$;

-- 2. Add missing columns safely
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS appointment_date DATE;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS appointment_time TIME;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS visit_type VARCHAR(50);
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS reason TEXT;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS veterinarian_notes TEXT;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS version BIGINT NOT NULL DEFAULT 0;

-- 3. Populate appointment_date and appointment_time from legacy scheduled_at if scheduled_at exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'appointments' AND column_name = 'scheduled_at'
    ) THEN
        UPDATE appointments 
        SET appointment_date = CAST(scheduled_at AS DATE),
            appointment_time = CAST(scheduled_at AS TIME)
        WHERE appointment_date IS NULL AND scheduled_at IS NOT NULL;

        ALTER TABLE appointments ALTER COLUMN scheduled_at DROP NOT NULL;
    END IF;
END $$;

-- 4. Set fallback values for required fields on legacy records
UPDATE appointments SET visit_type = 'GENERAL_CHECKUP' WHERE visit_type IS NULL;
UPDATE appointments SET reason = 'Scheduled appointment' WHERE reason IS NULL;
UPDATE appointments SET appointment_date = CURRENT_DATE WHERE appointment_date IS NULL;
UPDATE appointments SET appointment_time = CURRENT_TIME WHERE appointment_time IS NULL;

-- 5. Copy notes to veterinarian_notes if present
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'appointments' AND column_name = 'notes'
    ) THEN
        UPDATE appointments SET veterinarian_notes = notes WHERE notes IS NOT NULL AND veterinarian_notes IS NULL;
    END IF;
END $$;

-- 6. Enforce NOT NULL constraints
ALTER TABLE appointments ALTER COLUMN appointment_date SET NOT NULL;
ALTER TABLE appointments ALTER COLUMN appointment_time SET NOT NULL;
ALTER TABLE appointments ALTER COLUMN visit_type SET NOT NULL;
ALTER TABLE appointments ALTER COLUMN reason SET NOT NULL;

-- 7. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_appointments_farmer_id ON appointments(farmer_id);
CREATE INDEX IF NOT EXISTS idx_appointments_veterinarian_id ON appointments(veterinarian_id);
CREATE INDEX IF NOT EXISTS idx_appointments_animal_id ON appointments(animal_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
