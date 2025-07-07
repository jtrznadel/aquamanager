-- AquaManager Database Schema
-- Updated to match current backend models

-- ==================== CREATE TABLES ====================

-- Aquariums table (updated fields)
CREATE TABLE aquariums (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity DECIMAL(10,2) NOT NULL CHECK (capacity > 0), -- Changed to capacity in liters
    water_type VARCHAR(50) NOT NULL CHECK (water_type IN ('freshwater', 'saltwater', 'brackish')),
    temperature DECIMAL(4,2), -- Temperature in Celsius
    ph DECIMAL(3,2) CHECK (ph >= 0 AND ph <= 14), -- pH level
    fish_count INTEGER DEFAULT 0 CHECK (fish_count >= 0),
    status VARCHAR(20) DEFAULT 'healthy' CHECK (status IN ('healthy', 'warning', 'critical')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fish table (updated fields)
CREATE TABLE fish (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(100) NOT NULL,
    aquarium_id INTEGER NOT NULL REFERENCES aquariums(id) ON DELETE CASCADE,
    age INTEGER CHECK (age >= 0), -- Age in years (optional)
    health VARCHAR(20) DEFAULT 'good' CHECK (health IN ('poor', 'fair', 'good', 'excellent')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table (updated fields to use camelCase format)
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    task_type VARCHAR(50) NOT NULL CHECK (task_type IN ('water_change', 'feeding', 'cleaning', 'testing', 'maintenance')),
    due_date TIMESTAMP WITH TIME ZONE NOT NULL, -- Changed to full timestamp
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    aquarium_id INTEGER NOT NULL REFERENCES aquariums(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== CREATE INDEXES ====================

-- Performance indexes
CREATE INDEX idx_fish_aquarium_id ON fish(aquarium_id);
CREATE INDEX idx_tasks_aquarium_id ON tasks(aquarium_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_completed ON tasks(is_completed);

-- Search indexes
CREATE INDEX idx_fish_name ON fish USING gin(to_tsvector('english', name));
CREATE INDEX idx_fish_species ON fish USING gin(to_tsvector('english', species));
CREATE INDEX idx_aquariums_name ON aquariums USING gin(to_tsvector('english', name));

-- ==================== CREATE TRIGGERS ====================

-- Auto-update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_aquariums_updated_at BEFORE UPDATE ON aquariums FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_fish_updated_at BEFORE UPDATE ON fish FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ==================== INSERT SAMPLE DATA ====================

-- Sample aquariums (using new schema)
INSERT INTO aquariums (name, capacity, water_type, temperature, ph, fish_count, status) VALUES
('Akwarium Główne', 240.0, 'freshwater', 24.5, 7.2, 1, 'healthy'),
('Akwarium Nano', 63.0, 'freshwater', 25.0, 6.8, 1, 'healthy'),
('Akwarium Morskie', 150.0, 'saltwater', 26.0, 8.1, 0, 'healthy');

-- Sample fish (using new schema)
INSERT INTO fish (name, species, aquarium_id, age, health) VALUES
('Nemo', 'Clownfish', 1, 2, 'good'),
('Dory', 'Blue Tang', 2, 3, 'excellent'),
('Bubbles', 'Goldfish', 1, 1, 'good');

-- Sample tasks (using new schema with timestamps)
INSERT INTO tasks (title, task_type, due_date, aquarium_id, is_completed) VALUES
('Wymiana wody', 'maintenance', NOW() + INTERVAL '1 day', 1, false),
('Karmienie ryb', 'feeding', NOW() + INTERVAL '12 hours', 2, false),
('Test parametrów wody', 'testing', NOW() + INTERVAL '3 days', 1, false),
('Czyszczenie filtra', 'cleaning', NOW() + INTERVAL '1 week', 1, false),
('Wymiana wody', 'maintenance', NOW() + INTERVAL '1 day', 3, false);
