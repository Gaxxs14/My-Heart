-- ==========================================================
-- MY HEART - Database Schema for Neon PostgreSQL
-- ==========================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(100),
    avatar_url TEXT,
    mood_status VARCHAR(100) DEFAULT 'Enamorado/a 🥰',
    mood_icon VARCHAR(20) DEFAULT '🥰',
    is_online BOOLEAN DEFAULT false,
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fcm_token TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. COUPLES TABLE (Pairing Room)
CREATE TABLE IF NOT EXISTS couples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pairing_code VARCHAR(20) UNIQUE NOT NULL,
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'active', 'paused'
    anniversary_date DATE,
    relationship_time_start TIMESTAMP WITH TIME ZONE,
    pet_name VARCHAR(100) DEFAULT 'Corazoncito',
    pet_type VARCHAR(50) DEFAULT 'puppy', -- 'puppy', 'kitten', 'plant', 'bunny'
    pet_level INT DEFAULT 1,
    pet_xp INT DEFAULT 0,
    love_song_title VARCHAR(255),
    love_song_artist VARCHAR(255),
    love_song_url TEXT,
    love_song_lyrics TEXT,
    current_question_id UUID,
    theme_palette VARCHAR(50) DEFAULT 'rose_gold',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Foreign key reference on users to track couple
ALTER TABLE users ADD COLUMN IF NOT EXISTS couple_id UUID REFERENCES couples(id) ON DELETE SET NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS partner_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- 3. DAILY QUESTIONS TABLE
CREATE TABLE IF NOT EXISTS daily_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_text TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'deep', -- 'deep', 'fun', 'spicy', 'memories', 'future'
    emoji VARCHAR(20) DEFAULT '💬',
    day_number INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. DAILY QUESTION ANSWERS TABLE
CREATE TABLE IF NOT EXISTS daily_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES daily_questions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    answer_text TEXT NOT NULL,
    answered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(couple_id, question_id, user_id)
);

-- 5. TIMELINE MEMORIES (Private Moments)
CREATE TABLE IF NOT EXISTS timeline_memories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    photo_urls JSONB DEFAULT '[]'::jsonb,
    memory_date DATE NOT NULL,
    location_name VARCHAR(255),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. BUCKET LIST ITEMS (Dates & Goals)
CREATE TABLE IF NOT EXISTS bucket_list_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) DEFAULT 'travel', -- 'travel', 'food', 'date_night', 'adventure', 'home'
    is_completed BOOLEAN DEFAULT false,
    completed_date DATE,
    proof_photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. SECRET LETTERS / TIME CAPSULES
CREATE TABLE IF NOT EXISTS secret_letters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    unlock_type VARCHAR(50) DEFAULT 'date', -- 'date', 'mood'
    unlock_date TIMESTAMP WITH TIME ZONE,
    unlock_mood VARCHAR(100), -- 'sad', 'missing_you', 'anniversary', 'angry'
    is_opened BOOLEAN DEFAULT false,
    opened_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. HEARTBEATS (Real-time Pings / Touch)
CREATE TABLE IF NOT EXISTS heartbeats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vibration_pattern VARCHAR(50) DEFAULT 'double_pulse',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. STICKY NOTES (Post-its de Amor)
CREATE TABLE IF NOT EXISTS sticky_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    color VARCHAR(30) DEFAULT 'pink',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. COUPLE CALENDAR (Citas & Aniversarios)
CREATE TABLE IF NOT EXISTS couple_calendar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    emoji VARCHAR(20) DEFAULT '💖',
    event_type VARCHAR(50) DEFAULT 'date',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. ROMANTIC PLACES (Nuestros Lugares)
CREATE TABLE IF NOT EXISTS couple_places (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(255),
    category VARCHAR(50) DEFAULT 'restaurant',
    note TEXT,
    visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 12. SEED INITIAL DAILY QUESTIONS
INSERT INTO daily_questions (question_text, category, emoji, day_number) VALUES
('¿Cuál fue el momento exacto en que te diste cuenta de que te gustaba?', 'memories', '✨', 1),
('Si pudiéramos teletransportarnos a cualquier lugar del mundo durante 24 horas, ¿a dónde iríamos?', 'future', '✈️', 2),
('¿Qué pequeña cosa que hago siempre te hace sonreír sin que te des cuenta?', 'deep', '😊', 3),
('¿Cuál es tu recuerdo favorito de una de nuestras citas?', 'memories', '🍷', 4),
('¿Qué hábito o manía mía encuentras tierna o graciosa?', 'fun', '🤭', 5),
('Si tuviéramos que elegir una canción que describa nuestra relación hoy, ¿cuál sería?', 'deep', '🎵', 6),
('¿Cuál es un sueño o meta personal en el que te gustaría que te apoye más este año?', 'future', '🌱', 7),
('¿Qué comida o postre me prepararías para alegrarme un mal día?', 'fun', '🥞', 8),
('¿Qué es algo nuevo o atrevido que te gustaría intentar juntos?', 'spicy', '🔥', 9),
('¿Qué es lo que más agradeces de tenernos en nuestras vidas?', 'deep', '💖', 10)
ON CONFLICT DO NOTHING;

-- INDEXES for fast lookup
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_couples_pairing_code ON couples(pairing_code);
CREATE INDEX IF NOT EXISTS idx_daily_answers_couple ON daily_answers(couple_id, question_id);
CREATE INDEX IF NOT EXISTS idx_memories_couple ON timeline_memories(couple_id);
CREATE INDEX IF NOT EXISTS idx_bucket_couple ON bucket_list_items(couple_id);
CREATE INDEX IF NOT EXISTS idx_letters_couple ON secret_letters(couple_id);
CREATE INDEX IF NOT EXISTS idx_sticky_notes_couple ON sticky_notes(couple_id);
CREATE INDEX IF NOT EXISTS idx_couple_calendar_couple ON couple_calendar(couple_id);
CREATE INDEX IF NOT EXISTS idx_couple_places_couple ON couple_places(couple_id);
