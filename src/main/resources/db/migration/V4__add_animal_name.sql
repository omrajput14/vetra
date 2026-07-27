-- Flyway Migration V4: Add animal_name column to animals table
ALTER TABLE animals ADD COLUMN animal_name VARCHAR(100);
